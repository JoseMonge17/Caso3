CREATE OR ALTER PROCEDURE [dbo].[sp_revisar_propuesta]
    @proposalid INT,
    @userid INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT;
    DECLARE @Message NVARCHAR(4000);
    DECLARE @InicieTransaccion BIT = 0;
    DECLARE @now DATETIME = GETDATE();
    DECLARE @cursor_initialized BIT = 0;
    
    -- Parametros para el log de errores
    DECLARE @log_typeid INT, @log_sourceid INT, @log_severityid INT;
    SELECT @log_severityid = log_severityid FROM vpv_log_severity WHERE name = 'Error';
    SELECT @log_sourceid = log_sourceid FROM vpv_log_source WHERE name = 'Procedimiento sp_revisar_propuesta';
    SELECT @log_typeid = log_typeid FROM vpv_log_type WHERE name = 'Error SQL';

	CREATE TABLE #reviewSummary (
		documentid INT,
		reviewed_at DATETIME,
		reviewed_by NVARCHAR(50)
	);

    IF @@TRANCOUNT = 0
    BEGIN
        SET @InicieTransaccion = 1;
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        BEGIN TRANSACTION;
    END

    BEGIN TRY
		-- Validar permiso por rol (PROP_APPROVE)
		IF NOT EXISTS (
			SELECT 1
			FROM vpv_user_roles ur
			JOIN vpv_rolepermissions rp ON rp.roleid = ur.roleid AND rp.enable = 1 AND rp.deleted = 0
			JOIN vpv_permissions p ON p.permissionid = rp.permissionid
			WHERE ur.userid = @userid AND ur.enabled = 1
			  AND p.permissioncode = 'PROP_APPROVE'
		)
		BEGIN
			SET @Message = 'El usuario no tiene permisos para aprobar propuestas.';
			INSERT INTO vpv_logs (
				description, posttime, computer, trace,
				reference_id1, reference_id2, value1, value2,
				checksum, log_typeid, log_sourceid, log_severityid
			)
			VALUES (
				@Message, GETDATE(), HOST_NAME(), 'sp_revisar_propuesta',
				NULL, @userid, NULL, NULL,
				HASHBYTES('SHA1', @Message), @log_typeid, @log_sourceid, @log_severityid
			);
			RAISERROR(@Message, 16, 1);
			RETURN;
		END

        -- Existe la propuesta
        IF NOT EXISTS (SELECT 1 FROM vpv_proposal WHERE proposalid = @proposalid)
        BEGIN
            SET @Message = 'La propuesta ' + CAST(@proposalid AS VARCHAR) + ' no existe';
            
            -- Registrar en log
            INSERT INTO vpv_logs (
                description, posttime, computer, trace,
                reference_id1, reference_id2, value1, value2,
                checksum, log_typeid, log_sourceid, log_severityid
            )
            VALUES (
                @Message, GETDATE(), HOST_NAME(), 'sp_revisar_propuesta',
                @proposalid, @userid, NULL, NULL,
                HASHBYTES('SHA1', @Message), @log_typeid, @log_sourceid, @log_severityid
            );
            
            RAISERROR(@Message, 16, 1);
            RETURN;
        END

        -- Crear solicitud
        DECLARE @requestid INT;
        INSERT INTO vpv_validation_request (creation_date, userid, validation_typeid)
        VALUES (@now, @userid, 6);
        SET @requestid = SCOPE_IDENTITY();

        -- Comenzar la simulacion del workflow
        DECLARE @documentid INT, @workflowid INT, @has_workflow BIT;
        DECLARE @documents_processed INT = 0;

        DECLARE cur CURSOR LOCAL FOR
        SELECT 
            dd.documentid, 
            ISNULL(dw.workflowid, 0),
            CASE WHEN dw.workflowid IS NULL THEN 0 ELSE 1 END
        FROM vpv_proposal_documents pd
        JOIN vpv_digital_documents dd ON dd.documentid = pd.documentid
        LEFT JOIN vpv_document_workflows dw ON dd.documentid = dw.documentid AND dw.enabled = 1
        WHERE pd.proposalid = @proposalid
        ORDER BY ISNULL(dw.workflow_order, 99);

        SET @cursor_initialized = 1;
        OPEN cur;
        FETCH NEXT FROM cur INTO @documentid, @workflowid, @has_workflow;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @has_workflow = 1
            BEGIN
                -- Obtener parametros base del workflow
                DECLARE @parameters NVARCHAR(MAX), @workflow_name NVARCHAR(100);
                
                SELECT 
                    @workflow_name = workflow_name,
                    @parameters = parameter
                FROM vpv_validation_workflow
                WHERE workflowid = @workflowid;

                -- Simular delay de llamada a Airflow
                -- WAITFOR DELAY '00:00:01'; Está comentado, pues lambda da un timeout si se queda "esperando"
                
				DECLARE @reviewed_at DATETIME = GETDATE();
				DECLARE @reviewed_by NVARCHAR(50) = 'IA_AUTOMATICA';

				INSERT INTO #reviewSummary (documentid, reviewed_at, reviewed_by)
				VALUES (@documentid, @reviewed_at, @reviewed_by);
            END
            
            -- Actualizar documento
            UPDATE vpv_digital_documents
            SET requestid = @requestid,
                validation_date = @now
            WHERE documentid = @documentid;

            SET @documents_processed += 1;
            FETCH NEXT FROM cur INTO @documentid, @workflowid, @has_workflow;
        END

        -- Verificar que se procesaron documentos
        IF @documents_processed = 0
        BEGIN
            SET @Message = 'No se encontraron documentos para validar en la propuesta ' + CAST(@proposalid AS VARCHAR);
            
            -- Registrar en log
            INSERT INTO vpv_logs (
                description, posttime, computer, trace,
                reference_id1, reference_id2, value1, value2,
                checksum, log_typeid, log_sourceid, log_severityid
            )
            VALUES (
                @Message, GETDATE(), HOST_NAME(), 'sp_revisar_propuesta',
                @proposalid, @userid, NULL, NULL,
                HASHBYTES('SHA1', @Message), @log_typeid, @log_sourceid, @log_severityid
            );
            
            RAISERROR(@Message, 16, 1);
        END

        -- 3. Finalizar validaci�n (�xito autom�tico como indic� el encargado)
        UPDATE vpv_validation_request
        SET finish_date = @now,
            global_result = '�xito'
        WHERE requestid = @requestid;

        -- 4. Aprobar propuesta (statusid = 3)
        UPDATE vpv_proposal
        SET statusid = 3
        WHERE proposalid = @proposalid;

		IF @InicieTransaccion = 1
		BEGIN
			SELECT 
				'Éxito' AS resultado, 
				@proposalid AS propuesta_aprobada,
				@documents_processed AS documentos_procesados;

			-- Toma los datos de reviewSummary para visualizar el resultado del workflow
			SELECT 
				r.documentid,
				d.name,
				r.reviewed_at,
				r.reviewed_by
			FROM #reviewSummary r
			JOIN vpv_digital_documents d ON d.documentid = r.documentid;

			COMMIT;
		END
    END TRY
    BEGIN CATCH
        SET @ErrorNumber = ERROR_NUMBER();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @Message = 'Error en sp_revisar_propuesta: ' + 
                      'L�nea ' + CAST(ERROR_LINE() AS VARCHAR) + ' | ' + 
                      ERROR_MESSAGE();

		IF LEN(@Message) > 200
			SET @Message = LEFT(@Message, 200);
        
        -- Manejo seguro del cursor en caso de error
        IF @cursor_initialized = 1 AND CURSOR_STATUS('local','cur') >= 0
        BEGIN
            CLOSE cur;
            DEALLOCATE cur;
        END

        IF @InicieTransaccion = 1
            ROLLBACK;
        
        -- Log del error real 
        INSERT INTO vpv_logs (
            description,
            posttime,
            computer,
            trace,
            reference_id1,
            reference_id2,
            value1,
            value2,
            checksum,
            log_typeid,
            log_sourceid,
            log_severityid
        )
        VALUES (
            @Message,
            GETDATE(),
            HOST_NAME(),
            ERROR_PROCEDURE(),
            @proposalid,
            @userid,
            CAST(@ErrorNumber AS VARCHAR),
            CAST(@ErrorState AS VARCHAR),
            HASHBYTES('SHA1', @Message),
            @log_typeid,
            @log_sourceid,
            @log_severityid
        );
        
        -- Error "amigable" para la API
        RAISERROR('%s', 16, 1, @Message);
    END CATCH
    
    -- Liberaci�n final del cursor si a�n existe
    IF @cursor_initialized = 1 AND CURSOR_STATUS('local','cur') >= 0
    BEGIN
        CLOSE cur;
        DEALLOCATE cur;
    END
END
GO
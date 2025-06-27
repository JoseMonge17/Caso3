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
    DECLARE @log_typeid INT = 1;        -- Tipo de log para errores
    DECLARE @log_sourceid INT = 1002;   -- ID de fuente para revisi�n de propuestas
    DECLARE @log_severityid INT = 3;    -- Severidad de error (3 = Error)

    IF @@TRANCOUNT = 0
    BEGIN
        SET @InicieTransaccion = 1;
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        BEGIN TRANSACTION;
    END

    BEGIN TRY
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

        -- COmenzar la simulacion del workflow
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
            COMMIT;
            SELECT '�xito' AS resultado, 
                   @proposalid AS propuesta_aprobada,
                   @documents_processed AS documentos_procesados;
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
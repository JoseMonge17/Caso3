CREATE OR ALTER PROCEDURE [dbo].[sp_crear_actualizar_propuesta]
    @name               VARCHAR(100),
    @description        VARCHAR(255),
    @origin_typeid      INT,
    @userid             INT,
    @proposal_typeid    INT,
    @entityid           INT = NULL,
    @documents          NVARCHAR(MAX), -- JSON con todos los datos del documento digital + is_required
    @version_comment    TEXT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT;
    DECLARE @Message NVARCHAR(4000);
    DECLARE @InicieTransaccion BIT = 0;
    DECLARE @now DATETIME = GETDATE();
    DECLARE @proposalid INT;
    DECLARE @current_version INT;
    DECLARE @Status_Borrador INT = 1;
    DECLARE @Status_Modificacion INT = 5;
    
    -- Parametros para el log de errores
    DECLARE @log_typeid INT;
    DECLARE @log_sourceid INT;
    DECLARE @log_severityid INT;

	SELECT @log_severityid = log_severityid FROM vpv_log_severity WHERE name = 'Error';
    SELECT @log_sourceid = log_sourceid FROM vpv_log_source WHERE name = 'Procedimiento sp_crear_actualizar_propuesta';
    SELECT @log_typeid = log_typeid FROM vpv_log_type WHERE name = 'Error SQL';

    IF @@TRANCOUNT = 0
    BEGIN
        SET @InicieTransaccion = 1;
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        BEGIN TRANSACTION;
    END

    BEGIN TRY
        -- Validar permisos solo si hay entidad
        IF @entityid IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM vpv_entity_representative
                WHERE entity_id = @entityid
                  AND user_id = @userid
                  AND end_date > @now
            )
            BEGIN
                SET @Message = 'El usuario no tiene permisos para esta entidad.';
                
                INSERT INTO vpv_logs (
                    description, posttime, computer, trace,
                    reference_id1, reference_id2, value1, value2,
                    checksum, log_typeid, log_sourceid, log_severityid
                )
                VALUES (
                    @Message, GETDATE(), HOST_NAME(), 'sp_crear_actualizar_propuesta',
                    @entityid, @userid, NULL, NULL,
                    HASHBYTES('SHA1', @Message), @log_typeid, @log_sourceid, @log_severityid
                );
                
                RAISERROR(@Message, 16, 1);
                RETURN;
            END
        END

        -- Verificar si ya existe una propuesta con ese nombre
        SELECT @proposalid = proposalid, @current_version = current_version
        FROM vpv_proposal
        WHERE name = @name AND userid = @userid AND 
              (
                (entityid IS NULL AND @entityid IS NULL) OR
                (entityid = @entityid)
              );

        IF @proposalid IS NULL
        BEGIN
            -- Nueva propuesta
            INSERT INTO vpv_proposal (
                name, enabled, current_version, description, submission_date,
                version, origin_typeid, userid, statusid, proposal_typeid, entityid
            )
            VALUES (
                @name, 1, 1, @description, @now,
                1, @origin_typeid, @userid, @Status_Borrador,
                @proposal_typeid, @entityid
            );

            SET @proposalid = SCOPE_IDENTITY();
            SET @current_version = 1;
        END
        ELSE
        BEGIN
            -- Actualizacion
            UPDATE vpv_proposal
            SET
                description = @description,
                origin_typeid = @origin_typeid,
                proposal_typeid = @proposal_typeid,
                submission_date = @now,
                current_version = current_version + 1,
                statusid = @Status_Modificacion
            WHERE proposalid = @proposalid;

            SET @current_version = @current_version + 1;

            -- Limpiar versiones ligadas
            DELETE pv
            FROM vpv_proposal_versions pv
            JOIN vpv_proposal_documents pd ON pv.proposal_documentid = pd.proposal_documentid
            WHERE pd.proposalid = @proposalid;

            DELETE FROM vpv_proposal_documents WHERE proposalid = @proposalid;
        END

        -- Tabla temporal para los documentos digitales
        CREATE TABLE #documentMap (
            name NVARCHAR(100),
            url NVARCHAR(255),
            hash NVARCHAR(255),
            metadata NVARCHAR(MAX),
            validation_date DATETIME,
            requestid INT,
            document_typeid INT,
            is_required BIT
        );

        -- Parsear JSON de documentos
        INSERT INTO #documentMap (name, url, hash, metadata, validation_date, requestid, document_typeid, is_required)
        SELECT 
            name,
            url,
            hash,
            metadata,
            validation_date,
            requestid,
            document_typeid,
            is_required
        FROM OPENJSON(@documents)
        WITH (
            name NVARCHAR(100) '$.name',
            url NVARCHAR(255) '$.url',
            hash NVARCHAR(255) '$.hash',
            metadata NVARCHAR(MAX) '$.metadata',
            validation_date DATETIME '$.validation_date',
            requestid INT '$.requestid',
            document_typeid INT '$.document_typeid',
            is_required BIT '$.is_required'
        );

        -- Tabla temporal para capturar documentos insertados
        DECLARE @newDoc TABLE (
            documentid INT,
            is_required BIT
        );

        -- Insertar documentos nuevos
        INSERT INTO vpv_digital_documents (name, url, hash, metadata, validation_date, requestid, document_typeid)
        SELECT 
            dm.name,
            dm.url,
            dm.hash,
            dm.metadata,
            NULL,
            NULL,
            dm.document_typeid
        FROM #documentMap dm
        WHERE NOT EXISTS (
            SELECT 1 FROM vpv_digital_documents dd WHERE CONVERT(NVARCHAR(MAX), dd.url) = dm.url
        );

        -- Tabla temporal con los nuevos ids de los documentos añadidos
        INSERT INTO @newDoc (documentid, is_required)
        SELECT dd.documentid, dm.is_required
        FROM #documentMap dm
        JOIN vpv_digital_documents dd ON CONVERT(NVARCHAR(255), dd.url) = dm.url;

        -- Relacionar propuesta al documento nuevo
        INSERT INTO vpv_proposal_documents (proposalid, documentid, is_required)
        SELECT @proposalid, nd.documentid, nd.is_required
        FROM @newDoc nd;

        -- Insertar version
        INSERT INTO vpv_proposal_versions (
            version, changes_description, created_at, approved, proposal_documentid
        )
        SELECT 
            @current_version,
            ISNULL(@version_comment, 'Actualizaci�n autom�tica'),
            @now,
            0,
            pd.proposal_documentid
        FROM vpv_proposal_documents pd
        WHERE pd.proposalid = @proposalid;

        IF @InicieTransaccion = 1
        BEGIN
            COMMIT;
            SELECT '�xito' AS resultado, @proposalid AS proposalid, @current_version AS version;
        END
    END TRY
    BEGIN CATCH
		SET @ErrorNumber = ERROR_NUMBER();
		SET @ErrorSeverity = ERROR_SEVERITY();
		SET @ErrorState = ERROR_STATE();
		SET @Message = 'Error en sp_crear_actualizar_propuesta: ' + 
					  'L�nea ' + CAST(ERROR_LINE() AS VARCHAR) + ' | ' + 
					  ERROR_MESSAGE();

		IF LEN(@Message) > 200
			SET @Message = LEFT(@Message, 200);

		IF @InicieTransaccion = 1
			ROLLBACK;

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

		RAISERROR('%s', 16, 1, @Message);
	END CATCH
    
    IF OBJECT_ID('tempdb..#documentMap') IS NOT NULL
        DROP TABLE #documentMap;
END
GO
-----------------------------------------------------------
-- Autor: Daniel Monterrosa
-- Fecha: 16/6/2025
-- Descripcion: Recibe los datos del formulario para crear o actualizar la propuesta
-- Otros parámetros: documents recibe todos los datos de los documentos, target_population solo recibe los ids de las poblaciones meta
-----------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[sp_crear_actualizar_propuesta]
    @name               VARCHAR(100),
    @description        VARCHAR(255),
    @origin_typeid      INT,
    @userid             INT,
    @proposal_typeid    INT,
    @entityid           INT = NULL,
    @allows_comments    BIT,
    @documents          NVARCHAR(MAX), -- JSON
    @target_population  NVARCHAR(MAX), -- JSON: [{ "demographicid": 3 }, ...]
    @version_comment    TEXT = NULL
AS
BEGIN
    SET NOCOUNT ON;

	-- Variables generales de control
    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT;
    DECLARE @Message NVARCHAR(4000);
    DECLARE @InicieTransaccion BIT = 0;
    DECLARE @now DATETIME = GETDATE();
    DECLARE @proposalid INT;
    DECLARE @current_version INT;
    DECLARE @Status_Borrador INT = 1;
    DECLARE @Status_Modificacion INT = 5;

    -- Carga de IDs necesarios para logs de errores
    DECLARE @log_typeid INT, @log_sourceid INT, @log_severityid INT;
    SELECT @log_severityid = log_severityid FROM vpv_log_severity WHERE name = 'Error';
    SELECT @log_sourceid = log_sourceid FROM vpv_log_source WHERE name = 'Procedimiento sp_crear_actualizar_propuesta';
    SELECT @log_typeid = log_typeid FROM vpv_log_type WHERE name = 'Error SQL';

	-- Iniciar transacción solo si no hay una activa
    IF @@TRANCOUNT = 0
    BEGIN
        SET @InicieTransaccion = 1;
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        BEGIN TRANSACTION;
    END

    BEGIN TRY
        -- Validar si el usuario tiene permisos de creación (rol con PROP_CREATE)
        IF NOT EXISTS (
            SELECT 1
            FROM vpv_user_roles ur
            JOIN vpv_rolepermissions rp ON rp.roleid = ur.roleid AND rp.enable = 1 AND rp.deleted = 0
            JOIN vpv_permissions p ON p.permissionid = rp.permissionid
            WHERE ur.userid = @userid AND ur.enabled = 1
              AND p.permissioncode = 'PROP_CREATE'
        )
        BEGIN
            SET @Message = 'El usuario no tiene permisos para crear propuestas.';
			-- Registrar en logs y cortar ejecución
            INSERT INTO vpv_logs (
                description, posttime, computer, trace,
                reference_id1, reference_id2, value1, value2,
                checksum, log_typeid, log_sourceid, log_severityid
            )
            VALUES (
                @Message, GETDATE(), HOST_NAME(), 'sp_crear_actualizar_propuesta',
                NULL, @userid, NULL, NULL,
                HASHBYTES('SHA1', @Message), @log_typeid, @log_sourceid, @log_severityid
            );
            RAISERROR(@Message, 16, 1);
            RETURN;
        END

        -- Validar que el usuario sea representante de la entidad (si aplica)
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

        -- Verificar si ya existe la propuesta
        SELECT @proposalid = proposalid, @current_version = current_version
        FROM vpv_proposal
        WHERE name = @name AND userid = @userid AND 
              (
                (entityid IS NULL AND @entityid IS NULL) OR
                (entityid = @entityid)
              );
		
		-- Crear nueva propuesta si no existe
        IF @proposalid IS NULL
        BEGIN
            INSERT INTO vpv_proposal (
                name, enabled, current_version, description, submission_date,
                version, origin_typeid, userid, statusid, proposal_typeid, entityid, allows_comments
            )
            VALUES (
                @name, 1, 1, @description, @now,
                1, @origin_typeid, @userid, @Status_Borrador,
                @proposal_typeid, @entityid, @allows_comments
            );
            SET @proposalid = SCOPE_IDENTITY();
            SET @current_version = 1;
        END
        ELSE
        BEGIN
			-- Actualizar propuesta existente
            UPDATE vpv_proposal
            SET description = @description,
                origin_typeid = @origin_typeid,
                proposal_typeid = @proposal_typeid,
                submission_date = @now,
                current_version = current_version + 1,
                statusid = @Status_Modificacion,
                allows_comments = @allows_comments
            WHERE proposalid = @proposalid;

            SET @current_version = @current_version + 1;
        END

        -- Mapear los documentos recibidos (JSON) en una tabla temporal
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

        INSERT INTO #documentMap (name, url, hash, metadata, validation_date, requestid, document_typeid, is_required)
        SELECT 
            name, url, hash, metadata, validation_date, requestid, document_typeid, is_required
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

        DECLARE @newDoc TABLE (
            documentid INT,
            is_required BIT
        );

        -- Insertar documentos si no existen aún en la base
        INSERT INTO vpv_digital_documents (name, url, hash, metadata, validation_date, requestid, document_typeid)
        SELECT dm.name, dm.url, dm.hash, dm.metadata, NULL, NULL, dm.document_typeid
        FROM #documentMap dm
        WHERE NOT EXISTS (
            SELECT 1 FROM vpv_digital_documents dd WHERE CONVERT(NVARCHAR(255), dd.url) = dm.url
        );

        -- Asociar los documentos a la propuesta en vpv_proposal_documents
        INSERT INTO @newDoc (documentid, is_required)
        SELECT dd.documentid, dm.is_required
        FROM #documentMap dm
        JOIN vpv_digital_documents dd ON CONVERT(NVARCHAR(255), dd.url) = dm.url;

        INSERT INTO vpv_proposal_documents (proposalid, documentid, is_required)
        SELECT @proposalid, nd.documentid, nd.is_required
        FROM @newDoc nd;

        -- Crear nueva versión de la propuesta
        DECLARE @version_table TABLE (versionid INT);
        INSERT INTO vpv_proposal_versions (
            version, changes_description, created_at, approved, proposal_documentid
        )
        OUTPUT INSERTED.versionid INTO @version_table(versionid)
        SELECT @current_version, ISNULL(@version_comment, 'Auto'), @now, 0, pd.proposal_documentid
        FROM vpv_proposal_documents pd WHERE pd.proposalid = @proposalid;

        -- Calcular hash (checksum) de los documentos para validar integridad
        DECLARE @checksum VARBINARY(64);
        SELECT @checksum = HASHBYTES('SHA1', 
            STRING_AGG(CONVERT(NVARCHAR(MAX), CONCAT_WS('|', name, url, hash)), '')
        )
        FROM #documentMap;

        UPDATE vpv_proposal_versions
        SET checksum = @checksum
        WHERE versionid IN (SELECT versionid FROM @version_table);

        -- Insertar población meta desde el JSON recibido
        IF @target_population IS NOT NULL
        BEGIN
            DELETE FROM vpv_proposal_target WHERE proposalid = @proposalid;

            INSERT INTO vpv_proposal_target (proposalid, demographicid, assigned_by)
            SELECT @proposalid, demographicid, @userid
            FROM OPENJSON(@target_population)
            WITH (demographicid INT '$.demographicid');
        END

		-- Cierre exitoso de transacción
        IF @InicieTransaccion = 1
        BEGIN
            COMMIT;
            SELECT 'Éxito' AS resultado, @proposalid AS proposalid, @current_version AS version;
        END
    END TRY
    BEGIN CATCH
		-- Manejo de errores, rollback y logs
        SET @ErrorNumber = ERROR_NUMBER();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @Message = 'Error en sp_crear_actualizar_propuesta: Línea ' + CAST(ERROR_LINE() AS VARCHAR) + ' | ' + ERROR_MESSAGE();

        IF LEN(@Message) > 200
            SET @Message = LEFT(@Message, 200);

        IF @InicieTransaccion = 1
            ROLLBACK;

        INSERT INTO vpv_logs (
            description, posttime, computer, trace,
            reference_id1, reference_id2, value1, value2,
            checksum, log_typeid, log_sourceid, log_severityid
        )
        VALUES (
            @Message, GETDATE(), HOST_NAME(), ERROR_PROCEDURE(),
            @proposalid, @userid, CAST(@ErrorNumber AS VARCHAR), CAST(@ErrorState AS VARCHAR),
            HASHBYTES('SHA1', @Message), @log_typeid, @log_sourceid, @log_severityid
        );

        RAISERROR('%s', 16, 1, @Message);
    END CATCH

	-- Limpieza final de recursos temporales
    IF OBJECT_ID('tempdb..#documentMap') IS NOT NULL
        DROP TABLE #documentMap;
END
GO

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

    IF @@TRANCOUNT = 0
    BEGIN
        SET @InicieTransaccion = 1;
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        BEGIN TRANSACTION;
    END

    BEGIN TRY
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
                RAISERROR('El usuario no tiene permisos para esta entidad.', 16, 1);
                RETURN;
            END
        END

        SELECT @proposalid = proposalid, @current_version = current_version
        FROM vpv_proposal
        WHERE name = @name AND userid = @userid AND 
              (
                (entityid IS NULL AND @entityid IS NULL) OR
                (entityid = @entityid)
              );

        IF @proposalid IS NULL
        BEGIN
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

            DELETE pv
            FROM vpv_proposal_versions pv
            JOIN vpv_proposal_documents pd ON pv.proposal_documentid = pd.proposal_documentid
            WHERE pd.proposalid = @proposalid;

            DELETE FROM vpv_proposal_documents WHERE proposalid = @proposalid;
        END

        -- Tabla temporal para documentos
        CREATE TABLE #documentMap (
            documentid INT,
            name NVARCHAR(100),
            url NVARCHAR(255),
            hash VARBINARY(255),
            metadata NVARCHAR(MAX),
            validation_date DATETIME,
            requestid INT,
            document_typeid INT,
            is_required BIT
        );

        INSERT INTO #documentMap (
            name, url, hash, metadata, validation_date, requestid, document_typeid, is_required
        )
        SELECT 
            name,
            url,
            CONVERT(VARBINARY(255), hash),
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

        -- Insertar en vpv_digital_documents y capturar IDs insertados
        DECLARE @newDoc TABLE (documentid INT, is_required BIT);

        INSERT INTO vpv_digital_documents (
            name, url, hash, metadata, validation_date, requestid, document_typeid
        )
        OUTPUT 
            INSERTED.documentid, dm.is_required
        INTO @newDoc (documentid, is_required)
        SELECT name, url, hash, metadata, validation_date, requestid, document_typeid
        FROM #documentMap dm;

        -- Insertar relaciones
        INSERT INTO vpv_proposal_documents (proposalid, documentid, is_required)
        SELECT @proposalid, documentid, is_required FROM @newDoc;

        -- Insertar versiones
        INSERT INTO vpv_proposal_versions (
            version, changes_description, created_at, approved, proposal_documentid
        )
        SELECT 
            @current_version,
            ISNULL(@version_comment, 'Actualización automática'),
            @now,
            0,
            pd.proposal_documentid
        FROM vpv_proposal_documents pd
        WHERE pd.proposalid = @proposalid;

        IF @InicieTransaccion = 1
        BEGIN
            COMMIT;
            SELECT 'Éxito' AS resultado, @proposalid AS proposalid, @current_version AS version;
        END
    END TRY
    BEGIN CATCH
        IF @InicieTransaccion = 1
            ROLLBACK;

        SET @ErrorNumber = ERROR_NUMBER();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @Message = ERROR_MESSAGE();

        RAISERROR('%s (Error %d)', @ErrorSeverity, @ErrorState, @Message, @ErrorNumber);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_crear_actualizar_propuesta]
    @name               VARCHAR(100),
    @description        VARCHAR(255),
    @origin_typeid      INT,
    @userid             INT,
    @proposal_typeid    INT,
    @entityid           INT = NULL,
    @documents          NVARCHAR(MAX), -- JSON con { documentid, is_required }
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
    DECLARE @Status_Revision INT = 2;

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
                RAISERROR('El usuario no tiene permisos para esta entidad.', 16, 1);
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
            -- Crear nueva propuesta
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
            -- Actualizar propuesta existente
            UPDATE vpv_proposal
            SET
                description = @description,
                origin_typeid = @origin_typeid,
                proposal_typeid = @proposal_typeid,
                submission_date = @now,
                current_version = current_version + 1,
                statusid = @Status_Revision -- Propuesta en revisi�n
            WHERE proposalid = @proposalid;

            SET @current_version = @current_version + 1;

            -- Eliminar documentos antiguos (si los hay)
			DELETE pv
			FROM vpv_proposal_versions pv
			JOIN vpv_proposal_documents pd ON pv.proposal_documentid = pd.proposal_documentid
			WHERE pd.proposalid = @proposalid;

            DELETE FROM vpv_proposal_documents WHERE proposalid = @proposalid;
        END

        -- Insertar documentos (usando OPENJSON, sin cursor)
        INSERT INTO vpv_proposal_documents (proposalid, documentid, is_required)
        SELECT @proposalid, doc.documentid, doc.is_required
        FROM OPENJSON(@documents)
        WITH (
            documentid INT '$.documentid',
            is_required BIT '$.is_required'
        ) AS doc;

        -- Insertar versi�n
        INSERT INTO vpv_proposal_versions (
            version, changes_description, created_at, approved, proposal_documentid --, checksum
        )
        SELECT 
            @current_version,
            ISNULL(@version_comment, 'Actualizaci�n autom�tica'),
            @now,
            0,
            pd.proposal_documentid
            -- , @hash
        FROM vpv_proposal_documents pd
        WHERE pd.proposalid = @proposalid;

        IF @InicieTransaccion = 1
        BEGIN
			SELECT '�xito' AS resultado, @proposalid AS proposalid, @current_version AS version;

            COMMIT;
        END
    END TRY
    BEGIN CATCH
        IF @InicieTransaccion = 1
            ROLLBACK;

        SET @ErrorNumber = ERROR_NUMBER();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @Message = ERROR_MESSAGE();

        DECLARE @formattedMessage NVARCHAR(4000) = @Message + ' (Error ' + CAST(@ErrorNumber AS VARCHAR) + ')';
        RAISERROR(@formattedMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
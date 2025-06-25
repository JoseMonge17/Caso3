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

    IF @@TRANCOUNT = 0
    BEGIN
        SET @InicieTransaccion = 1;
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        BEGIN TRANSACTION;
    END

    BEGIN TRY
        -- Simular ejecución de workflows por cada documento relacionado a la propuesta
        DECLARE @documentid INT, @workflowid INT;

        DECLARE cur CURSOR FOR
        SELECT dd.documentid, dw.workflowid
        FROM vpv_proposal_documents pd
        JOIN vpv_digital_documents dd ON dd.documentid = pd.documentid
        JOIN vpv_document_workflows dw ON dw.documentid = dd.documentid
        WHERE pd.proposalid = @proposalid;

        OPEN cur;
        FETCH NEXT FROM cur INTO @documentid, @workflowid;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Insertar la solicitud de validación
            DECLARE @requestid INT;
            INSERT INTO vpv_validation_request (creation_date, userid, validation_typeid)
            VALUES (@now, @userid, 1); -- 1 es un placeholder
            SET @requestid = SCOPE_IDENTITY();

            -- Simular delay de procesamiento de 1 segundo
            WAITFOR DELAY '00:00:01';

            -- Insertar el log de la ejecución del workflow
            INSERT INTO vpv_validation_workflow (
                workflowid, execution_date, status, parameters
            ) VALUES (
                @workflowid, @now, 'Ejecutado', '{"resultado": "exito"}'
            );

            -- Actualizar solicitud de validación con resultado exitoso
            UPDATE vpv_validation_request
            SET finish_date = @now, global_result = 'Exito'
            WHERE requestid = @requestid;

            FETCH NEXT FROM cur INTO @documentid, @workflowid;
        END

        CLOSE cur;
        DEALLOCATE cur;

        -- Cambiar estado de la propuesta a 'Aprobada' (statusid = 3)
        UPDATE vpv_proposal
        SET statusid = 3
        WHERE proposalid = @proposalid;

        IF @InicieTransaccion = 1
        BEGIN
            COMMIT;
            SELECT 'Propuesta aprobada exitosamente' AS resultado;
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

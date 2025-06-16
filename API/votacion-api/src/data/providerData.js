const { executeSP, sql } = require('../db/config');

async function fetchProvidersFromSP(params) {
  return executeSP('SP_InsertCountry', 
  {
    name: params.name,
    codeISO: params.codeISO,
    enable: params.enable
  },
  {
    name: sql.NVarChar(60),
    codeISO: sql.NVarChar(3),
    enable: sql.Bit
  });
}

module.exports = { fetchProvidersFromSP };


/*

ALTER PROCEDURE [dbo].[SP_InsertCountry]
    @name NVARCHAR(60),
    @codeISO NVARCHAR(3),
    @enable BIT
AS 
BEGIN
    SET NOCOUNT ON
    
    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
    DECLARE @Message VARCHAR(200)
    DECLARE @InicieTransaccion BIT
    
    SET @InicieTransaccion = 0
    IF @@TRANCOUNT=0 BEGIN
        SET @InicieTransaccion = 1
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED
        BEGIN TRANSACTION        
    END
    
    BEGIN TRY
        SET @CustomError = 2001

        -- Operación principal (INSERT)
        INSERT INTO vpv_countries (
            name,
            codeISO,
            register_enable
        ) VALUES (
            @name,
            @codeISO,
            @enable
        );
                    
        IF @InicieTransaccion=1 BEGIN
            COMMIT
        END
        
        -- Retornar el ID generado
        SELECT SCOPE_IDENTITY() AS countryid;
    END TRY
    BEGIN CATCH
        SET @ErrorNumber = ERROR_NUMBER()
        SET @ErrorSeverity = ERROR_SEVERITY()
        SET @ErrorState = ERROR_STATE()
        SET @Message = ERROR_MESSAGE()
        
        IF @InicieTransaccion=1 BEGIN
            ROLLBACK
        END
        
        -- Registrar error y devolver mensaje "amigable"
        INSERT INTO ErrorLogs(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorMessage)
        VALUES (@ErrorNumber, @ErrorSeverity, @ErrorState, 'SP_InsertCountry', @Message)
        
        RAISERROR('No se pudo registrar el país. Por favor intente nuevamente', 16, 1)
    END CATCH
    
    RETURN 0
END
GO

*/
-- Insertar para usuarios 6-10
-- Versión simplificada que no requiere conocer los métodos por adelantado
DECLARE @UserId INT = 6;

WHILE @UserId <= 10
BEGIN
    INSERT INTO vpv_available_pay_methods (name, token, exp_token, mask_account, idMethod, userid)
    SELECT 
        name,
        token + '_u' + CAST(@UserId AS VARCHAR),
        DATEADD(MONTH, 6, GETDATE()),
        mask_account,
        idMethod,
        @UserId
    FROM vpv_available_pay_methods
    WHERE userid = 1;
    
    SET @UserId = @UserId + 1;
END;
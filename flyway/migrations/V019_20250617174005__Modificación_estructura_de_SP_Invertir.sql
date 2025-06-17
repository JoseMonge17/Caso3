ALTER PROCEDURE [dbo].[SP_CF_ProcesarInversion]
    @proposalid INT,
    @userid INT,
    @monto FLOAT,
    @codigoPago VARCHAR(100),
    @numeroreferencia VARCHAR(100),
    @token VARCHAR(200),
    @metodoPagoId INT
AS 
BEGIN
    SET NOCOUNT ON
    
    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
    DECLARE @Message VARCHAR(200)
    DECLARE @InicieTransaccion BIT
    
    -- Variables para cálculos
    DECLARE @montoDecimal DECIMAL(12,2) = CAST(@monto AS DECIMAL(12,2))
    DECLARE @tokenBin VARBINARY(200) = CAST(@token AS VARBINARY(200));
    DECLARE @equity DECIMAL(5,2)
    DECLARE @projectid INT
    DECLARE @totalActual DECIMAL(12,2)
    DECLARE @maxFunding DECIMAL(12,2)
    DECLARE @userExists BIT = 0
    DECLARE @enoughFounds BIT = 0
    DECLARE @portfolioid INT;
    DECLARE @paymentid INT;
    DECLARE @investmentid INT;
    DECLARE @equityOffered DECIMAL(5,2)
    DECLARE @equityAssigned DECIMAL(5,2)
	DECLARE @maxPermitido DECIMAL(12,2)
	DECLARE @equityAvailable DECIMAL(5,2)
    -- Variables para IDs de soporte del log
    DECLARE @log_severityid INT, @log_sourceid INT, @log_typeid INT;
    
    -- Obtener datos del proyecto (sin bloquear)
    SELECT 
        @projectid = projectid,
        @totalActual = total_invested,
        @maxFunding = max_funding_target,
        @equityOffered = equity_offered
    FROM cf_projects
    WHERE proposalid = @proposalid

    -- Validar existencia del usuario (antes de iniciar transacción)
    SELECT @userExists = 1 
    FROM vpv_users 
    WHERE userid = @userid AND statusid = 1 -- Status 1 = Activo

    -- Validar fondos suficientes del usuario
    SELECT @enoughFounds = CASE 
                            WHEN available_balance >= @montoDecimal THEN 1 
                            ELSE 0 
                        END
    FROM cf_investment_portfolios
    WHERE userid = @userid;

    -- Calcular equity (monto_invertido / valor_total_proyecto) * porcentaje_equity_disponible
    SET @equity = (@montoDecimal / (SELECT budget FROM cf_projects WHERE projectid = @projectid)) * @equityOffered
    
    -- Validar equity disponible
    SET @equityAssigned = (
        SELECT SUM(equity_obtained) 
        FROM cf_investments 
        WHERE projectid = @projectid
    )

    SELECT @log_severityid = log_severityid FROM vpv_log_severity WHERE name = 'Error';
    SELECT @log_sourceid = log_sourceid FROM vpv_log_source WHERE name = 'Procedimiento SP_CF_ProcesarInversion';
    SELECT @log_typeid = log_typeid FROM vpv_log_type WHERE name = 'Error SQL';
    
    BEGIN TRY
        SET @CustomError = 2001
        
        -- 1. Validar usuario (nueva validación)
        IF @userExists = 0
            RAISERROR('Usuario no existe o no está activo', 16, 1)
        
		-- 2. Validar existencia del proyecto por proposalid
		IF NOT EXISTS (
			SELECT 1
			FROM cf_projects
			WHERE proposalid = @proposalid
		)
			RAISERROR('No existe un proyecto asociado a esta propuesta.', 16, 1);

        -- 3. Validar estado del proyecto
        IF NOT EXISTS (
            SELECT 1 FROM cf_projects p
            JOIN cf_status_types st ON p.statusid = st.statusid
            WHERE p.projectid = @projectid
            AND st.module = 'crowdfunding'
            AND st.name IN ('Aprobado', 'En Recaudación')
        )
            RAISERROR('El proyecto no está en estado válido para inversión', 16, 1)
        
        -- 4. Validar fondos del usuario para procesar la inversión
        IF @enoughFounds = 0
            RAISERROR('Fondos insuficientes en el portafolio para realizar la inversión.', 16, 1);

        -- 5. Validar que el monto no exceda el máximo de financiamiento
        IF (@totalActual + @montoDecimal) > @maxFunding
        BEGIN
            SET @maxPermitido  = @maxFunding - @totalActual;
            RAISERROR('El monto excede el límite de financiamiento.', 16, 1);
        END
        
        -- 6 Vlidar no exceder la cantidad de equity ofrecido
        IF @equityAssigned IS NOT NULL AND (@equityAssigned + @equity) > @equityOffered
        BEGIN
            SET @equityAvailable = @equityOffered - @equityAssigned;
            RAISERROR('No hay suficiente equity disponible.', 16, 1);
        END

        SET @InicieTransaccion = 0
        IF @@TRANCOUNT=0 BEGIN
            SET @InicieTransaccion = 1
            SET TRANSACTION ISOLATION LEVEL READ COMMITTED
            BEGIN TRANSACTION        
        END

        -- 7. Registrar pago
        INSERT INTO vpv_payments (
            amount, taxamount, discountporcent, realamount,
            result, authcode, referencenumber, chargetoken,
            [date], [checksum],statusid, paymentmethodid, availablemethodid
        ) VALUES (
            @montoDecimal, 0, 0, @montoDecimal,
            'APPROVED', @codigoPago, @numeroreferencia, @tokenBin,
            GETDATE(), HASHBYTES('SHA1', @numeroreferencia),1 , @metodoPagoId, 1
        );
        SET @paymentid = SCOPE_IDENTITY();

        -- 8. Registrar inversión
        INSERT INTO cf_investments (
            amount, investmentdate, equity_obtained,
            statusid, investment_hash, projectid,
            paymentid, userid
        ) VALUES (
            @montoDecimal, GETDATE(), @equity,
            8, -- Status: Completado
            @tokenBin, 
            @projectid,
            @paymentid, @userid
        );
        SET @investmentid = SCOPE_IDENTITY();

        -- 8. Actualizar el total invertido en el proyecto
        UPDATE cf_projects
        SET total_invested = total_invested + @montoDecimal
        WHERE projectid = @projectid;
        
        -- 9. Obtener el portafolio del inversionista
        SELECT @portfolioid = portfolioid 
        FROM cf_investment_portfolios 
        WHERE userid = @userid;

        --- 10. Registrar movimiento financiero
        INSERT INTO cf_financial_movements (
            reference_code, 
            movement_typeid, 
            amount,
            statusid, 
            execution_date, 
            registered_date,
            description, 
            investmentid,
            source_portfolioid,
            destination_portfolioid,
            paymentid
        ) VALUES (
            @numeroreferencia,
            (SELECT movementid FROM cf_movement_types WHERE name = 'Inversión'), 
            @montoDecimal,
            (SELECT statusid FROM cf_status_types WHERE name = 'Completado'),
            GETDATE(), 
            GETDATE(),
            'Inversión en proyecto ID: ' + CAST(@projectid AS VARCHAR(10)) + 
            ' - ' + (SELECT name FROM cf_projects WHERE projectid = @projectid),
            @investmentid,
            @portfolioid, -- Fondos salen del portafolio personal
            NULL, -- No hay portafolio destino (va al proyecto)
            @paymentid
        );

        -- 11. Actualizar el balance del portafolio del inversionista
        UPDATE cf_investment_portfolios
        SET 
            available_balance = available_balance - @montoDecimal,
            invested_balance = invested_balance + @montoDecimal,
            last_update = GETDATE()
        WHERE portfolioid = @portfolioid;
        
        IF @InicieTransaccion=1 BEGIN
            COMMIT
        END
        
        -- Retornar resultado
        SELECT 
            @investmentid AS investmentid,
            @equity AS equityPercentage,
            @totalActual + @montoDecimal AS newTotalInvested
    END TRY
    BEGIN CATCH
        SET @ErrorNumber = ERROR_NUMBER()
        SET @ErrorSeverity = ERROR_SEVERITY()
        SET @ErrorState = ERROR_STATE()
        SET @Message = ERROR_MESSAGE()
        
        IF @InicieTransaccion=1 BEGIN
            ROLLBACK
        END
        
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
            'Error en SP_CF_ProcesarInversion',
            GETDATE(),
            HOST_NAME(), -- O SYSTEM_USER si se desea el usuario
            @Message,
            @proposalid,         -- referencia 1
            @userid,             -- referencia 2
            CAST(@ErrorNumber AS VARCHAR),
            CAST(@ErrorState AS VARCHAR),
            HASHBYTES('SHA1', @Message), -- checksum simplificado
            @log_typeid,
            @log_sourceid,
            @log_severityid
        );
        
        -- Error "amigable" para la API
        RAISERROR('No se pudo completar la inversión. Error: %s', 16, 1, @Message);
    END CATCH
END





/*
{
  "proposalid": 123,
  "monto": 1500.00,
  "codigoPago": "PAY-789XYZ",
  "numeroreferencia": "REF987654"
  "token": "aqwijdhaliuowdhakjdnaliowudhadijaw"
  "metodoPagoId": 1
}

*/

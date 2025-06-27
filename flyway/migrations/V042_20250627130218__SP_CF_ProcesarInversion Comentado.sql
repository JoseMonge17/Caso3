ALTER PROCEDURE [dbo].[SP_CF_ProcesarInversion]
    /* Parámetros de entrada */
    @proposalid INT,
    @userid INT,
    @monto FLOAT,
    @codigoPago VARCHAR(100),
    @token VARCHAR(200),
    @metodoPagoId INT
AS 
BEGIN
    SET NOCOUNT ON
    -- Variables para manejo de errores
    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
    DECLARE @Message VARCHAR(200)
    DECLARE @InicieTransaccion BIT

    -- Variables de datos del proyecto
    DECLARE @montoDecimal DECIMAL(12,2) = CAST(@monto AS DECIMAL(12,2)) -- Monto convertido a formato monetario
    DECLARE @tokenBin VARBINARY(200) = CAST(@token AS VARBINARY(200)); -- Token de pago en formato binario
    DECLARE @equity DECIMAL(5,2) -- Porcentaje de equity obtenido
    DECLARE @projectid INT -- ID del proyecto relacionado
    DECLARE @totalActual DECIMAL(12,2) -- Total ya invertido
    DECLARE @maxFunding DECIMAL(12,2) -- Límite de financiamiento
    DECLARE @equityOffered DECIMAL(5,2) -- % de equity ofrecido
    DECLARE @ProjectName VARCHAR(100) -- Nombre del proyecto

    -- Variables de control
    DECLARE @userExists BIT -- ¿Existe el usuario?
    DECLARE @enoughFounds BIT -- ¿Tiene fondos suficientes?
    DECLARE @portfolioid INT -- ID del portafolio del inversor
    DECLARE @paymentid INT -- ID del pago registrado
    DECLARE @investmentid INT -- ID de la inversión
    DECLARE @completedid INT -- ID del estado "Completado"
    DECLARE @Fundid INT -- ID del fondo del proyecto

    -- Variables para validación
    DECLARE @equityAssigned DECIMAL(5,2) -- Equity ya asignado
    DECLARE @maxPermitido DECIMAL(12,2) -- Máximo permitido para no exceder financiamiento
    DECLARE @equityAvailable DECIMAL(5,2) -- Equity disponible

    -- Variables de auditoría
    DECLARE @FechaEjecucion DATETIME = GETDATE() -- Timestamp único para todas las operaciones
    DECLARE @log_severityid INT, @log_sourceid INT, @log_typeid INT -- IDs para logging
    
    -- Obtener datos del proyecto (sin bloquear)
    SELECT 
        @projectid = projectid,
        @totalActual = total_invested,
        @maxFunding = max_funding_target,
        @equityOffered = equity_offered,
        @ProjectName = name
    FROM cf_projects
    WHERE proposalid = @proposalid
    /* Propósito: Recupera información crítica del proyecto antes de iniciar transacción */

    -- Obtener ID del estado "Completado" para usar en registros
    SELECT @completedid = statusid 
    FROM cf_status_types 
    WHERE name = 'Completado'
    /* Propósito: Evitar magic numbers en el código */

    -- Validar existencia del usuario (antes de iniciar transacción)
    SELECT @userExists = 1 
    FROM vpv_users 
    WHERE userid = @userid AND statusid = 1 -- Status 1 = Activo TODO: en lugar de números de id usar variables
    /* Cumple con: "Verificar identidad del usuario y confirmar su registro" */

    -- Obtener el fundid asociado al proyecto
    SELECT @FundID = fundid 
    FROM cf_project_funds 
    WHERE projectid = @projectId;
    /* Propósito: Para actualizar balances de fondos posteriormente */

    -- Validar fondos suficientes del usuario
    SELECT @enoughFounds = CASE 
                            WHEN available_balance >= @montoDecimal THEN 1 
                            ELSE 0 
                        END
    FROM cf_investment_portfolios
    WHERE userid = @userid;
    /* Cumple con: "Validar el pago y confirmar el monto transferido" */

    -- Calcular equity (monto_invertido / valor_total_proyecto) * porcentaje_equity_disponible
    SET @equity = (@montoDecimal / (SELECT budget FROM cf_projects WHERE projectid = @projectid)) * @equityOffered
    /* Cumple con: "Calcular el porcentaje accionario basado en monto y valor total" */

    -- Validar equity disponible
    SET @equityAssigned = (
        SELECT SUM(equity_obtained) 
        FROM cf_investments 
        WHERE projectid = @projectid
    )
    /* Propósito: Evitar sobrepasar el equity ofrecido */

    -- Configurar IDs para sistema de logs
    SELECT @log_severityid = log_severityid FROM vpv_log_severity WHERE name = 'Error';
    SELECT @log_sourceid = log_sourceid FROM vpv_log_source WHERE name = 'Procedimiento SP_CF_ProcesarInversion';
    SELECT @log_typeid = log_typeid FROM vpv_log_type WHERE name = 'Error SQL';
    /* Propósito: Auditoría detallada de errores */

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

        -- Iniciar transacción (DENTRO del try para manejo integrado de errores)
        SET @InicieTransaccion = 0
        IF @@TRANCOUNT=0 BEGIN
            SET @InicieTransaccion = 1
            SET TRANSACTION ISOLATION LEVEL READ COMMITTED
            BEGIN TRANSACTION        
        END
        /* Nota: La transacción comienza aquí para:
            1. Minimizar tiempo de bloqueo
            2. Permitir que validaciones previas fallen sin rollback
        */


        -- 7. Registrar pago
        INSERT INTO vpv_payments (
            amount, 
            taxamount, 
            discountporcent, 
            realamount,
            result, 
            authcode, 
            referencenumber, 
            chargetoken,
            [date], 
            [checksum],
            statusid, 
            paymentmethodid, 
            availablemethodid
        ) VALUES (
            @montoDecimal, 
            0, 
            0, 
            @montoDecimal,
            'APPROVED', 
            @codigoPago, 
            'PAY-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                  LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 8), 
            @tokenBin,
            GETDATE(), 
            HASHBYTES('SHA1', CONCAT(
                @codigoPago, 
                '|', @montoDecimal, 
                '|', FORMAT(GETDATE(), 'yyyyMMddHHmmss')
            )), -- checksum simulado y simplificado
            (SELECT paymentstatusid FROM vpv_paymentstatus WHERE name = 'Completed'), 
            @metodoPagoId, 
            1
        );
        SET @paymentid = SCOPE_IDENTITY();

        -- 7.5. Crear transacción de inversión
        INSERT INTO vpv_transactions (
            name, 
            description, 
            amount, 
            referencenumber, 
            transactiondate, 
            officetime, 
            checksum,
            transactiontypeid, 
            transactionsubtypeid, 
            currencyid,
            payid -- Mismo pago asociado
        )
        VALUES (
            'Inversión al proyecto: ' + @ProjectName, 
            'Inversión al proyecto: ' + @ProjectName + ' con un monto de ' + CAST(@montoDecimal AS VARCHAR),
            @montoDecimal,
            'INV-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                  LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 8),
            @FechaEjecucion,
            @FechaEjecucion,
            HASHBYTES('SHA2_256', CAST(@projectid AS VARCHAR) + CAST(@paymentid AS VARCHAR) + CAST(@montoDecimal AS VARCHAR) + CAST(@FechaEjecucion AS VARCHAR)),
            (SELECT TOP 1 transactiontypeid FROM vpv_transactiontypes WHERE name = 'Inversión' ORDER BY 1),
            (SELECT TOP 1 transactionsubtypeid FROM vpv_transactionsubtypes WHERE name = 'Inversión en equity'  ORDER BY 1),
            (SELECT TOP 1 currencyid FROM vpv_currencies WHERE acronym = 'USD'  ORDER BY 1),
            @paymentid
        );
        /* Propósito: Trazabilidad auditoría financiera */

        -- 8. Registrar inversión
        INSERT INTO cf_investments (
            amount, 
            investmentdate, 
            equity_obtained,
            statusid, 
            investment_hash, 
            projectid,
            paymentid, 
            userid
        ) VALUES (
            @montoDecimal, 
            @FechaEjecucion, 
            @equity,
            @completedid,
            @tokenBin, 
            @projectid,
            @paymentid, 
            @userid
        );
        SET @investmentid = SCOPE_IDENTITY();
        /* Cumple con: "Insertar registro de inversión" */

        -- 8. Actualizar el total invertido en el proyecto
        UPDATE cf_projects
        SET total_invested = total_invested + @montoDecimal
        WHERE projectid = @projectid;
        /* Mantiene consistencia de datos agregados */
        
        -- 9. Actualizar fondos del proyecto
        UPDATE cf_project_funds
        SET 
            total_funds = total_funds + @montoDecimal,
            last_updated = @FechaEjecucion
        WHERE fundid = @FundID;
        /* Actualiza balances financieros */

        -- 10. Obtener el portafolio del inversionista
        SELECT @portfolioid = portfolioid 
        FROM cf_investment_portfolios 
        WHERE userid = @userid
        AND portfoliotype = 1;
        /* Para registrar movimiento financiero */

        --- 11. Registrar movimiento financiero
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
            'INV-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                  LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 8),
            (SELECT movementid FROM cf_movement_types WHERE name = 'Inversión'), 
            @montoDecimal,
            (SELECT statusid FROM cf_status_types WHERE name = 'Completado'),
            GETDATE(), 
            GETDATE(),
            'Inversión en proyecto ID: ' + CAST(@projectid AS VARCHAR(10)) + 
            ' - ' + (SELECT name FROM cf_projects WHERE projectid = @projectid),
            @investmentid,
            @portfolioid, -- Fondos salen del portafolio personal
            @FundID, 
            @paymentid
        );

        -- 12. Actualizar el balance del portafolio del inversionista
        UPDATE cf_investment_portfolios
        SET 
            available_balance = available_balance - @montoDecimal,
            invested_balance = invested_balance + @montoDecimal,
            last_update = GETDATE()
        WHERE portfolioid = @portfolioid;
        /* Actualiza balances del usuario */
        
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
        SET @Message = 'Error en SP_CF_ProcesarInversion: ' + 
                  'Línea ' + CAST(ERROR_LINE() AS VARCHAR) + ' | ' + 
                  ERROR_MESSAGE();
                  -- Mensaje de error para saber en qué linea falló y porqué
        
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
            @Message,
            GETDATE(),
            HOST_NAME(), -- O SYSTEM_USER si se desea el usuario
            ERROR_PROCEDURE(),
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
        RAISERROR('%s', 16, 1, @Message);
    END CATCH
END





/*
{
  "proposalid": 1025,
  "monto": 5000.00,
  "codigoPago": "PMT-USDC-20240625-1025A",
  "token": "ch_tok_26QCj2mJ7bP9H3xV5t8LkE4s",
  "metodoPagoId": 3
}
*/

-----------------------------------------------------------
-- Autor: Carlos Ávalos
-- Fecha: 16/06/2024
-- Descripcion: Distribuye dividendos a inversionistas de un proyecto activo
-- Valida estado del proyecto, fiscalizaciones aprobadas y realiza
-- la distribución proporcional según equity de cada inversionista
-----------------------------------------------------------
ALTER PROCEDURE [dbo].[SP_RepartirDividendos]
    @projectId INT,
    @ReporteGananciasID INT,
    @UsuarioEjecutor INT,
    @PayMethodId INT
AS 
BEGIN
    SET NOCOUNT ON
    
    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
    DECLARE @Message VARCHAR(200)
    DECLARE @InicieTransaccion BIT
    
    -- Variables de proceso
    DECLARE @MontoGanancias DECIMAL(12,2)
    DECLARE @EstadoProyecto INT
    DECLARE @reporteAprobado BIT
    DECLARE @TotalEquity DECIMAL(5,2)
    DECLARE @ComisionesTotales DECIMAL(12,2) = 0
    DECLARE @MontoDistribuir DECIMAL(12,2)
    DECLARE @FechaEjecucion DATETIME = GETDATE()
    DECLARE @ProjectName VARCHAR(100)
    DECLARE @GroupID INT 
    DECLARE @ComisionAmount DECIMAL(12,2)
    DECLARE @PaymentID INT -- Nueva variable para el ID del pago
    DECLARE @TransactionID INT
    DECLARE @FundID INT -- Para trabajar con la nueva estructura
    DECLARE @NombreGrupo VARCHAR(100)            
    DECLARE @GrupoPortfolioId INT
    DECLARE @DistributionID INT
    DECLARE @EstadoActivo VARCHAR(50)
    DECLARE @log_severityid INT, @log_sourceid INT, @log_typeid INT; -- Variables para IDs de soporte del log
    
    -- Variables para montos a inversionistas 
    DECLARE @AgreementID INT, @UserID INT, @Equity DECIMAL(5,2), @MontoInversionista DECIMAL(12,2)
    
    SET @EstadoActivo = 'Activo'

    -- Operaciones preliminares sin transacción
    SELECT @EstadoProyecto = p.statusid, @ProjectName = name 
    FROM cf_projects p
    WHERE p.projectid = @projectId;
    
    -- Obtener el fundid asociado al proyecto
    SELECT @FundID = fundid 
    FROM cf_project_funds 
    WHERE projectid = @projectId;

    -- Crear tabla temporal para comisiones
    CREATE TABLE #ComisionesCalculadas (
        groupid INT NOT NULL,
        amount DECIMAL(12,2) NOT NULL
    );
    
    -- Verificar reporte de ganancias
    SELECT @reporteAprobado = approved
    FROM cf_financial_reports 
    WHERE reportid = @ReporteGananciasID
    AND projectid = @projectId;

    -- Sacar monto de ganancias
    SELECT TOP 1 @MontoGanancias = t.amount, @PaymentID = t.payid 
    FROM vpv_transactions t
    JOIN cf_financial_reports fr ON t.transactionid = fr.transactionid
    WHERE fr.reportid = @ReporteGananciasID
    AND fr.projectid = @projectId;

    -- Verificar que todos los inversionistas tengan métodos de pago válidos
    -- Crear tabla temporal para usuarios sin método de pago
    CREATE TABLE #UsersSinMetodo (
        userid INT,
        nombre VARCHAR(100)
    );

    -- Identificar usuarios sin métodos de pago válidos
    INSERT INTO #UsersSinMetodo (userid, nombre)
    SELECT DISTINCT i.userid, u.username
    FROM cf_investments i
    JOIN vpv_users u ON i.userid = u.userid
    JOIN cf_status_types st ON st.statusid = i.statusid
    WHERE i.projectid = @projectId
    AND st.name = @EstadoActivo
    AND NOT EXISTS (
        SELECT 1 
        FROM vpv_available_pay_methods apm
        WHERE apm.userid = i.userid
        AND apm.idMethod = @PayMethodId  -- Validar contra el método de pago específico
    );

    -- Tablas para el registro en el ciclo de distribución
    CREATE TABLE #TransactionsToRegister (
        transaction_typeid INT,
        related_id INT,
        amount DECIMAL(18,2),
        transactionid INT
    );
    
    -- Calcular total equity para normalizar (por si hay inconsistencias)
    SELECT @TotalEquity = SUM(equity_porcentage)
    FROM cf_investment_agreements ia
    JOIN cf_investments i ON ia.investmentid = i.investmentid
    JOIN cf_status_types st ON st.statusid = ia.statusid
    WHERE i.projectid = @projectId
    AND st.name = @EstadoActivo; 
    --TODO: Cambiar todos los status por select a JOIN 

	SELECT @log_severityid = log_severityid FROM vpv_log_severity WHERE name = 'Error';
    SELECT @log_sourceid = log_sourceid FROM vpv_log_source WHERE name = 'Procedimiento SP_RepartirDividendos';
    SELECT @log_typeid = log_typeid FROM vpv_log_type WHERE name = 'Error SQL';
    
    BEGIN TRY
        SET @CustomError = 2001
        -- VALIDACIONES 
        IF @reporteAprobado IS NULL
        BEGIN
            RAISERROR('El reporte financiero no existe o no pertenece a este proyecto', 16, 1);
            RETURN -1;
        END

        IF @reporteAprobado = 0
        BEGIN
            RAISERROR('El reporte financiero no está aprobado', 16, 1);
            RETURN -1;
        END

        -- Verificar fondos disponibles
        IF EXISTS (
            SELECT 1 FROM cf_project_funds 
            WHERE fundid = @FundID 
            AND available_funds = 0.00
        )
        BEGIN
            SET @Message = 'Fondos insuficientes para distribuir las ganancias reportadas'
            RAISERROR(@Message, 16, 1)
            RETURN -1
        END

        -- Verificar estado del proyecto
        IF @EstadoProyecto <> (SELECT statusid FROM cf_status_types WHERE name = 'En Ejecución')
        BEGIN
            SET @Message = 'El proyecto no está en estado de ejecución'
            RAISERROR(@Message, 16, 1)
            RETURN -1
        END

        -- Verificar fiscalizaciones aprobadas
        IF EXISTS (
            SELECT 1 FROM cf_financial_reports 
            WHERE projectid = @projectId 
            AND approved = 0
            AND reporttypeid IN (SELECT reporttypeid FROM cf_report_types WHERE name IN ('Fiscalización', 'Auditoría')))
        BEGIN
            SET @Message = 'Existen fiscalizaciones pendientes de aprobar'
            RAISERROR(@Message, 16, 1)
            RETURN -1
        END

        -- Si hay usuarios sin métodos, retornar error
        IF EXISTS (SELECT 1 FROM #UsersSinMetodo)
        BEGIN
            -- Construir mensaje de error con la lista de usuarios
            DECLARE @ListaUsuarios VARCHAR(MAX) = '';
            
            SELECT @ListaUsuarios = @ListaUsuarios + nombre + ', '
            FROM #UsersSinMetodo;
            
            SET @ListaUsuarios = LEFT(@ListaUsuarios, LEN(@ListaUsuarios) - 1);
            
            SET @Message = 'Los siguientes inversionistas no tienen métodos de depósito válidos: ' + @ListaUsuarios;
            
            -- Limpiar tabla temporal antes de salir
            DROP TABLE #UsersSinMetodo;
            
            RAISERROR(@Message, 16, 1);
            RETURN -1;
        END

        -- Limpiar tabla temporal si no hubo error
        DROP TABLE #UsersSinMetodo;
        
        SET @InicieTransaccion = 0
        IF @@TRANCOUNT=0 BEGIN
            SET @InicieTransaccion = 1
            SET TRANSACTION ISOLATION LEVEL READ COMMITTED
            BEGIN TRANSACTION        
        END

        -- 1. Calcular comisiones a grupos primero
        INSERT INTO #ComisionesCalculadas
        SELECT 
            fs.groupid,
            CASE 
                WHEN ft.name = 'Porcentaje sobre ganancias' THEN @MontoGanancias * (fs.value/100)
                WHEN ft.name = 'Monto fijo por distribución' THEN fs.value
                ELSE 0
            END AS amount
        FROM cf_project_fee_configurations pfc
        JOIN cf_fee_structures fs ON pfc.structureid = fs.structureid
        JOIN cf_fee_type ft ON fs.fee_typeid = ft.fee_typeid
        JOIN cf_status_types st ON st.statusid = pfc.statusid
        WHERE pfc.projectid = @projectId
        AND st.name = @EstadoActivo
        AND (pfc.end_date IS NULL OR pfc.end_date >= @FechaEjecucion);
        
        SELECT @ComisionesTotales = SUM(amount) FROM #ComisionesCalculadas;
        SET @MontoDistribuir = @MontoGanancias - @ComisionesTotales;

        -- 2. Crear transacción maestra de DISTRIBUCIÓN (salida de fondos del proyecto)
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
            'Distribución Dividendos Proyecto: ' + @ProjectName, 
            'Distribución de ganancias según reporte ' + CAST(@ReporteGananciasID AS VARCHAR),
            @MontoGanancias,
            NEWID(),
            @FechaEjecucion,
            @FechaEjecucion,
            HASHBYTES('SHA2_256', CAST(@projectId AS VARCHAR) + CAST(@PaymentID AS VARCHAR) + CAST(@MontoGanancias AS VARCHAR) + CAST(@FechaEjecucion AS VARCHAR)),
            (SELECT TOP 1 transactiontypeid FROM vpv_transactiontypes WHERE name = 'Dividendo' ORDER BY 1),
            (SELECT TOP 1 transactionsubtypeid FROM vpv_transactionsubtypes WHERE name = 'Distribución Proyecto'  ORDER BY 1),
            (SELECT TOP 1 currencyid FROM vpv_currencies WHERE acronym = 'USD'  ORDER BY 1),
            @PaymentID
        );
        
        SET @TransactionID = SCOPE_IDENTITY();

        -- 3. Registrar movimiento financiero de salida del proyecto
        INSERT INTO cf_financial_movements (
            reference_code, 
            movement_typeid, 
            amount, 
            statusid,
            execution_date, 
            registered_date, 
            description,
            agreementid, 
            source_portfolioid, 
            paymentid
        )
        VALUES (
            'DIV-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                  LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 8),
            (SELECT movementid FROM cf_movement_types WHERE name = 'Retiro de Fondos'),
            @MontoGanancias,
            (SELECT statusid FROM cf_status_types WHERE name = 'Completado'),
            @FechaEjecucion,
            @FechaEjecucion,
            'Salida para distribución de dividendos proyecto ' + @ProjectName,
            NULL,
            (SELECT fundid FROM cf_project_funds WHERE projectid = @projectId),
            @PaymentID
        );

        -- 4. Actualizar fondos del proyecto
        UPDATE cf_project_funds
        SET 
            available_funds = available_funds - @MontoGanancias,
            distributed_funds = distributed_funds + @MontoGanancias,
            last_updated = @FechaEjecucion
        WHERE fundid = @FundID;
        
        -- 5. Aplicar comisiones a grupos
        DECLARE ComisionesCursor CURSOR FOR
        SELECT groupid, amount FROM #ComisionesCalculadas WHERE amount > 0;
        
        OPEN ComisionesCursor;
        FETCH NEXT FROM ComisionesCursor INTO @GroupID, @ComisionAmount;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN

            -- Obtener nombre del grupo
            SELECT @NombreGrupo = name 
            FROM vpv_groups 
            WHERE groupid = @GroupID;
            
            -- Obtener portfolioid del grupo validando el tipo
            SELECT @GrupoPortfolioId = portfolioid 
            FROM cf_investment_portfolios 
            WHERE userid = @GroupID 
            AND portfoliotype = (SELECT foliotype FROM cf_portfolio_types WHERE name = 'Grupo');
            
            -- Validar que existe el portafolio del grupo
            IF @GrupoPortfolioId IS NULL
            BEGIN
                SET @Message = 'No se encontró portafolio válido para el grupo: ' + ISNULL(@NombreGrupo, CAST(@GroupID AS VARCHAR));
                RAISERROR(@Message, 16, 1);
                RETURN -1;
            END

            -- Inserción transactions para distribución al final
            DECLARE @GroupTransactionID INT;

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
                payid
            )
            VALUES (
                'Comisión para grupo ' + ISNULL(@NombreGrupo, CAST(@GroupID AS VARCHAR)),
                'Comisión por distribución de dividendos proyecto ' + @ProjectName,
                @ComisionAmount,
                'GRP-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                  LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 8), 
                @FechaEjecucion,
                @FechaEjecucion,
                HASHBYTES('SHA2_256', CAST(@GroupID AS VARCHAR) + CAST(@ComisionAmount AS VARCHAR)),
                (SELECT transactiontypeid FROM vpv_transactiontypes WHERE name = 'Pago Comisión'),
                (SELECT transactionsubtypeid FROM vpv_transactionsubtypes WHERE name = 'Grupo'),
                (SELECT currencyid FROM vpv_currencies WHERE acronym = 'USD'),
                @PaymentID
            );

            SET @GroupTransactionID = SCOPE_IDENTITY();

            INSERT INTO #TransactionsToRegister VALUES (
                2, -- Group
                @GroupID,
                @ComisionAmount,
                @GroupTransactionID
            );

            -- Registrar movimiento financiero de comisión
            INSERT INTO cf_financial_movements (
                reference_code, 
                movement_typeid, 
                amount, 
                statusid,
                execution_date, 
                registered_date, 
                description,
                agreementid, 
                destination_portfolioid, 
                paymentid
            )
            VALUES (
                'GRP-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                  LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 8),
                (SELECT movementid FROM cf_movement_types WHERE name = 'Pago de tarifa'),
                @ComisionAmount,
                (SELECT statusid FROM cf_status_types WHERE name = 'Completado'),
                @FechaEjecucion,
                @FechaEjecucion,
                'Comisión por distribución a grupo ' + ISNULL(@NombreGrupo, CAST(@GroupID AS VARCHAR)),
                NULL,
                @GrupoPortfolioId,
                @PaymentID
            );
            
            -- Actualizar portafolio del grupo (validando tipo)
            UPDATE cf_investment_portfolios
            SET available_balance = available_balance + @ComisionAmount,
                last_update = @FechaEjecucion
            WHERE portfolioid = @GrupoPortfolioId
            AND portfoliotype = (SELECT foliotype FROM cf_portfolio_types WHERE name = 'Grupo');
            
            -- Verificar que se actualizó correctamente
            IF @@ROWCOUNT = 0
            BEGIN
                SET @Message = 'Error al actualizar portafolio del grupo: ' + ISNULL(@NombreGrupo, CAST(@GroupID AS VARCHAR));
                RAISERROR(@Message, 16, 1);
                RETURN -1;
            END

            FETCH NEXT FROM ComisionesCursor INTO @GroupID, @ComisionAmount;
        END
        
        CLOSE ComisionesCursor;
        DEALLOCATE ComisionesCursor;
        
        -- 6. Distribuir a inversionistas según su equity
        
        DECLARE InversionistasCursor CURSOR FOR
        SELECT 
            ia.agreementid,
            i.userid,
            ia.equity_porcentage
        FROM cf_investments i
        JOIN cf_investment_agreements ia ON i.investmentid = ia.investmentid
        WHERE i.projectid = @projectId
        AND i.statusid = (SELECT statusid FROM cf_status_types WHERE name = @EstadoActivo)
        AND ia.statusid = (SELECT statusid FROM cf_status_types WHERE name = @EstadoActivo);
        
        OPEN InversionistasCursor;
        FETCH NEXT FROM InversionistasCursor INTO @AgreementID, @UserID, @Equity;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Calcular monto proporcional
            SET @MontoInversionista = (@Equity / @TotalEquity) * @MontoDistribuir;

            -- Insertar en transacciones y guardar en tabla temporal
            DECLARE @InvestorTransactionID INT;

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
                payid
            )
            VALUES (
                'Dividendo para inversionista ' + CAST(@UserID AS VARCHAR),
                'Dividendo proyecto ' + @ProjectName + ' según equity ' + CAST(@Equity AS VARCHAR),
                @MontoInversionista,
                NEWID(), /*TODO: numero de referencia*/
                @FechaEjecucion,
                @FechaEjecucion,
                HASHBYTES('SHA2_256', CAST(@UserID AS VARCHAR) + CAST(@MontoInversionista AS VARCHAR)),
                (SELECT transactiontypeid FROM vpv_transactiontypes WHERE name = 'Dividendo'),
                (SELECT transactionsubtypeid FROM vpv_transactionsubtypes WHERE name = 'Inversionista'),
                (SELECT currencyid FROM vpv_currencies WHERE acronym = 'USD'),
                @PaymentID
            );

            SET @InvestorTransactionID = SCOPE_IDENTITY();

            INSERT INTO #TransactionsToRegister VALUES (
                1, -- Investor
                @AgreementID,
                @MontoInversionista,
                @InvestorTransactionID
            );
            -- Registrar movimiento financiero
            INSERT INTO cf_financial_movements (
                reference_code, 
                movement_typeid, 
                amount, 
                statusid,
                execution_date, 
                registered_date, 
                description,
                agreementid, 
                destination_portfolioid, 
                paymentid
            )
            VALUES (
                'INV-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                  LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 8),
                (SELECT movementid FROM cf_movement_types WHERE name = 'Dividendo'),
                @MontoInversionista,
                (SELECT statusid FROM cf_status_types WHERE name = 'Completado'),
                @FechaEjecucion,
                @FechaEjecucion,
                'Dividendo proyecto ' + CAST(@projectId AS VARCHAR) + ' periodo ' + CONVERT(VARCHAR(7), @FechaEjecucion, 120),
                @AgreementID, 
                (SELECT portfolioid FROM cf_investment_portfolios WHERE userid = @UserID AND portfoliotype = 1),
                @PaymentID
            );
            
            -- Actualizar portafolio del inversionista
            UPDATE cf_investment_portfolios
            SET available_balance = available_balance + @MontoInversionista,
                last_update = @FechaEjecucion
            WHERE userid = @UserID;
            
            FETCH NEXT FROM InversionistasCursor INTO @AgreementID, @UserID, @Equity;
        END
        
        CLOSE InversionistasCursor;
        DEALLOCATE InversionistasCursor;
        
        -- 7. Registrar ciclo de distribución
        INSERT INTO cf_dividend_distributions (
            projectid, 
            reportid, 
            total_amount, 
            fees_amount, 
            distributed_amount,
            distribution_date, 
            master_transactionid, 
            created_by
        )
        VALUES (
            @projectId, @ReporteGananciasID, @MontoGanancias, @ComisionesTotales, @MontoDistribuir,
            @FechaEjecucion, @TransactionID, @UsuarioEjecutor
        );

        SET @DistributionID = SCOPE_IDENTITY();

        INSERT INTO cf_distribution_transactions (
            distributionid, transactionid, transaction_typeid, related_id, amount
        )
        SELECT 
            @DistributionID,
            transactionid,
            transaction_typeid,
            related_id,
            amount
        FROM #TransactionsToRegister;

        IF @InicieTransaccion=1 BEGIN
            COMMIT
        END
        
        -- Retornar resumen
        SELECT 
            @MontoGanancias AS TotalGanancias,
            @ComisionesTotales AS ComisionesAplicadas,
            @MontoDistribuir AS DistribuidoInversionistas,
            @TransactionID AS TransactionID;
    END TRY
    BEGIN CATCH
        SET @ErrorNumber = ERROR_NUMBER()
        SET @ErrorSeverity = ERROR_SEVERITY()
        SET @ErrorState = ERROR_STATE()
        SET @Message = 'Error en SP_RepartirDividendos: ' + 
                  'Línea ' + CAST(ERROR_LINE() AS VARCHAR) + ' | ' + 
                  ERROR_MESSAGE();
        
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
            @projectId,         -- referencia 1
            @UsuarioEjecutor,             -- referencia 2
            CAST(@ErrorNumber AS VARCHAR),
            CAST(@ErrorState AS VARCHAR),
            HASHBYTES('SHA1', @Message), -- checksum simplificado
            @log_typeid,
            @log_sourceid,
            @log_severityid
        );
        
        -- Retornar error controlado
        RAISERROR('%s', 16, 1, @Message);
    END CATCH
    
    -- Limpiar tablas temporales
    IF OBJECT_ID('tempdb..#ComisionesCalculadas') IS NOT NULL
        DROP TABLE #ComisionesCalculadas;
        
    IF OBJECT_ID('tempdb..#TransactionsToRegister') IS NOT NULL
        DROP TABLE #TransactionsToRegister;
END
RETURN 0
GO
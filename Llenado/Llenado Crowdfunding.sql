-- Estados para el módulo de crowdfunding
INSERT INTO cf_status_types (name, module) VALUES 
('Borrador', 'crowdfunding'),
('En Revisión', 'crowdfunding'),
('Aprobado', 'crowdfunding'),
('Rechazado', 'crowdfunding'),
('En Recaudación', 'crowdfunding'),
('Financiado', 'crowdfunding'),
('En Ejecución', 'crowdfunding'),
('Completado', 'crowdfunding'),
('Suspendido', 'crowdfunding'),
('Cancelado', 'crowdfunding'),
('Activo', 'crowdfunding'),
('Pendiente', 'crowdfunding');

-- Tipos de proyectos de crowdfunding
INSERT INTO cf_project_types (name) VALUES 
('Infraestructura Pública'), -- Proyectos como expansión de boulevares, parques, etc.
('Energías Renovables'), -- Paneles solares, microhidroeléctricas
('Innovación Tecnológica'), -- Startups tech, desarrollo de software
('Agricultura Sostenible'), -- Proyectos agroecológicos, orgánicos
('Turismo Comunitario'), -- Eco-lodges, rutas turísticas locales
('Educación Digital'), -- Plataformas educativas, equipamiento tecnológico
('Salud Comunitaria'), -- Clínicas móviles, equipamiento médico
('Arte y Cultura'), -- Festivales, producciones artísticas
('Movilidad Urbana'), -- Bicicletas públicas, transporte eficiente
('Conservación Ambiental'), -- Reforestación, protección de especies
('Desarrollo Inmobiliario Sostenible'), -- Vivienda social, edificios verdes
('Economía Circular'); -- Reciclaje, reutilización de materiales

-- Sectores económicos para clasificación
INSERT INTO cf_sectors (name) VALUES 
('Construcción e Infraestructura'),
('Energía y Sostenibilidad'),
('Tecnología e Innovación'),
('Agroindustria y Alimentos'),
('Turismo y Hospitalidad'),
('Educación y Capacitación'),
('Salud y Bienestar'),
('Artes y Entretenimiento'),
('Transporte y Logística'),
('Medio Ambiente y Conservación'),
('Servicios Financieros'),
('Comercio y Retail'),
('Manufactura y Producción'),
('Servicios Profesionales'),
('Investigación y Desarrollo');

/*
******************************************************************
1. Infraestructura Pública (Boulevard Cartago)
******************************************************************
*/

-- Ejemplo completo para el proyecto mencionado
INSERT INTO cf_projects (
  budget, equity_offered, sectorid, startdate, statusid, 
  total_invested, proposalid, projecttypeid, min_funding_target, max_funding_target, name
) VALUES (
  18500000.00, -- 18.5 millones de dólares
  10.00, -- 10% de equity
  (SELECT sectorid FROM cf_sectors WHERE name = 'Construcción e Infraestructura'),
  '2024-06-01', 
  (SELECT statusid FROM cf_status_types WHERE name = 'Aprobado'),
  0.00,
  1, -- Asumiendo propuesta ID 1
  (SELECT pjtypeid FROM cf_project_types WHERE name = 'Infraestructura Pública'),
  5000000.00, -- Mínimo 5 millones
  15000000.00, -- Meta 15 millones
  'Expanción Boulevard Cartago'
);

/*
******************************************************************
2. Energía Renovable (Planta Solar en Guanacaste)
******************************************************************
*/

INSERT INTO cf_projects (
  budget, equity_offered, sectorid, startdate, statusid, 
  total_invested, proposalid, projecttypeid, min_funding_target, max_funding_target, name
) VALUES (
  3200000.00, -- 3.2 millones
  25.00, -- 25% equity
  (SELECT sectorid FROM cf_sectors WHERE name = 'Energía y Sostenibilidad'),
  '2024-07-15',
  (SELECT statusid FROM cf_status_types WHERE name = 'En Recaudación'),
  1250000.00, -- Ya recaudó 1.25 millones
  2,
  (SELECT pjtypeid FROM cf_project_types WHERE name = 'Energías Renovables'),
  2000000.00, -- Mínimo 2 millones
  3000000.00, -- Meta 3 millones
  'Planta Solar en Guanacaste'
);

/*
******************************************************************
3. Startup Tecnológica (Plataforma de Agricultura Digital)
******************************************************************
*/

INSERT INTO cf_projects (
  budget, equity_offered, sectorid, startdate, statusid, 
  total_invested, proposalid, projecttypeid, min_funding_target, max_funding_target, name
) VALUES (
  500000.00, -- 500 mil dólares
  30.00, -- 30% equity
  (SELECT sectorid FROM cf_sectors WHERE name = 'Tecnología e Innovación'),
  '2024-05-20',
  (SELECT statusid FROM cf_status_types WHERE name = 'En Ejecución'),
  500000.00, -- Completamente financiado
  3,
  (SELECT pjtypeid FROM cf_project_types WHERE name = 'Innovación Tecnológica'),
  300000.00, -- Mínimo 300 mil
  500000.00, -- Meta 500 mil
  'Plataforma de Agricultura Digital'
);

-- Insertar fondos para los proyectos
INSERT INTO cf_project_funds (projectid, total_funds, available_funds, distributed_funds, last_updated)
VALUES
(1, 0.00, 0.00, 0.00, GETDATE()),              -- Boulevard Cartago (sin financiar)
(2, 1250000.00, 00.00, 0.00, GETDATE()),  -- Planta Solar (parcialmente financiado)
(3, 500000.00, 00.00, 0.00, GETDATE());    -- Plataforma Agricultura Digital (totalmente financiado)

/******************************************/
-- Unidades de medida para los KPIs
INSERT INTO cf_measurement_units (name, symbol, description) VALUES
('Kilómetros', 'km', 'Longitud en kilómetros'),
('Hectáreas', 'ha', 'Superficie en hectáreas'),
('Megavatios', 'MW', 'Capacidad de generación eléctrica'),
('Hogares', 'hogares', 'Número de hogares beneficiados'),
('Empleos', 'empleos', 'Puestos de trabajo creados'),
('Toneladas', 't', 'Peso en toneladas métricas'),
('Metros cúbicos', 'm³', 'Volumen en metros cúbicos'),
('Personas', 'personas', 'Número de personas beneficiadas'),
('Porcentaje', '%', 'Porcentaje o ratio'),
('Dólares', '$', 'Dólares estadounidenses'),
('Comunidades', 'comun.', 'Número de comunidades beneficiadas'),
('Empresas', 'empresas', 'Número de empresas beneficiadas'),
('Horas', 'h', 'Tiempo en horas'),
('Kilovatios-hora', 'kWh', 'Energía en kilovatios-hora'),
('Usuarios', 'usuarios', 'Número de usuarios del servicio');


/*
1. KPIs para "Expansión del Boulevard Cartago" (projectid = 1)
*/

-- Indicadores para proyecto de infraestructura vial
INSERT INTO cf_project_kpis (projectid, value, description, unitid) VALUES
(1, 5.2, 'Longitud de vía expandida', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'km')),
(1, 8, 'Comunidades conectadas directamente', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'comun.')),
(1, 15000, 'Personas beneficiadas diariamente', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'personas')),
(1, 45, 'Reducción promedio en minutos de viaje', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'h')),
(1, 120, 'Empleos directos generados durante construcción', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'empleos')),
(1, 30, 'Reducción estimada de emisiones CO2 (anual)', (SELECT unitid FROM cf_measurement_units WHERE symbol = 't')),
(1, 2500000, 'Impacto económico anual estimado', (SELECT unitid FROM cf_measurement_units WHERE symbol = '$'));

/*
2. KPIs para "Planta Solar en Guanacaste" (projectid = 2)
*/

-- Indicadores para proyecto de energía renovable
INSERT INTO cf_project_kpis (projectid, value, description, unitid) VALUES
(2, 4.5, 'Capacidad instalada de generación', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'MW')),
(2, 6500, 'Hogares que podrán ser abastecidos', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'hogares')),
(2, 12000, 'Toneladas de CO2 evitadas anualmente', (SELECT unitid FROM cf_measurement_units WHERE symbol = 't')),
(2, 25, 'Empleos permanentes creados', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'empleos')),
(2, 30, 'Porcentaje de energía limpia en la región', (SELECT unitid FROM cf_measurement_units WHERE symbol = '%')),
(2, 15000000, 'Generación anual estimada', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'kWh')),
(2, 8, 'Empresas locales que participarán en mantenimiento', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'empresas'));

/*
3. KPIs para "Plataforma de Agricultura Digital" (projectid = 3)
*/
-- Indicadores para proyecto tecnológico agrícola
INSERT INTO cf_project_kpis (projectid, value, description, unitid) VALUES
(3, 1500, 'Agricultores que usarán la plataforma', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'usuarios')),
(3, 30, 'Incremento porcentual en productividad estimado', (SELECT unitid FROM cf_measurement_units WHERE symbol = '%')),
(3, 500, 'Hectáreas bajo gestión digitalizada', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'ha')),
(3, 20, 'Reducción porcentual en uso de agua', (SELECT unitid FROM cf_measurement_units WHERE symbol = '%')),
(3, 18, 'Empleos técnicos creados', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'empleos')),
(3, 200000, 'Ingresos anuales proyectados para agricultores', (SELECT unitid FROM cf_measurement_units WHERE symbol = '$')),
(3, 45, 'Empresas agroindustriales asociadas', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'empresas'));



/********************************************************
PLAN DE EJECUCIÓN
********************************************************/
/*
1. Plan para "Expansión del Boulevard Cartago" (projectid = 1)
*/
-- Hitos principales 

INSERT INTO cf_projects_milestones (
  name, description, target_date, completion_date, disbursement_porcentage, 
  statusid, validation_required, projectid, vote_sessionid
) VALUES
('Preparación del terreno', 'Despeje y nivelación del área de construcción', '2024-06-15', NULL, 15.00, 
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 1, NULL),
('Construcción base', 'Capa base y sub-base de la vía', '2024-08-30', NULL, 25.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 1, NULL),
('Capa asfáltica', 'Asfaltado completo de la vía', '2024-10-15', NULL, 30.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 1, NULL),
('Señalización', 'Instalación de señales viales y demarcación', '2024-11-30', NULL, 15.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 1, NULL),
('Entrega final', 'Pruebas finales y entrega a la municipalidad', '2024-12-20', NULL, 15.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 1, NULL);

-- Desembolsos programados ------------------------------------------

-- Desembolsos para el primer hito
INSERT INTO cf_project_disbursements (
  amount, request_date, approval_date, statusid, projectid, milestoneid, approved_by, paymentid
) VALUES
(2775000.00, '2024-06-01', NULL, 
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 
 (SELECT milestoneid FROM cf_projects_milestones WHERE projectid = 1 AND name = 'Preparación del terreno'), 
 NULL, NULL);

-- Desembolsos para los otros hitos (ejemplo)
INSERT INTO cf_project_disbursements (
  amount, request_date, approval_date, statusid, projectid, milestoneid, approved_by, paymentid
) VALUES
(4625000.00, '2024-08-15', NULL, 
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 
 (SELECT milestoneid FROM cf_projects_milestones WHERE projectid = 1 AND name = 'Construcción base'), 
 NULL, NULL),
(5550000.00, '2024-10-01', NULL, 
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 
 (SELECT milestoneid FROM cf_projects_milestones WHERE projectid = 1 AND name = 'Capa asfáltica'), 
 NULL, NULL);
 
-- Tareas específicas (cf_milestones_tasks)

-- Tareas para el primer hito
INSERT INTO cf_milestones_tasks (
  description, fixed_amount, porcentage_amount, completed, kpiid, statusid, milestoneid, validation_required
) VALUES
('Estudio topográfico completo', 500000.00, 0.00, 0, NULL,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'),
 (SELECT milestoneid FROM cf_projects_milestones WHERE projectid = 1 AND name = 'Preparación del terreno'), 1),
('Demolición de estructuras existentes', 750000.00, 0.00, 0, NULL,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'),
 (SELECT milestoneid FROM cf_projects_milestones WHERE projectid = 1 AND name = 'Preparación del terreno'), 1);

/*
2. Plan para "Planta Solar en Guanacaste" (projectid = 2)
*/

-- Hitos principales
INSERT INTO cf_projects_milestones (
  name, description, target_date, completion_date, disbursement_porcentage, 
  statusid, validation_required, projectid, vote_sessionid
) VALUES
('Adquisición de terreno', 'Compra y preparación del terreno', '2024-07-01', NULL, 20.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 2, NULL),
('Instalación de paneles', 'Montaje de estructuras y paneles solares', '2024-09-15', NULL, 35.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 2, NULL),
('Conexión a red', 'Instalación de inversores y conexión a la red eléctrica', '2024-11-01', NULL, 25.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 2, NULL),
('Pruebas operativas', 'Puesta en marcha y pruebas de generación', '2024-12-15', NULL, 15.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 2, NULL),
('Operación comercial', 'Inicio de operaciones comerciales', '2025-01-15', NULL, 5.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 2, NULL);

-- Desembolsos programados

-- Primer desembolso
INSERT INTO cf_project_disbursements (
  amount, request_date, approval_date, statusid, projectid, milestoneid, approved_by, paymentid
) VALUES
(640000.00, '2024-06-15', NULL,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 2,
 (SELECT milestoneid FROM cf_projects_milestones WHERE projectid = 2 AND name = 'Adquisición de terreno'),
 NULL, NULL);

/*
3. Plan para "Plataforma de Agricultura Digital" (projectid = 3)
*/

-- Hitos principales

INSERT INTO cf_projects_milestones (
  name, description, target_date, completion_date, disbursement_porcentage, 
  statusid, validation_required, projectid, vote_sessionid
) VALUES
('Desarrollo MVP', 'Versión mínima funcional de la plataforma', '2024-05-30', NULL, 30.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 3, NULL),
('Pruebas piloto', 'Implementación con 100 agricultores iniciales', '2024-07-15', NULL, 20.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 3, NULL),
('Lanzamiento oficial', 'Versión completa para todos los usuarios', '2024-09-01', NULL, 25.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 3, NULL),
('Capacitaciones', 'Programa de capacitación para agricultores', '2024-10-15', NULL, 15.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 3, NULL),
('Primer reporte de impacto', 'Evaluación de resultados después de 6 meses', '2025-03-01', NULL, 10.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'), 1, 3, NULL);

-- KPIs específicos por hito (cf_milestone_kpis) --

-- KPI para el MVP
INSERT INTO cf_milestone_kpis (value, description, unitid) VALUES
(100, 'Agricultores registrados en fase beta', (SELECT unitid FROM cf_measurement_units WHERE symbol = 'usuarios'));

-- Relacionar KPI con tarea
INSERT INTO cf_milestones_tasks (
  description, fixed_amount, porcentage_amount, completed, kpiid, statusid, milestoneid, validation_required
) VALUES
('Implementar sistema de registro de usuarios', 75000.00, 0.00, 0,
 (SELECT kpiid FROM cf_milestone_kpis WHERE description = 'Agricultores registrados en fase beta'),
 (SELECT statusid FROM cf_status_types WHERE name = 'Pendiente'),
 (SELECT milestoneid FROM cf_projects_milestones WHERE projectid = 3 AND name = 'Desarrollo MVP'), 1);

-- Tipos de acuerdos de inversión
INSERT INTO cf_agreement_types (name) VALUES 
('Equity Tradicional'),       -- Participación accionaria estándar
('Deuda Convertible'),        -- Préstamo convertible en equity
('Participación en Ganancias'), -- Porcentaje de beneficios
('Préstamo con Interés Fijo'), -- Préstamo con tasa fija
('Royalties');               -- Porcentaje de ventas

-- Portafolios para los usuarios inversores
INSERT INTO cf_investment_portfolios (
    available_balance, invested_balance, last_update, pending_returns, userid, portfoliotype
) VALUES
(12500.00, 42750.00, GETDATE(), 3800.00, 1, 1),  
(48750.00, 115000.00, GETDATE(), 18750.00, 2, 1),
(142300.00, 175500.00, GETDATE(), 6250.00, 3, 1),
(63200.00, 118750.00, GETDATE(), 2250.00, 4, 1),
(87500.00, 127500.00, GETDATE(), 31250.00, 5, 1),
(58750.00, 115000.00, GETDATE(), 1875.00, 6, 1),
(51250.00, 117500.00, GETDATE(), 1250.00, 7, 1),
(48750.00, 122500.00, GETDATE(), 950.00, 8, 1),
(52500.00, 118000.00, GETDATE(), 2100.00, 9, 1),
(47500.00, 117500.00, GETDATE(), 16250.00, 10, 1), 
(51250.00, 116250.00, GETDATE(), 14750.00, 11, 1),
(48750.00, 122750.00, GETDATE(), 15350.00, 12, 1),
(50250.00, 119500.00, GETDATE(), 14875.00, 13, 1),
(49250.00, 121250.00, GETDATE(), 15125.00, 14, 1),
(9750.00, 21250.00, GETDATE(), 3250.00, 15, 1),  
(10250.00, 20750.00, GETDATE(), 3150.00, 1, 2);   

-- Tipos de movimientos financieros
INSERT INTO cf_movement_types (name) VALUES
('Inversión Inicial'),
('Inversión'),
('Retorno de Inversión'),
('Dividendo'),
('Reinversión'),
('Retiro de Fondos'),
('Pago de Intereses'),
('Ajuste de Portafolio'),
('Pago de tarifa');

/*
Insertar Acuerdos de Inversión (cf_investment_agreements)
*/
-- Para el proyecto 1 (Boulevard Cartago):
/*
-- Acuerdo para inversión en Boulevard Cartago
INSERT INTO cf_investment_agreements (
    investmentid, agreement_type, expected_returns, equity_porcentage,
    signed_date, statusid, last_modifies, terms_hash
) VALUES
(1, 1, 8.50, 2.75, GETDATE(), 
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'), GETDATE(),
 CONVERT(VARBINARY(255), NEWID()));

-- Para el proyecto 2 (Planta Solar):

-- Acuerdo para inversión en Planta Solar
INSERT INTO cf_investment_agreements (
    investmentid, agreement_type, expected_returns, equity_porcentage,
    signed_date, statusid, last_modifies, terms_hash
) VALUES
(2, 3, 12.00, 5.00, GETDATE(),
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'), GETDATE(),
 CONVERT(VARBINARY(255), NEWID()));
*/
 
 -- estado de reportes 

INSERT INTO cf_report_types (name)
  VALUES ('Ganancias');

/*
INSERT INTO cf_financial_reports (
  period,
  reporttypeid,
  document_hash,
  submission_date,
  approved,
  projectid,
  documentid,
  uploaded_by,

)
VALUES (
  '2025-Q2',          -- Periodo
  1,                  -- reporttypeid para 'Ganancias'
  CONVERT(VARBINARY(255), HASHBYTES('SHA2_256', 'reporte_pdf')), 
  GETDATE(),          -- Fecha de envío
  1,                  -- Aprobado
  1,                -- ID del proyecto en estado "ejecutando"
  NULL,                 -- Documento cargado
  2                   -- Usuario que subió el archivo
);
*/

-- Insertar inversiones para el proyecto 3 (5 inversionistas)
INSERT INTO cf_investments (
    amount, investmentdate, equity_obtained, statusid, 
    investment_hash, projectid, paymentid, userid
)
VALUES
-- Inversión 1: $150,000 por 9% equity
(150000.00, '2024-05-20', 9.00, 
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'),
 CONVERT(VARBINARY(255), HASHBYTES('SHA2_256', 'Inversion_1')), 3, NULL, 6),

-- Inversión 2: $100,000 por 6% equity
(100000.00, '2024-05-21', 6.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'),
 CONVERT(VARBINARY(255), HASHBYTES('SHA2_256', 'Inversion_2')), 3, NULL, 7),

-- Inversión 3: $75,000 por 4.5% equity
(75000.00, '2024-05-22', 4.50,
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'),
 CONVERT(VARBINARY(255), HASHBYTES('SHA2_256', 'Inversion_3')), 3, NULL, 8),

-- Inversión 4: $100,000 por 6% equity
(100000.00, '2024-05-23', 6.00,
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'),
 CONVERT(VARBINARY(255), HASHBYTES('SHA2_256', 'Inversion_4')), 3, NULL, 9),

-- Inversión 5: $75,000 por 4.5% equity
(75000.00, '2024-05-24', 4.50,
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'),
 CONVERT(VARBINARY(255), HASHBYTES('SHA2_256', 'Inversion_5')), 3, NULL, 10);

-- Insertar acuerdos de inversión para el proyecto 3
INSERT INTO cf_investment_agreements (
    investmentid, agreement_type, expected_returns, equity_porcentage,
    signed_date, statusid, last_modifies, terms_hash
)
VALUES
(1, 1, 15.00, 9.00, '2024-05-20', 
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'), GETDATE(),
 CONVERT(VARBINARY(255), NEWID())),

(2, 1, 15.00, 6.00, '2024-05-21',
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'), GETDATE(),
 CONVERT(VARBINARY(255), NEWID())),

(3, 1, 15.00, 4.50, '2024-05-22',
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'), GETDATE(),
 CONVERT(VARBINARY(255), NEWID())),

(4, 1, 15.00, 6.00, '2024-05-23',
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'), GETDATE(),
 CONVERT(VARBINARY(255), NEWID())),

(5, 1, 15.00, 4.50, '2024-05-24',
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'), GETDATE(),
 CONVERT(VARBINARY(255), NEWID()));

-- Insertar estructuras de comisión para grupos asociados al proyecto 3
INSERT INTO cf_fee_type (name) VALUES 
('Porcentaje sobre ganancias'),
('Monto fijo por distribución'),
('Porcentaje sobre capital');

--          GRUPO DE FEE STRUCTURE ----------------
INSERT INTO vpv_group_type (name)
    VALUES ('Aceleradora'),('Incubadora'),('Grupo Inversor');

INSERT INTO vpv_groups (name, description, grouptypeid, entityid)
VALUES (
    'Aceleradora TechCR',
    'Aceleradora de proyectos tecnológicos',
    1,
    5
);

-- Estructuras de comisión para el grupo
INSERT INTO cf_fee_structures (
    value, fee_typeid, applicable_to, effective_date, end_date, groupid
)
VALUES
(5.00, 1, 'Ganancias netas', '2024-01-01', NULL, 1), -- 5% de ganancias
(1000.00, 2, 'Por distribución', '2024-01-01', NULL, 1); -- $1000 fijo por distribución

-- Configurar comisiones para el proyecto 3
INSERT INTO cf_project_fee_configurations (
    projectid, structureid, start_date, end_date, payment_scheduleid, statusid
)
VALUES
(3, 1, '2024-05-20', NULL, NULL, 
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo')),
(3, 2, '2024-05-20', NULL, NULL, 
 (SELECT statusid FROM cf_status_types WHERE name = 'Activo'));


-- Actualizar el proyecto 3 para simular que generó ganancias
UPDATE cf_project_funds 
SET available_funds = available_funds + 75000.00 -- $75,000 en ganancias
WHERE projectid = 3;

-- Insertar tipos de transacción necesarios
INSERT INTO vpv_transactiontypes (name) VALUES 
('Ingreso'),          -- Para registrar las ganancias del proyecto
('Dividendo'),        -- Para la distribución de dividendos
('Pago Comisión'),     -- Para pagos de comisiones
('Inversión'),      -- Para inversiones iniciales
('Desembolso');    -- Para desembolsos del proyecto

-- Insertar subtipos de transacción
INSERT INTO vpv_transactionsubtypes (name) VALUES
('Ganancias Proyecto'),     -- Ingresos generados por el proyecto
('Distribución Proyecto'), -- Distribución a inversionistas
('Comisión de grupo'),     -- Pago de comisiones a grupos
('Inversión en equity'),    -- Inversión en equity
('Inversión deuda'),      -- Inversión como deuda
('Retorno de capital'),       -- Retorno de capital
('Gastos Operativos'),  -- Gastos operativos
('Pago por hito'),    -- Pago por hitos cumplidos
('Inversionista'),
('Grupo');

-- Insertar monedas (con CRC como principal)
INSERT INTO vpv_currencies (name, acronym, country, symbol) VALUES
('Costa Rican Colón', 'CRC', 'Costa Rica', '₡'),
('US Dollar', 'USD', 'United States', '$');

INSERT INTO vpv_paymentstatus (name) VALUES 
('Completed'),
('Pending'),
('Failed'),
('Reversed'),
('On Hold');

DECLARE @PaymentID INT

INSERT INTO vpv_payments (
  amount, taxamount, discountporcent, realamount,
  result, authcode, referencenumber, chargetoken,
  date, checksum, statusid,
  paymentmethodid, availablemethodid
)
VALUES (
  75000.00,                       -- amount
  0,                              -- taxamount (asumimos 0 para dividendos)
  0,                              -- discountporcent
  75000.00,                       -- realamount (igual al amount sin descuentos)
  'COMPLETED',                    -- result
  'INC-3-20250626',               -- authcode
  'GAN-VOF-7880-002',             -- referencenumber
  CONVERT(VARBINARY(255), 'pay_tok_3x7b9f2q1'),  -- chargetoken (ejemplo en formato binario)
  GETDATE(),                      -- date
  HASHBYTES('SHA2_256', '3-75000.00'), -- checksum
  (SELECT paymentstatusid FROM vpv_paymentstatus WHERE name = 'Completed'), -- statusid
  1,                              -- paymentmethodid
  1                               -- availablemethodid
);

SET @PaymentID = SCOPE_IDENTITY();

--Crear transacción de ENTRADA de fondos al sistema
INSERT INTO vpv_transactions (
  name, description, amount, referencenumber, 
  transactiondate, officetime, checksum,
  transactiontypeid, transactionsubtypeid, currencyid,
  payid -- Asociamos el pago creado
)
VALUES (
  'Ganancias Proyecto 3 - Q2 2024', 
  'Depósito de ganancias generadas por la plataforma agrícola para distribución según reporte',
  75000.00,
  'GAN-VOF-7880-002',
  GETDATE(),
  GETDATE(),
  HASHBYTES('SHA2_256', '3-75000.00'),
  (SELECT transactiontypeid FROM vpv_transactiontypes WHERE name = 'Ingreso'),
  (SELECT transactionsubtypeid FROM vpv_transactionsubtypes WHERE name = 'Ganancias Proyecto'),
  (SELECT currencyid FROM vpv_currencies WHERE acronym = 'USD'),
  @PaymentID
);

-- Crear reporte financiero aprobado para las ganancias
INSERT INTO cf_financial_reports (
    period, reporttypeid, document_hash, submission_date,
    approved, projectid, uploaded_by, transactionid, name
)
VALUES (
    '2025-Q2', 
    (SELECT reporttypeid FROM cf_report_types WHERE name = 'Ganancias'),
    HASHBYTES('SHA2_256', 'reporte_ganancias_q2_proyecto3'),
    GETDATE(),
    1, -- Aprobado
    3, -- Proyecto 3
    2,  -- Subido por admin
    1,
    'Reporte de Ganancias T2-2025 - Proyecto Plataforma de Agricultura Digital'
);











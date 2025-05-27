# Documentación del Módulo de Crowdfunding

## Tablas Principales

### 1. `cf_projects`
**Propósito**: Almacena la información central de cada proyecto de crowdfunding.

```sql
CREATE TABLE `cf_projects` (
  `projectid` INT,                      -- ID único del proyecto (ej: 1001)
  `budget` DECIMAL(12,2),               -- Presupuesto total (ej: 50000.00)
  `equity_offered` DECIMAL(5,2),        -- Porcentaje de equity ofrecido (ej: 15.00)
  `employment_commitment` TEXT,         -- Compromisos de empleo (ej: "Generar 20 empleos")
  `sector` VARCHAR(100),                -- Sector económico (ej: "Tecnología")
  `startdate` DATETIME,                 -- Fecha de inicio (ej: '2023-06-01')
  `current_state` VARCHAR(50),          -- Estado actual (ej: 'En financiamiento')
  `total_invested` DECIMAL(12,2),       -- Total invertido hasta ahora (ej: 25000.00)
  `proposalid` INT,                     -- ID de la propuesta relacionada
  `entityid` INT,                       -- ID de entidad responsable
  `validationid` INT,                   -- ID de validación aprobatoria
  PRIMARY KEY (`projectid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_projects` VALUES (
  1001,
  50000.00,
  15.00,
  'Generar 20 empleos directos',
  'Tecnología',
  '2023-06-01 00:00:00',
  'En financiamiento',
  25000.00,
  45,
  12,
  8
);
```

---

### 2. `cf_project_types`
**Propósito**: Define los tipos de proyectos y sus requisitos específicos.

```sql
CREATE TABLE `cf_project_types` (
  `pjtypeid` INT,                       -- ID tipo proyecto (ej: 1)
  `name` VARCHAR(100),                  -- Nombre (ej: 'Proyecto Municipal')
  `validationrules` TEXT,               -- Reglas de validación en JSON
  `legal_requirements` TEXT,            -- Requisitos legales
  `min_funding_target` DECIMAL(12,2),   -- Mínimo financiamiento (ej: 5000.00)
  `max_funding_target` DECIMAL(12,2),   -- Máximo financiamiento (ej: 100000.00)
  `allowed_currencies` JSON,            -- Monedas aceptadas (ej: '["CRC", "USD"]')
  `required_documents` JSON,            -- Docs requeridos (ej: '[{"doc": "plan_negocios"}]')
  PRIMARY KEY (`pjtypeid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_project_types` VALUES (
  1,
  'Proyecto Municipal',
  '{"min_approvals": 3}',
  'Debe estar alineado con planes de desarrollo local',
  5000.00,
  100000.00,
  '["CRC", "USD"]',
  '[{"doc": "plan_negocios", "required": true}]'
);
```

---

### 3. `cf_project_endorsements`
**Propósito**: Registra los avales que reciben los proyectos por parte de grupos certificadores.

```sql
CREATE TABLE `cf_project_endorsements` (
  `endorsementid` INT,                  -- ID aval (ej: 1)
  `approval_status` VARCHAR(20),        -- Estado (ej: 'approved')
  `approval_date` DATETIME,             -- Fecha aprobación (ej: '2023-05-15')
  `projectid` INT,                      -- ID proyecto (ej: 1001)
  `fea_structureid` INT,                -- ID estructura financiera aplicada
  `groupid` INT,                        -- ID grupo avalador
  `validation_processid` INT,           -- ID proceso de validación
  `approved_by` INT,                    -- ID usuario que aprobó
  `documentid` INT,                     -- ID documento con términos
  PRIMARY KEY (`endorsementid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_project_endorsements` VALUES (
  1,
  'approved',
  '2023-05-15 14:30:00',
  1001,
  5,
  3,
  8,
  45,
  302
);
```

---

### 4. `cf_fea_structures`
**Propósito**: Almacena las estructuras financieras que aplican los grupos avaladores.

```sql
CREATE TABLE `cf_fea_structures` (
  `structureid` INT,                    -- ID estructura (ej: 1)
  `value` DECIMAL(10,2),                -- Valor (ej: 10.00)
  `featype` VARCHAR(30),                -- Tipo (ej: 'percentage_fee')
  `applicable_to` VARCHAR(100),         -- Aplicable a (ej: 'projects > 50000')
  `effective_date` DATETIME,            -- Fecha inicio vigencia
  `end_date` DATETIME,                  -- Fecha fin vigencia (NULL si activa)
  `groupid` INT,                        -- ID grupo asociado
  PRIMARY KEY (`structureid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_fea_structures` VALUES (
  5,
  10.00,
  'equity_stake',
  'all_projects',
  '2023-01-01 00:00:00',
  NULL,
  3
);
```

---

### 5. `cf_investments`
**Propósito**: Registra todas las inversiones realizadas en los proyectos.

```sql
CREATE TABLE `cf_investments` (
  `investmentid` INT,                   -- ID inversión (ej: 1)
  `amount` DECIMAL(12,2),               -- Monto invertido (ej: 5000.00)
  `investmentdate` DATETIME,            -- Fecha inversión (ej: '2023-06-10')
  `equity_obtained` DECIMAL(5,2),       -- % equity obtenido (ej: 1.50)
  `status` VARCHAR(20),                 -- Estado (ej: 'confirmed')
  `investment_hash` VARBINARY(255),     -- Hash de seguridad
  `projectid` INT,                      -- ID proyecto
  `paymentid` INT,                      -- ID pago asociado
  `userid` INT,                         -- ID inversor
  PRIMARY KEY (`investmentid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_investments` VALUES (
  1,
  5000.00,
  '2023-06-10 09:15:22',
  1.50,
  'confirmed',
  0x1a2b3c...,
  1001,
  78,
  45
);
```

---

### 6. `cf_project_milestones`
**Propósito**: Registra los hitos y fases de ejecución de cada proyecto.

```sql
CREATE TABLE `cf_projects_milestones` (
  `milestoneid` INT,                    -- ID hito (ej: 1)
  `name` VARCHAR(100),                  -- Nombre (ej: 'Fase 1 - Desarrollo')
  `description` VARCHAR(255),           -- Descripción detallada
  `target_date` DATETIME,               -- Fecha objetivo (ej: '2023-08-15')
  `completion_date` DATETIME,           -- Fecha real completado
  `disbursement_porcentage` DECIMAL(5,2), -- % desembolso (ej: 30.00)
  `status` VARCHAR(20),                 -- Estado (ej: 'pending')
  `validation_required` BIT,            -- Requiere validación (1/0)
  `projectid` INT,                      -- ID proyecto
  `validation_processid` INT,           -- ID proceso validación
  PRIMARY KEY (`milestoneid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_projects_milestones` VALUES (
  1,
  'Fase 1 - Desarrollo',
  'Desarrollo del prototipo funcional',
  '2023-08-15 00:00:00',
  NULL,
  30.00,
  'pending',
  1,
  1001,
  12
);
```

---

### Tablas de Financiamiento y Desembolsos

#### 7. `cf_project_disbursements`
**Propósito**: Registra cada desembolso de fondos a los creadores de proyectos, asegurando el flujo controlado de capital según los hitos alcanzados. Esta tabla es clave para la transparencia financiera y cumple con el requisito de "la plataforma administra los desembolsos mensuales conforme al plan aprobado".

```sql
CREATE TABLE `cf_project_disbursements` (
  `disbursementid` INT,                -- ID único del desembolso
  `amount` DECIMAL(12,2),              -- Monto desembolsado (ej: 15000.00)
  `request_date` DATETIME,             -- Fecha solicitud (ej: '2023-08-10 09:00:00')
  `approval_date` DATETIME,            -- Fecha aprobación (NULL si pendiente)
  `status` VARCHAR(20),                -- Estado: 'pending', 'approved', 'rejected', 'processed'
  `projectid` INT,                     -- ID proyecto asociado
  `milestoneid` INT,                   -- ID hito que gatilla el desembolso
  `approved_by` INT,                   -- ID usuario que aprobó (si aplica)
  `paymentid` INT,                     -- ID pago relacionado en sistema financiero
  PRIMARY KEY (`disbursementid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_project_disbursements` VALUES (
  1,
  15000.00,
  '2023-08-10 09:00:00',
  '2023-08-12 14:30:00',
  'processed',
  1001,
  1,
  45,
  89
);
```

**Flujo típico**:
1. Se completa un hito (`cf_projects_milestones`)
2. Sistema genera registro de desembolso pendiente
3. Validadores aprueban/rechazan
4. Al aprobarse, se ejecuta pago y actualiza estado

---

#### 8. `cf_investor_returns`
**Propósito**: Registra los retornos financieros a inversionistas (dividendos, reembolsos, etc.), implementando el requisito de "plan de pago a los inversionistas". Permite trazabilidad completa de rendimientos.

```sql
CREATE TABLE `cf_investor_returns` (
  `returnid` INT,                      -- ID retorno
  `amount` DECIMAL(12,2),              -- Monto (ej: 500.00)
  `return_type` VARCHAR(20),           -- Tipo: 'dividend', 'capital_return', 'interest'
  `return_date` DATETIME,              -- Fecha efectiva
  `description` VARCHAR(300),          -- Detalles (ej: 'Dividendo Q2 2023')
  `status` VARCHAR(20),                -- Estado: 'pending', 'processed', 'cancelled'
  `investmentid` INT,                  -- ID inversión relacionada
  `paymentid` INT,                     -- ID pago asociado
  PRIMARY KEY (`returnid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_investor_returns` VALUES (
  1,
  500.00,
  'dividend',
  '2023-09-30 00:00:00',
  'Dividendos correspondientes a Q2-2023',
  'pending',
  1,
  90
);
```

---

### Tablas de Gobernanza y Decisiones

#### 9. `cf_project_votes`
**Propósito**: Relaciona proyectos con sesiones de votación, permitiendo decisiones comunitarias sobre aspectos críticos. Implementa el requisito de "votación para detener proyectos en caso de irregularidades".

```sql
CREATE TABLE `cf_project_votes` (
  `projectvoteid` INT,                 -- ID relación
  `vote_porpuse` VARCHAR(50),          -- Propósito: 'project_approval', 'benefit_approval', 'oversight'
  `related_id` INT,                    -- ID elemento relacionado (hito, beneficio, etc.)
  `projectid` INT,                     -- ID proyecto
  `vote_sessionid` INT,                -- ID sesión de votación
  PRIMARY KEY (`projectvoteid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_project_votes` VALUES (
  1,
  'milestone_approval',
  1,          -- milestoneid
  1001,       -- projectid
  34          -- vote_sessionid
);
```

---

#### 10. `cf_goverment_benefits`
**Propósito**: Gestiona beneficios especiales otorgados por el gobierno (incentivos fiscales, etc.), implementando el requisito de "el gobierno puede votar sobre beneficios especiales".

```sql
CREATE TABLE `cf_goverment_benefits` (
  `goverbenefitid` INT,                -- ID beneficio
  `benefit_type` VARCHAR(20),          -- Tipo: 'tax_incentive', 'social_security', etc.
  `terms` TEXT,                        -- Términos legales
  `description` TEXT,                  -- Descripción pública
  `approval_status` VARCHAR(20),       -- Estado: 'pending', 'approved', 'rejected'
  `approval_date` DATETIME,            -- Fecha aprobación
  `approval_vote_id` INT,              -- ID votación que lo aprobó
  `approved_by` INT,                   -- ID usuario que validó
  `projectid` INT,                     -- ID proyecto beneficiado
  PRIMARY KEY (`goverbenefitid`)
);
```

**Ejemplo**:
```sql
INSERT INTO `cf_goverment_benefits` VALUES (
  1,
  'tax_incentive',
  'Exención del 50% de impuestos por 2 años',
  'Incentivo para proyectos de tecnología verde',
  'approved',
  '2023-07-15 00:00:00',
  35,
  50,
  1001
);
```

---

### Tablas de Reportes y Transparencia

#### 11. `cf_financial_reports`
**Propósito**: Almacena los reportes financieros periódicos que los creadores de proyectos deben presentar, cumpliendo con el requisito de "los creadores deben presentar mensualmente estados financieros". Esta tabla garantiza la transparencia hacia inversionistas y fiscalizadores.

```sql
CREATE TABLE `cf_financial_reports` (
  `reportid` INT,                      -- ID único del reporte
  `period` VARCHAR(20),                -- Período reportado (ej: '2023-06')
  `reporttypeid` INT,                  -- Tipo de reporte (1=Balance, 2=Estado de resultados)
  `document_hash` VARBINARY(255),      -- Hash del documento para integridad
  `submission_date` DATETIME,          -- Fecha de entrega (ej: '2023-07-05 15:00:00')
  `approved` BIT,                      -- Aprobado por plataforma (1/0)
  `projectid` INT,                     -- ID proyecto asociado
  PRIMARY KEY (`reportid`),
  FOREIGN KEY (`reporttypeid`) REFERENCES `cf_report_types`(`reporttypeid`)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO `cf_financial_reports` VALUES (
  1,
  '2023-06',
  2,
  0xa1b2c3d4...,
  '2023-07-05 15:00:00',
  1,
  1001
);
```

**Flujo de trabajo**:
1. Creador sube reporte mensual
2. Sistema genera hash de verificación
3. Validadores revisan y aprueban
4. Reporte queda disponible para inversionistas

---

#### 12. `cf_report_types`
**Propósito**: Cataloga los tipos de reportes financieros requeridos, permitiendo configurar diferentes requisitos por tipo de proyecto.

```sql
CREATE TABLE `cf_report_types` (
  `reporttypeid` INT,                  -- ID tipo de reporte
  `name` VARCHAR(100),                 -- Nombre descriptivo (ej: 'Balance General')
  PRIMARY KEY (`reporttypeid`)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO `cf_report_types` VALUES 
(1, 'Balance General'),
(2, 'Estado de Resultados'),
(3, 'Flujo de Efectivo');
```

---

#### 13. `cf_project_complains`
**Propósito**: Registra denuncias o reportes de irregularidades por parte de la comunidad, implementando el mecanismo de "cualquier ciudadano puede actuar como fiscalizador".

```sql
CREATE TABLE `cf_project_complains` (
  `complainid` INT,                    -- ID denuncia
  `description` VARCHAR(300),          -- Descripción detallada
  `evidence_hash` VARBINARY(255),      -- Hash de evidencias adjuntas
  `submission_date` DATETIME,          -- Fecha de reporte
  `status` VARCHAR(20),                -- Estado: 'open', 'investigating', 'resolved'
  `projectid` INT,                     -- ID proyecto denunciado
  `userid` INT,                        -- ID usuario denunciante
  PRIMARY KEY (`complainid`)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO `cf_project_complains` VALUES (
  1,
  'Uso de fondos no acorde al plan aprobado',
  0xe4f5a6b7...,
  '2023-08-20 10:15:00',
  'investigating',
  1001,
  78
);
```

---

#### 14. `cf_project_complains_resolution`
**Propósito**: Registra el proceso de resolución de cada denuncia, incluyendo decisiones tomadas por votación o comités de revisión.

```sql
CREATE TABLE `cf_project_complains_resolution` (
  `resolutionid` INT,                  -- ID resolución
  `resolution` TEXT,                   -- Texto completo de la resolución
  `date` DATETIME,                     -- Fecha de resolución
  `resolved_by` INT,                   -- ID usuario o sistema que resolvió
  `complainid` INT,                    -- ID denuncia relacionada
  PRIMARY KEY (`resolutionid`)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO `cf_project_complains_resolution` VALUES (
  1,
  'Se verificó el uso de fondos y se encontró dentro de lo aprobado',
  '2023-08-25 14:00:00',
  55,
  1
);
```

---

### Tablas de Configuración y Soporte

#### 15. `cf_condition_types`
**Propósito**: Define tipos de condiciones especiales que pueden aplicarse a proyectos (requisitos de empleo, ubicación, etc.), especialmente para beneficios gubernamentales.

```sql
CREATE TABLE `cf_condition_types` (
  `condition_typeid` INT,              -- ID tipo condición
  `name` VARCHAR(100),                 -- Nombre descriptivo
  PRIMARY KEY (`condition_typeid`)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO `cf_condition_types` VALUES 
(1, 'Número mínimo de empleos'),
(2, 'Ubicación geográfica'),
(3, 'Sector económico prioritario');
```

---

#### 16. `cf_project_conditions`
**Propósito**: Almacena condiciones específicas aplicadas a cada proyecto, especialmente aquellas requeridas para beneficios gubernamentales.

```sql
CREATE TABLE `cf_project_conditions` (
  `conditionid` INT,                   -- ID condición
  `description` VARCHAR(300),          -- Descripción completa
  `condition_typeid` INT,              -- Tipo de condición
  `value` VARCHAR(100),                -- Valor requerido (ej: '20' empleos)
  `approval_status` VARCHAR(20),       -- Estado: 'pending', 'verified', 'rejected'
  `approval_date` DATETIME,            -- Fecha de verificación
  `approval_voteid` INT,               -- ID votación de aprobación (si aplica)
  `approved_by` INT,                   -- ID validador
  `projectid` INT,                     -- ID proyecto
  PRIMARY KEY (`conditionid`)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO `cf_project_conditions` VALUES (
  1,
  'Generar al menos 20 empleos directos en la zona norte',
  1,
  '20',
  'verified',
  '2023-06-15 00:00:00',
  33,
  60,
  1001
);
```

---

#### 17. `cf_project_versions`
**Propósito**: Mantiene historial de versiones de cada proyecto, permitiendo seguimiento de cambios y aprobaciones iterativas.

```sql
CREATE TABLE `cf_project_versions` (
  `versionid` INT,                     -- ID versión
  `versionnum` INT,                    -- Número de versión (ej: 1, 2, 3)
  `changes` TEXT,                      -- Descripción de cambios
  `creationdate` DATETIME,             -- Fecha de creación
  `approved` BIT,                      -- Aprobado (1/0)
  `projectid` INT,                     -- ID proyecto
  PRIMARY KEY (`versionid`)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO `cf_project_versions` VALUES (
  1,
  2,
  'Ajuste en plan de desembolsos y cronograma',
  '2023-05-20 11:30:00',
  1,
  1001
);
```

---

#### 18. `cf_goverment_conditions`
**Propósito**: Condiciones específicas establecidas por el gobierno para proyectos con beneficios especiales.

```sql
CREATE TABLE `cf_goverment_conditions` (
  `conditionid` INT,                   -- ID condición
  `description` VARCHAR(300),          -- Descripción detallada
  `value` VARCHAR(100),                -- Valor requerido
  `approved` BIT,                      -- Cumplimiento verificado (1/0)
  `condition_typeid` INT,              -- Tipo de condición
  `projectid` INT,                     -- ID proyecto
  PRIMARY KEY (`conditionid`)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO `cf_goverment_conditions` VALUES (
  1,
  'Mantener operaciones en zona franca por 5 años',
  '5',
  0,
  4,
  1001
);
```

---

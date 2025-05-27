# Documentación del Módulo de Solicitudes e Integraciones – Voto Pura Vida

## Tablas Principales

### 1. `vpv_request_type`
**Propósito**: Catalogar los distintos tipos de solicitudes que puede generar un usuario (p. ej. `identity_validation`, `mfa_setup`).  
**Cumple con**: Flexibilidad para añadir nuevos flujos sin alterar `vpv_requests`.

```sql
CREATE TABLE `vpv_request_type` (
  `requestTypeId` TINYINT       PRIMARY KEY,
  `name`         VARCHAR(60)    NOT NULL,   -- Identificador del tipo
  `enabled`      BIT            DEFAULT 1   -- 1=Activo, 0=Inactivo
);
```

### 2. vpv_requests
**Propósito**: Registrar cada solicitud de validación iniciada por un usuario.
**Cumple con**: Trazabilidad de flujos (MFA, prueba de vida, documentos, etc.).

```sql
CREATE TABLE `vpv_requests` (
  `requestId`     INT           PRIMARY KEY,
  `data`          VARCHAR(255)  NOT NULL,   -- JSON o referencia a datos
  `date`          DATETIME      NOT NULL,   -- Fecha de creación
  `validators`    TINYINT       NOT NULL,   -- Cantidad requerida
  `status`        SMALLINT      NOT NULL,   -- 0=Pendiente,1=En Proceso,2=Completada,3=Rechazada
  `checksum`      VARBINARY(255) NOT NULL,  -- Hash para integridad
  `requestTypeId` TINYINT       NOT NULL,   -- FK → `vpv_request_type`
  `userId`        INT           NOT NULL,   -- FK → `citizen` / `foreign_citizen`
  FOREIGN KEY (`requestTypeId`) REFERENCES `vpv_request_type`(`requestTypeId`),
  FOREIGN KEY (`userId`)        REFERENCES `citizen`(`id`)
);
```

### 3. vpv_request_votes
**Propósito**: Guardar el voto de cada validador sobre una solicitud.
**Cumple con**: Aprobación mancomunada y registro de decisiones.
```sql
CREATE TABLE `vpv_request_votes` (
  `requestVoteId`   INT           PRIMARY KEY,
  `voteDate`        DATETIME      NOT NULL,   -- Fecha en que el validador emitió su voto
  `vote`            VARBINARY(255) NOT NULL,  -- E.g. 0x01=aprobado,0x00=rechazado
  `digitalSignature`VARBINARY(255) NULL,      -- Firma del validador
  `checksum`        VARBINARY(255) NOT NULL,  -- Hash de la decisión
  `validatorId`     INT           NOT NULL,   -- FK → `citizen` o tabla de validadores
  `requestId`       INT           NOT NULL,   -- FK → `vpv_requests`
  FOREIGN KEY (`validatorId`) REFERENCES `citizen`(`id`),
  FOREIGN KEY (`requestId`)   REFERENCES `vpv_requests`(`requestId`)
);
```

### 4. vpv_identity_validations
**Propósito**: Registrar el resultado de la validación de identidad (API externa).
**Cumple con**: Trazabilidad de fuente oficial (TSE/Registro Civil).
```sql
CREATE TABLE `vpv_identity_validations` (
  `validationId`     INT           PRIMARY KEY,
  `approved`         BIT           NOT NULL,    -- 1=Válido, 0=Rechazado
  `validation_date`  DATETIME      NOT NULL,    -- Fecha del chequeo
  `observations`     VARCHAR(255)  NULL,        -- Notas o comentarios
  `rejected_data`    VARCHAR(255)  NULL,        -- Datos rechazados (motivo)
  `next_validation`  DATE          NULL,        -- Fecha sugerida para revalidación
  `requestId`        INT           NOT NULL,    -- FK → `vpv_requests`
  `apiId`            SMALLINT      NOT NULL,    -- FK → `api_integrations`
  FOREIGN KEY (`requestId`) REFERENCES `vpv_requests`(`requestId`),
  FOREIGN KEY (`apiId`)       REFERENCES `api_integrations`(`apiId`)
);
```

### 5. vpv_groups
**Propósito**: Definir grupos o segmentaciones de usuarios (instituciones, comisiones).
**Cumple con**: Segmentación para votaciones y ponderación.
```sql
CREATE TABLE `vpv_groups` (
  `groupId`       INT           PRIMARY KEY,
  `description`   VARCHAR(100)  NOT NULL,   -- Descripción del grupo
  `name`          VARCHAR(50)   NOT NULL,   -- Nombre corto
  `groupTypeId`   TINYINT       NOT NULL,   -- FK → `vpv_group_type`
  FOREIGN KEY (`groupTypeId`) REFERENCES `vpv_group_type`(`groupTypeId`)
);
```

### 6. vpv_group_type
**Propósito**: Catalogar tipos de grupos (e.g. institutional, operational).
**Cumple con**: Diferenciación de la naturaleza de cada agrupación.
```sql
CREATE TABLE `vpv_group_type` (
  `groupTypeId` TINYINT      PRIMARY KEY,
  `name`        VARCHAR(60)  NOT NULL   -- Nombre del tipo
);
```
##Tablas de Integración con APIs Externas
### 7. api_providers
**Propósito**: Registrar proveedores externos de servicios (TSE, Registro Civil).
**Cumple con**: Gestión de múltiples fuentes de validación.
```sql
CREATE TABLE `api_providers` (
  `providerId`           INT           PRIMARY KEY,
  `brand_name`           VARCHAR(100)  NOT NULL,  -- Nombre comercial
  `legal_name`           VARCHAR(150)  NOT NULL,  -- Razón social
  `legal_identification` VARCHAR(50)   NOT NULL,  -- Cédula/RUC
  `enabled`              BIT           DEFAULT 1   -- 1=Activo, 0=Inactivo
);
```
### 8. api_integrations
**Propósito**: Configurar credenciales y parámetros de integración con cada proveedor.
**Cumple con**: Seguridad y trazabilidad de llamadas a APIs.
```sql
CREATE TABLE `api_integrations` (
  `apiId`         SMALLINT      PRIMARY KEY,
  `name`          VARCHAR(80)   NOT NULL,   -- Identificador interno
  `public_key`    VARBINARY(255) NULL,      -- Clave pública
  `private_key`   VARBINARY(255) NULL,      -- Clave privada (segura)
  `url`           VARCHAR(200)  NULL,       -- Endpoint de la API
  `creation_date` DATETIME      DEFAULT GETDATE(),
  `last_update`   DATETIME      DEFAULT GETDATE(),
  `enabled`       BIT           DEFAULT 1,
  `idProvider`    INT           NOT NULL,   -- FK → `api_providers`
  FOREIGN KEY (`idProvider`) REFERENCES `api_providers`(`providerId`)
);
```

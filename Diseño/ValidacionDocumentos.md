# Documentación de la validación de documentos digitales

## Tablas principales

### Gestión de Documentos
#### vpv_document_type
**Propósito**: Catálogo de tipos de documentos soportados (DNI, pasaportes, facturas, etc.)
```sql
CREATE TABLE [vpv_document_type] (
  [document_typeid] INT             PRIMARY KEY ,
  [name]            VARCHAR(100)    NOT NULL,       --Nombre del tipo de documento
  [description]     TEXT            NOT NULL,       --Descripción del tipo
  [enabled]         BIT             NOT NULL        --Si el tipo de documento está activo
);
```

#### vpv_digital_documents
**Propósito**: Almacena todos los documentos subidos al sistema con:
- Metadatos técnicos (hash, URL de almacenamiento)
- Estados de validación (IA/humano)
- Relación con solicitudes de validación
```sql
CREATE TABLE [vpv_digital_documents] (
  [documentid]              INT             PRIMARY KEY,
  [name]                    TEXT            NOT NULL,
  [url]                     TEXT            NOT NULL, --Ubicación del archivo
  [hash]                    TEXT            NOT NULL,
  [metadata]                JSONB           NOT NULL, --Datos del archivo
  [ai_processed]            BIT             NOT NULL, --Verifica si el documento ha sido procesado por la IA
  [ai_response]             TEXT            NULL,     --Registra la respuesta de la IA sobre el documento
  [manually_validated]      BIT             NOT NULL, --Verifica si el  documento fue validado por un humano
  [validation_date]         DATETIME        NULL,     --Registra la fecha de validación del documento
  [requestid]               INT             NOT NULL, --FK -> vpv_validation_request(requestid)
  [document_typeid]         INT             NOT NULL, --FK -> vpv_document_type(socument_typeid)
  FOREIGN KEY (requestid)       REFERENCES vpv_validation_request(requestid),
  FOREIGN KEY (document_typeid) REFERENCES vpv_document_type(document_typeid)
);
```

### Componentes de IA
#### ai_service
**Propósito**: Registro de servicios de IA disponibles en el sistema
```sql
CREATE TABLE [ai_service] (
  [ai_serviceid]        INT             PRIMARY KEY,
  [name]                VARCHAR(100)    NOT NULL,
  [description]         TEXT            NOT NULL,
  [endpoint_base]       TEXT            NOT NULL, --Endpoint base
  [version]             TEXT            NOT NULL, --Versión del modelo
  [provider]            TEXT            NOT NULL, --Proveedor del servicio(AWS, Azure, etc)
);
```

#### vpv_ai_interactions
**Propósito**: Auditoría detallada de cada llamada a IA
```sql
CREATE TABLE [vpv_ai_interactions] (
  [interactionid]   INT         PRIMARY KEY,
  [endpoint]        TEXT        NOT NULL,
  [payload]         JSONB       NOT NULL, --Guarda la información enviada a la IA
  [response]        JSONB       NOT NULL, --Registra la respuesta recibida por la IA
  [status_code]     BIT         NOT NULL,
  [duration_ms]     BIT         NOT NULL, --Registra la duración en milisegundos de respuesta
  [date]            DATETIME    NOT NULL,
  [requestid]       INT         NOT NULL, --FK -> vpv_validation_request(requestid)
  [ai_serviceid]    INT         NOT NULL, --FK -> ai_service(ai_serviceid)
  FOREIGN KEY (requestid)       REFERENCES vpv_validation_request(requestid),
  FOREIGN KEY (ai_serviceid)    REFERENCES ai_service(ai_serviceid)
);
```

### Workflow de Validación
#### vpv_validation_types
**Propósito**: Tipos de validaciones a los documentos
```sql
CREATE TABLE [vpv_validation_types] (
  [validation_typeid]       INT             PRIMARY KEY,
  [name]                    VARCHAR(50)     NOT NULL,
  [description]             TEXT            NOT NULL,
  [enabled]                 BIT             NOT NULL
);
```

#### vpv_validation_request
**Propósito**: Punto central para gestionar solicitudes de validación
```sql
CREATE TABLE [vpv_validation_request] (
  [requestid]               INT         PRIMARY KEY,
  [creation_date]           DATETIME    NOT NULL, --Fecha de la creación de la solicitud
  [finish_date]             DATETIME    NULL,     --Fecha de finalización de la validación
  [global_result]           TEXT        NULL,     --Resutado de la validación
  [validation_typeid]       INT         NOT NULL, --FK -> vpv_validation_types(validation_typeid)
  [userid]                  INT         NOT NULL, --FK -> vpv_users(userid)
  [processid]               INT         NOT NULL, --FK -> vpv_validation_process(processid)
  FOREIGN KEY (validation_typeid)   REFERENCES vpv_validation_types(validation_typeid),
  FOREIGN KEY (userid)              REFERENCES vpv_users(userid),
  FOREIGN KEY (processid)           REFERENCES vpv_validation_process(processid)
);
```

#### vpv_validation_process
**Propósito**: Define flujos completos de validación
```sql
CREATE TABLE [vpv_validation_process] (
  [processid]           INT             PRIMARY KEY,
  [name]                VARCHAR(100)    NOT NULL,
  [description]         TEXT            NOT NULL,
  [enabled]             BIT             NOT NULL,
  [result]              BIT             NOT NULL,
  [schedule_interval]   VARCHAR(100)    NOT NULL,
  [startTime]           DATETIME        NOT NULL,
  [ai_validatorid]      INT             NULL,     --FK -> ai_service(ai_serviceid)
  [human_validatorid]   INT             NULL,     --FK -> vpv_human_validators(validatorid)
  FOREIGN KEY (ai_validatorid)      REFERENCES ai_service(ai_serviceid),
  FOREIGN KEY (human_validatorid)   REFERENCES vpv_human_validators(validatorid)
);
```

#### vpv_validation_process_steps
**Propósito**: Pasos individuales dentro de un proceso
```sql
CREATE TABLE [vpv_validation_process_steps] (
  [process_stepid]  INT     PRIMARY KEY,
  [order]           INT     NOT NULL,
  [required]        BIT     NOT NULL,
  [arguments]       JSON    NOT NULL, --Argumentos del workflow formato JSON
  [operatorid]      INT     NOT NULL, --FK -> vpv_validation_operator_type(operatorid)
  [processid]       INT     NOT NULL, --FK -> vpv_validation_process(processid)
  FOREIGN KEY (operatorid)  REFERENCES vpv_validation_operator_type(operatorid),
  FOREIGN KEY (processid)   REFERENCES vpv_validation_process(processid)
);
```

#### vpv_validation_operator_type
**Propósito**: Clasifica operadores de validación
```sql
CREATE TABLE [vpv_vaidation_operator_type] (
  [operatorid]      INT             PRIMARY KEY,
  [name]            VARCHAR(100)    NOT NULL,
  [description]     TEXT            NOT NULL,
  [enabled]         BIT             NOT NULL
);
```

#### vpv_validation_audit
**Propósito**: Registro inmutable de cada acción de validación. Registrá quien validó, el resultado y la relación con el paso específico
```sql
CREATE TABLE [vpv_validation_audit] (
  [auditid]     INT         PRIMARY KEY,
  [result]      BIT         NOT NULL,
  [comments]    TEXT        NOT NULL,
  [startTime]   DATETIME    NOT NULL,
  [requestid]   INT         NOT NULL, --FK -> vpv_validation_request(requestid)
  [processid]   INT         NOT NULL, --FK -> vpv_validation_process(processid)
  FOREIGN KEY (requestid) REFERENCES vpv_validation_request(requestid),
  FOREIGN KEY (processid) REFERENCES vpv_validation_process(processid)
);
```

### Gestión de validadores
#### vpv_human_validators
**Propósito**: Catálogo de validadores humanos autorizados en el sistema. Guarda al usuario relacionado al validador
```sql
CREATE TABLE [vpv_human_validators] (
  [validatorid] INT     PRIMARY KEY,
  [name]        TEXT    NOT NULL,
  [public_key]  TEXT    NOT NULL, --Llave pública del validador
  [enabled]     BIT     NOT NULL,
  [userid]      INT     NOT NULL, --FK -> vpv_users(userid)
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);
```
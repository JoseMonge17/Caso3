# Documentación de la validación de documentos digitales

## Tablas principales

### Gestión de Documentos
#### vpv_document_type
**Propósito**: Catálogo de tipos de documentos soportados (DNI, pasaportes, facturas, etc.) al igual que los parámetros para un workflow en Airflow
- Schedule interval es que tan frecuente sucede el workflow (diario, mensual, cada 15 dias, etc). Se puede dejar vacio.
```sql
CREATE TABLE [vpv_document_type] (
  [document_typeid] INT,
  [name] VARCHAR(100),
  [description] TEXT,
  [enabled] BIT,
  [workflowid] INT,
  [workflow_name] VARCHAR(100),
  [parameters] JSON,
  [schedule_interval] VARCHAR(15),
  [order] INT,
  [url] TEXT,
  PRIMARY KEY ([document_typeid])
);
```

#### vpv_digital_documents
**Propósito**: Almacena todos los documentos subidos al sistema con:
- Metadatos técnicos (hash, URL de almacenamiento)
- Estados de validación (IA/humano)
- Relación con solicitudes de validación
```sql
CREATE TABLE `vpv_digital_documents` (
  `documentid` INT,
  `name` VARCHAR(150),
  `url` TEXT,
  `hash` TEXT,
  `metadata` JSONB,
  `validation_date` DATETIME,
  `requestid` INT,
  `document_typeid` INT,
  PRIMARY KEY (`documentid`),
  FOREIGN KEY (`requestid`) REFERENCES `vpv_validation_request`(`requestid`),
  FOREIGN KEY (`document_typeid`) REFERENCES `vpv_document_type`(`document_typeid`)
);
```

### Componentes de IA


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

#### vpv_validation_request_log
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

#### vpv_validation_process_log
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

#### vpv_validation_process_steps_log
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

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
CREATE TABLE [vpv_digital_documents] (
  [documentid] INT,
  [name] VARCHAR(150),
  [url] TEXT,
  [hash] TEXT,
  [metadata] JSONB,
  [validation_date] DATETIME,
  [requestid] INT,
  [document_typeid] INT,
  PRIMARY KEY ([documentid]),
  CONSTRAINT [FK_vpv_digital_documents.requestid]
    FOREIGN KEY ([requestid])
      REFERENCES [vpv_validation_request]([requestid]),
  CONSTRAINT [FK_vpv_digital_documents.document_typeid]
    FOREIGN KEY ([document_typeid])
      REFERENCES [vpv_document_type]([document_typeid])
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
**Propósito**: Define flujos completos de validación llamados workflows
```sql
CREATE TABLE [vpv_validation_process_log] (
  [processid] INT,
  [name] VARCHAR(100),
  [description] VARCHAR(200),
  [enabled] BIT,
  [schedule_interval] VARCHAR(15),
  [parameters] JSON,
  [startTime] DATETIME,
  [result] INT,
  PRIMARY KEY ([processid]),
  CONSTRAINT [FK_vpv_validation_process_log.result]
    FOREIGN KEY ([result])
      REFERENCES [vpv_validation_result_type]([result_typeid])
);
```

#### vpv_validation_result_type
**Propósito**: Documentar los tipos de resultados del workflow
```sql
CREATE TABLE [vpv_validation_result_type] (
  [result_typeid] INT,
  [name] VARCHAR(50),
  [description] VARCHAR(200),
  PRIMARY KEY ([result_typeid])
);
```

#### vpv_validation_process_steps_log
**Propósito**: Pasos individuales dentro de un proceso
```sql
CREATE TABLE [vpv_validation_process_steps_log] (
  [process_stepid] INT,
  [order] INT,
  [required] BIT,
  [processid] INT,
  PRIMARY KEY ([process_stepid])
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



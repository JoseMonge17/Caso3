# Documentación del Sistema de Entidades

## Tablas Principales

### 1. `vpv_entities - Entidades Registradas`
**Propósito**: Almacenar información legal de organizaciones, empresas o instituciones que participan en el sistema.

```sql
CREATE TABLE vpv_entities (
  entity_id         INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  legal_name        VARCHAR(255)   NOT NULL,
  public_name       VARCHAR(255)   NOT NULL,
  legal_id_type     VARCHAR(50)    NOT NULL,
  legal_id_number   VARCHAR(50)    NOT NULL,
  entity_type       VARCHAR(50)    NOT NULL,
  registration_date DATETIME       NOT NULL,
  status            VARCHAR(20)    NOT NULL,
  is_current        BIT            NOT NULL DEFAULT 1
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_entities 
(entity_id, legal_name, public_name, legal_id_type, legal_id_number, entity_type, registration_date, status, is_current) 
VALUES 
(1, 'Soluciones Electrónicas S.A.', 'VotoDigital', 'Cédula Jurídica', '3-101-234567', 'TECH_COMPANY', '2023-01-15 00:00:00', 'ACTIVE', 1);
```

legal_name vs public_name: Distingue entre nombre legal y nombre comercial/marca

legal_id_type y legal_id_number validan identidad legal (cédula jurídica, DIMEX, etc.)

entity_type clasifica entidades (GOVERNMENT, NGO, PRIVATE_COMPANY)

status controla ciclo de vida (PENDING, ACTIVE, SUSPENDED, DELETED)

is_current permite mantener histórico de cambios (actual vs versiones anteriores)

Fechas de registro permiten análisis temporal de crecimiento

---

### 2. `vpv_entity_representative - Representantes Legales`
**Propósito**: Establecer relaciones de representación entre usuarios y entidades con roles específicos.

```sql
CREATE TABLE vpv_entity_representative (
  rep_id               INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  role                 VARCHAR(255)   NOT NULL,
  department           VARCHAR(100)   NOT NULL,
  proof_doc_hash       VARBINARY(255) NOT NULL,
  start_date           DATETIME       NOT NULL,
  end_date             DATETIME       NOT NULL,
  is_primary           BIT            NOT NULL DEFAULT 1,
  representation_hash  VARBINARY(255) NOT NULL,
  entity_id            INT            NOT NULL,
  user_id              INT            NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id),
  FOREIGN KEY (user_id)   REFERENCES vpv_users(userid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_entity_representative 
(rep_id, role, department, proof_doc_hash, start_date, end_date, is_primary, representation_hash, entity_id, user_id) 
VALUES 
(1, 'Director Ejecutivo', 'Gestión', 0x4a3b..., '2023-01-16 00:00:00', '2025-01-16 00:00:00', 1, 0x89fe..., 1, 1001);
```

proof_doc_hash: Hash del documento que acredita la representación legal

representation_hash: Firma digital del acta de nombramiento

is_primary identifica al representante principal/autorizado

Campos de fecha permiten representaciones temporales/por períodos

department especifica área de responsabilidad dentro de la entidad

Relación muchos-a-muchos implícita (un usuario puede representar múltiples entidades)

---

### 3. `vpv_entity_proposals - Propuestas de Entidades`
**Propósito**: Gestionar propuestas formales presentadas por entidades para votación o consideración.

```sql
CREATE TABLE vpv_entity_proposals (
  proposal_id      INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  proposal_type    VARCHAR(50)    NOT NULL,
  tittle           VARCHAR(255)   NOT NULL,
  summary          VARCHAR(255)   NOT NULL,
  impact_analysis  VARCHAR(255)   NOT NULL,
  submission_date  DATETIME       NOT NULL,
  status           VARCHAR(50)    NOT NULL,
  entity_id        INT            NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_entity_proposals 
(proposal_id, proposal_type, tittle, summary, impact_analysis, submission_date, status, entity_id) 
VALUES 
(1, 'PROJECT_FUNDING', 'Plataforma de Voto Municipal', 'Sistema para elecciones locales...', 'Incrementará participación en 30%...', '2023-05-01 09:00:00', 'UNDER_REVIEW', 1);
```

proposal_type clasifica propuestas (LEGAL_CHANGE, PROJECT_FUNDING, POLICY)

impact_analysis resume beneficios/impactos esperados

Flujo de estados: DRAFT → UNDER_REVIEW → APPROVED/REJECTED → IMPLEMENTED

Relación con entidad garantiza trazabilidad de autoría

Campos obligatorios aseguran completitud de información

---

### 4. `vpv_entity_access_controls - Controles de Acceso`
**Propósito**: Gestionar permisos granulares para operaciones sobre entidades.

```sql
CREATE TABLE vpv_entity_access_controls (
  access_id      INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  permission_type VARCHAR(50)   NOT NULL,
  granted_date    DATETIME      NOT NULL,
  expiration_date DATETIME      NOT NULL,
  signature       VARBINARY(255) NOT NULL,
  version         INT           NOT NULL,
  entity_id       INT           NOT NULL,
  user_id         INT           NOT NULL,
  FOREIGN KEY (user_id)   REFERENCES vpv_users(userid),
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_entity_access_controls 
(access_id, permission_type, granted_date, expiration_date, signature, version, entity_id, user_id) 
VALUES 
(1, 'FULL_MANAGEMENT', '2023-01-16 00:00:00', '2024-01-16 00:00:00', 0x5d3a..., 1, 1, 1001);
```

permission_type: Define alcance (VIEW, EDIT, APPROVE, FULL_MANAGEMENT)

signature: Firma digital de quien otorga el permiso

version: Permite evolución de estructuras de permisos

Fechas de vigencia automatizan revocación

Combina seguridad RBAC (Roles) y ABAC (Atributos)

Auditoría completa con firmas digitales

---

### 5. `vpv_entity_audit_log - Auditoría de Entidades`
**Propósito**: Registrar cambios críticos en entidades para trazabilidad y cumplimiento.

```sql
CREATE TABLE vpv_entity_audit_log (
  log_id              INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  action_type         VARCHAR(50)    NOT NULL,
  action_date         DATETIME       NOT NULL,
  performed_by_user   INT            NOT NULL,
  ip_address          VARBINARY(255) NOT NULL,
  transaction_hash    VARBINARY(255) NOT NULL,
  version             INT            NOT NULL,
  entity_id           INT            NOT NULL,
  FOREIGN KEY (performed_by_user) REFERENCES vpv_users(userid),
  FOREIGN KEY (entity_id)         REFERENCES vpv_entities(entity_id)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_entity_audit_log 
(log_id, action_type, action_date, performed_by_user, ip_address, transaction_hash, version, entity_id) 
VALUES 
(1, 'STATUS_CHANGE', '2023-02-01 14:30:00', 1001, 0x8912..., 0x7f2e..., 1, 1);
```

action_type: Clasifica operaciones (CREATE, UPDATE, STATUS_CHANGE)

transaction_hash: Identificador único inmutable de la transacción

ip_address hasheado: Balance entre trazabilidad y privacidad

version: Soporta historial de cambios (type 2 SCD)

Cumple con regulaciones de no repudio y auditoría

Permite reconstrucción forense de incidentes

---

### 6. `vpv_entity_validations - Validaciones de Entidades`
**Propósito**: Gestionar procesos de verificación formal de entidades (KYC/AML).

```sql
CREATE TABLE vpv_entity_validations (
  validation_id      INT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  validation_type    VARCHAR(255) NOT NULL,
  start_date         DATETIME     NOT NULL,
  end_date           DATETIME     NOT NULL,
  status             VARCHAR(20)  NOT NULL,
  required_approvals INT          NOT NULL,
  current_approvals  INT          NOT NULL,
  version            INT          NOT NULL,
  entity_id          INT          NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_entity_validations 
(validation_id, validation_type, start_date, end_date, status, required_approvals, current_approvals, version, entity_id) 
VALUES 
(1, 'FULL_KYC', '2023-01-17 00:00:00', '2023-02-17 00:00:00', 'PENDING', 3, 0, 1, 1);
```

validation_type: Diferentes niveles de validación (BASIC, FULL, ENHANCED)

required_approvals: Implementa esquema M-de-N aprobaciones

current_approvals: Contador en tiempo real

end_date: Plazo máximo para completar validación

status (PENDING, APPROVED, REJECTED, EXPIRED)

Relacionado con vpv_validations_approvals para detalles

---

#### 7. `vpv_entiity_documents - Documentos de Entidades`
**Propósito**: Almacenar documentos legales asociados a entidades.

```sql
CREATE TABLE vpv_entiity_documents (
  document_id       INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  document_type     VARCHAR(100)   NOT NULL,
  document_hash     VARBINARY(255) NOT NULL,
  storage_reference VARCHAR(255)   NOT NULL,
  upload_date       DATETIME       NOT NULL,
  version           INT            NOT NULL,
  entity_id         INT            NOT NULL,
  FOREIGN KEY (entity_id)         REFERENCES vpv_entities(entity_id)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_entiity_documents 
(document_id, document_type, document_hash, storage_reference, upload_date, version, entity_id) 
VALUES 
(1, 'ESTATUTOS_SOCIALES', 0x3a4b..., 'S3://documents/ent1/estatutos_v1.pdf', '2023-01-16 00:00:00', 1, 1);
```

document_type: Clasificación (ESTATUTOS, IDENTIFICACION, ACTA_CONSTITUTIVA)

document_hash: Hash criptográfico del contenido para integridad

storage_reference: URI/ubicación segura del documento original

version: Control de versiones documentales

Soporta documentos en cualquier formato (PDF, XML, imágenes)

Base para verificaciones de cumplimiento legal

---

#### 8. `vpv_validations_approvals - Aprobaciones de Validación`
**Propósito**: Registrar decisiones individuales en procesos de validación.

```sql
CREATE TABLE vpv_validations_approvals (
  approval_id          INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  validator_id         INT            NOT NULL,
  approval_date        DATETIME       NOT NULL,
  approval_result      VARCHAR(20)    NOT NULL,
  comments             VARCHAR(255)   NOT NULL,
  validator_signature  VARBINARY(255) NOT NULL,
  version              INT            NOT NULL,
  validation_id        INT            NOT NULL,
  FOREIGN KEY (validation_id) REFERENCES vpv_entity_validations(validation_id)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_validations_approvals 
(approval_id, validator_id, approval_date, approval_result, comments, validator_signature, version, validation_id) 
VALUES 
(1, 2001, '2023-01-25 09:30:00', 'APPROVED', 'Documentación completa y válida', 0x9e8f..., 1, 1);
```

validator_signature: Firma digital que asegura no repudio

comments: Justificación de la decisión

approval_result (APPROVED, REJECTED, NEEDS_INFO)

Relación con vpv_entity_validations completa el flujo

version: Permite cambios en el formato de aprobación

Base para análisis de patrones de aprobación/rechazo

---


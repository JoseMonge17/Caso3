# Documentación del Sistema MFA

## Tablas Principales

### 1. `vpv_mfa_devices - Dispositivos de Autenticación`
**Propósito**: Registrar todos los dispositivos asociados a MFA para un usuario.

```sql
CREATE TABLE vpv_mfa_devices (
  deviceid             INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  userid               INT            NOT NULL,
  Campo                VARCHAR(50)    NOT NULL,
  device_name          VARCHAR(50)    NOT NULL,
  registration_date    DATETIME       NOT NULL,
  last_used_date       DATETIME       NOT NULL,
  device_status        VARCHAR(20)    NOT NULL,
  serial_hash          VARBINARY(255) NOT NULL,
  authentication_factor VARCHAR(50)   NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_mfa_devices 
(deviceid, userid, device_name, registration_date, last_used_date, device_status, serial_hash, authentication_factor) 
VALUES 
(1, 1001, 'iPhone 13 Pro', '2023-05-01 09:00:00', '2023-05-28 14:30:00', 'ACTIVE', 0x4a3b2c1d..., 'BIOMETRIC');
```

Almacena información de dispositivos asociados a MFA (móviles, tokens hardware, autenticadores)
authentication_factor especifica el tipo de autenticación (BIOMETRIC, TOTP, SMS, etc.)
serial_hash es un identificador único cifrado del dispositivo para prevenir duplicados
Campos de fecha permiten monitorear actividad y detectar dispositivos inactivos
Relación con vpv_users garantiza que cada dispositivo pertenece a un usuario válido

---

### 2. `vpv_auth_methods - Métodos de Autenticación`
**Propósito**: Gestionar los diferentes métodos de autenticación disponibles para cada usuario.

```sql
CREATE TABLE vpv_auth_methods (
  method_id          INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  userid             INT            NOT NULL,
  device_id          INT            NOT NULL,
  method_type        VARCHAR(50)    NOT NULL,
  identifier_hash    VARCHAR(255)   NOT NULL,
  registration_date  DATETIME       NOT NULL,
  last_used_date     DATETIME       NOT NULL,
  method_status      VARCHAR(20)    NOT NULL,
  priority           INT            NOT NULL,
  is_primary         BIT            NOT NULL DEFAULT 1,
  FOREIGN KEY (userid)    REFERENCES vpv_users(userid),
  FOREIGN KEY (device_id) REFERENCES vpv_mfa_devices(deviceid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_auth_methods 
(method_id, userid, device_id, method_type, identifier_hash, registration_date, last_used_date, method_status, priority, is_primary) 
VALUES 
(1, 1001, 1, 'BIOMETRIC', 0x89ab..., '2023-05-01 09:05:00', '2023-05-28 14:30:00', 'ACTIVE', 1, 1);
```

Establece una jerarquía de métodos mediante priority y marca el principal con is_primary
identifier_hash protege información sensible (como números de teléfono o emails)
Relaciona usuarios con dispositivos específicos de MFA
method_status permite habilitar/deshabilitar métodos sin eliminarlos
Auditoría completa con fechas de registro y último uso

---

### 3. `vpv_user_keys - Claves Criptográficas`
**Propósito**: Almacenamiento seguro de claves públicas y privadas cifradas.

```sql
CREATE TABLE vpv_user_keys (
  key_id           INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  userid           INT            NOT NULL,
  key_type         VARCHAR(50)    NOT NULL,
  algorithm        VARCHAR(50)    NOT NULL,
  creation_date    DATETIME       NOT NULL,
  expiration_date  DATETIME       NOT NULL,
  key_status       VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE',
  key_identifier   VARBINARY(255) NOT NULL,
  secure_storage   VARCHAR(255)   NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_user_keys 
(key_id, userid, key_type, algorithm, creation_date, expiration_date, key_status, key_identifier, secure_storage) 
VALUES 
(1, 1001, 'RSA', 'SHA-256', '2023-01-01 00:00:00', '2024-01-01 00:00:00', 'ACTIVE', 0x12ab...34cd, 'HSM_PROTECTED');
```

Soporta múltiples algoritmos criptográficos (RSA, ECC, Ed25519)
key_status controla el ciclo de vida (ACTIVE, EXPIRED, REVOKED)
secure_storage indica dónde se almacena la clave privada (HSM, KMS, etc.)
Fechas de creación y expiración permiten rotación automática
key_identifier es una referencia única para operaciones criptográficas

---

### 4. `vpv_auth_sessions - Sesiones Activas`
**Propósito**: Rastrear y controlar sesiones de usuario.

```sql
CREATE TABLE vpv_auth_sessions (
  sessionid           INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  method_id           INT            NOT NULL,
  device_id           INT            NOT NULL,
  start_date          DATETIME       NOT NULL,
  last_activity_date  DATETIME       NOT NULL,
  expiration_date     DATETIME       NOT NULL,
  session_status      VARCHAR(20)    NOT NULL,
  session_token_hash  VARBINARY(255) NOT NULL,
  used_factors        VARCHAR(255)   NOT NULL,
  device_hash         VARBINARY(255) NOT NULL,
  ip_hash             VARBINARY(255) NOT NULL,
  FOREIGN KEY (method_id) REFERENCES vpv_auth_methods(method_id),
  FOREIGN KEY (device_id) REFERENCES vpv_mfa_devices(deviceid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_auth_sessions 
(sessionid, method_id, device_id, start_date, last_activity_date, expiration_date, session_status, session_token_hash, used_factors, device_hash, ip_hash) 
VALUES 
(1, 1, 1, '2023-05-28 14:30:00', '2023-05-28 15:45:00', '2023-05-28 18:30:00', 'ACTIVE', 0x5d3a..., 'BIOMETRIC+PASSWORD', 0xa45b..., 0x8912...);
```

used_factors detalla los factores de autenticación utilizados
Hash de tokens, dispositivos e IPs protege la privacidad
session_status permite revocar sesiones manualmente
Campos temporales controlan duración máxima e inactividad
Relaciona sesiones con métodos y dispositivos específicos

---

### 5. `vpv_mfa_codes - Códigos de Verificación`
**Propósito**: Generar y gestionar códigos temporales para MFA o recuperación.

```sql
CREATE TABLE vpv_mfa_codes (
  code_it              INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  method_id            INT            NOT NULL,
  device_id            INT            NOT NULL,
  code_hash            VARBINARY(255) NOT NULL,
  generation_date      DATETIME       NOT NULL,
  expiration_date      DATETIME       NOT NULL,
  remaining_attempts   INT            NOT NULL,
  code_status          VARCHAR(20)    NOT NULL,
  request_context      VARCHAR(255)   NOT NULL,
  request_ip_hash      VARBINARY(255) NOT NULL,
  request_device_hash  VARBINARY(255) NOT NULL,
  FOREIGN KEY (method_id) REFERENCES vpv_auth_methods(method_id),
  FOREIGN KEY (device_id) REFERENCES vpv_mfa_devices(deviceid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_mfa_codes 
(code_it, method_id, device_id, code_hash, generation_date, expiration_date, remaining_attempts, code_status, request_context, request_ip_hash, request_device_hash) 
VALUES 
(1, 1, 1, 0x89fe..., '2023-05-28 14:35:00', '2023-05-28 14:45:00', 3, 'UNUSED', 'LOGIN_ATTEMPT', 0x4590..., 0x3f21...);
```

Códigos de un solo uso con vida corta controlada por expiration_date
remaining_attempts limita intentos fallidos antes de invalidar el código
request_context registra el propósito del código (login, recuperación, etc.)
Hashes de IP y dispositivo permiten detectar intentos sospechosos
code_status controla estado (UNUSED, USED, EXPIRED, INVALIDATED)

---

### 6. `vpv_digital_certificates - Certificados Digitales`
**Propósito**: Gestionar certificados digitales emitidos para usuarios o dispositivos.

```sql
CREATE TABLE vpv_digital_certificates (
  certificate_id       INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  key_id               INT            NOT NULL,
  issuer               VARCHAR(255)   NOT NULL,
  issue_date           DATETIME       NOT NULL,
  expiration_date      DATETIME       NOT NULL,
  serial_number        VARCHAR(20)    NOT NULL,
  certificate_status   VARCHAR(20)    NOT NULL,
  crl_distribution     VARCHAR(255)   NOT NULL,
  certificate_signature VARCHAR(255)  NOT NULL,
  FOREIGN KEY (key_id) REFERENCES vpv_user_keys(key_id)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_digital_certificates 
(certificate_id, key_id, issuer, issue_date, expiration_date, serial_number, certificate_status, crl_distribution, certificate_signature) 
VALUES 
(1, 1, 'CA_VOTOS_CR', '2023-01-01 00:00:00', '2024-01-01 00:00:00', 'SN-123456', 'VALID', 'https://crl.votos.cr', 0x7f2e...);
```

Vincula certificados con claves criptográficas mediante key_id
certificate_status controla validez (VALID, REVOKED, EXPIRED)
crl_distribution apunta a lista de certificados revocados
certificate_signature valida autenticidad del certificado
Soporta PKI (Infraestructura de Clave Pública) completa

---

#### 7. `vpv_recovery_tokens - Tokens de Recuperación`
**Propósito**: Gestionar tokens seguros para recuperación de cuentas o acceso.

```sql
CREATE TABLE vpv_recovery_tokens (
  token_id            INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  device_id           INT            NOT NULL,
  token_hash          VARCHAR(255)   NOT NULL,
  creation_date       DATETIME       NOT NULL,
  expiration_date     DATETIME       NOT NULL,
  delivery_method     VARCHAR(50)    NOT NULL,
  remaining_attemps   INT            NOT NULL,
  token_status        VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE',
  request_ip_hash     VARBINARY(255) NOT NULL,
  request_device_hash VARBINARY(255) NOT NULL,
  FOREIGN KEY (device_id) REFERENCES vpv_mfa_devices(deviceid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_recovery_tokens 
(token_id, device_id, token_hash, creation_date, expiration_date, delivery_method, remaining_attemps, token_status, request_ip_hash, request_device_hash) 
VALUES 
(1, 1, 0x3a4b..., '2023-05-28 10:00:00', '2023-05-28 12:00:00', 'EMAIL', 1, 'ACTIVE', 0x4590..., 0x3f21...);
```

Tokens de un solo uso con ventana temporal estrecha
delivery_method especifica cómo se envió el token (EMAIL, SMS, etc.)
remaining_attemps previene fuerza bruta
Hashes de solicitud permiten auditoría de seguridad
Vinculado a dispositivos específicos para mayor seguridad

---

#### 8. `vpv_security_questions - Preguntas de Seguridad`
**Propósito**: Almacenar preguntas de seguridad para verificación de identidad.

```sql
CREATE TABLE vpv_security_questions (
  question_id         INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  userid              INT            NOT NULL,
  question_hash       VARCHAR(255)   NOT NULL,
  answer_hash         VARCHAR(255)   NOT NULL,
  creation_date       DATETIME       NOT NULL,
  last_modified_date  DATETIME       NOT NULL,
  failed_attempts     INT            NOT NULL,
  question_status     VARCHAR(255)   NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_security_questions 
(question_id, userid, question_hash, answer_hash, creation_date, last_modified_date, failed_attempts, question_status) 
VALUES 
(1, 1001, 0x5c6d..., 0x7e8f..., '2023-01-01 00:00:00', '2023-05-01 00:00:00', 0, 'ACTIVE');
```

Preguntas y respuestas almacenadas como hashes para seguridad
failed_attempts bloquea temporalmente tras varios intentos fallidos
last_modified_date permite rotación periódica
question_status habilita/deshabilita preguntas individuales
Alternativa de autenticación cuando MFA no está disponible

---

#### 9. `vpv_auth_events - Eventos de Autenticación`
**Propósito**: Registrar eventos importantes del sistema de autenticación.

```sql
CREATE TABLE vpv_auth_events (
  event_id            INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  session_id          INT            NOT NULL,
  event_type          VARCHAR(50)    NOT NULL,
  event_date          DATETIME       NOT NULL,
  method_used         VARCHAR(50)    NOT NULL,
  success             BIT            NOT NULL,
  error_code          VARCHAR(100)   NOT NULL,
  ip_hash             VARBINARY(255) NOT NULL,
  device_hash         VARBINARY(255) NOT NULL,
  approx_location     VARCHAR(255)   NOT NULL,
  FOREIGN KEY (session_id) REFERENCES vpv_auth_sessions(sessionid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_auth_events 
(event_id, session_id, event_type, event_date, method_used, success, error_code, ip_hash, device_hash, approx_location) 
VALUES 
(1, 1, 'LOGIN', '2023-05-28 14:30:00', 'BIOMETRIC', 1, 'NONE', 0x4590..., 0x3f21..., 'San José, CR');
```

Auditoría completa de todos los eventos de autenticación
event_type clasifica eventos (LOGIN, LOGOUT, MFA_ATTEMPT, etc.)
success y error_code permiten análisis de problemas
approx_location deriva geolocalización de IP (hasheada)
Detección de patrones sospechosos o ataques

---

#### 10. `cvpv_cryptographic_operations - Operaciones Criptográficas`
**Propósito**: Registrar operaciones criptográficas para auditoría y no repudio.

```sql
CREATE TABLE vpv_cryptographic_operations (
  operation_id    INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  session_id      INT            NOT NULL,
  key_id          INT            NOT NULL,
  operation_type  VARCHAR(50)    NOT NULL,
  operation_date  DATETIME       NOT NULL,
  document_hash   VARCHAR(255)   NOT NULL,
  result_hash     VARCHAR(255)   NOT NULL,
  device_hash     VARCHAR(255)   NOT NULL,
  ip_hash         VARCHAR(255)   NOT NULL,
  op_signature    VARCHAR(255)   NOT NULL,
  FOREIGN KEY (key_id)     REFERENCES vpv_user_keys(key_id),
  FOREIGN KEY (session_id) REFERENCES vpv_auth_sessions(sessionid)
);
```

**Ejemplo**:
```sql
INSERT INTO vpv_cryptographic_operations 
(operation_id, session_id, key_id, operation_type, operation_date, document_hash, result_hash, device_hash, ip_hash, op_signature) 
VALUES 
(1, 1, 1, 'SIGN', '2023-05-28 15:00:00', 0xa3d4..., 0x7f2e..., 0xa45b..., 0x8912..., 0x9e8f...);
```

Registro inmutable de firmas, cifrados y otras operaciones
operation_type especifica acción (SIGN, VERIFY, ENCRYPT, DECRYPT)
Hashes de entrada/salida permiten verificación posterior
op_signature prueba quién realizó la operación
Cumple con requisitos legales de no repudio

---

#### 11. `vpv_key_rotation - Rotación de Claves`
**Propósito**: Gestionar el proceso de rotación de claves criptográficas.

```sql
CREATE TABLE vpv_key_rotation (
  rotation_id        INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  old_key_id         INT            NOT NULL,
  new_key_id         INT            NOT NULL,
  rotation_date      DATETIME       NOT NULL,
  rotation_reason    VARCHAR(100)   NOT NULL,
  initiated_by       VARCHAR(50)    NOT NULL,
  rotation_signature VARCHAR(255)   NOT NULL,
  FOREIGN KEY (old_key_id) REFERENCES vpv_user_keys(key_id),
  FOREIGN KEY (new_key_id) REFERENCES vpv_user_keys(key_id)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO vpv_key_rotation 
(rotation_id, old_key_id, new_key_id, rotation_date, rotation_reason, initiated_by, rotation_signature) 
VALUES 
(1, 1, 2, '2023-12-15 00:00:00', 'SCHEDULED_ROTATION', 'SYSTEM', 0x3b4c...);
```

Automatiza ciclo de vida de claves según políticas de seguridad
rotation_reason documenta por qué se rotó (compromiso, expiración, etc.)
initiated_by registra si fue automático o manual
rotation_signature valida la autenticidad del proceso
Mantiene relación entre clave antigua y nueva

---

#### 12. `vpv_key_backups - Copias de Seguridad de Claves`
**Propósito**: Gestionar copias de seguridad seguras de claves criptográficas.

```sql
CREATE TABLE vpv_key_backups (
  backup_id           INT            IDENTITY(1,1) PRIMARY KEY NOT NULL,
  key_id              INT            NOT NULL,
  backup_date         DATETIME       NOT NULL,
  storage_method      VARCHAR(50)    NOT NULL,
  backup_location_hash VARCHAR(255)  NOT NULL,
  backup_status       VARCHAR(20)    NOT NULL DEFAULT 'VALID',
  backup_signature    VARBINARY(255) NOT NULL,
  FOREIGN KEY (key_id) REFERENCES vpv_user_keys(key_id)
);
```

**Ejemplo de INSERT**:
```sql
INSERT INTO vpv_key_backups 
(backup_id, key_id, backup_date, storage_method, backup_location_hash, backup_status, backup_signature) 
VALUES 
(1, 1, '2023-06-01 00:00:00', 'HSM', 0x5d6e..., 'VALID', 0x8f9a...);
```

storage_method especifica ubicación segura (HSM, KMS, etc.)
backup_location_hash identifica la copia sin revelar ubicación
backup_status controla validez (VALID, COMPROMISED)
backup_signature verifica integridad de la copia
Permite recuperación ante desastres sin comprometer seguridad

---

![deepseek_mermaid_20250531_5ce098](https://github.com/user-attachments/assets/2e3daea6-0e1c-448d-8920-ccae68e7823f)



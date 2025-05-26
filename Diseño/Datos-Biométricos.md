# Documentación del Módulo Biométrico - Voto Pura Vida

## Tablas Principales

### 1. `vpv_biometric_devices`
**Propósito**: Registrar todos los dispositivos biométricos autorizados en el sistema.  
**Cumple con**:  
- Ley 8968 (Art. 10): Seguridad de infraestructura  
- ISO/IEC 19794: Certificación de dispositivos biométricos  

```sql
CREATE TABLE `vpv_biometric_devices` (
  `deviceid` INT,
  `manufacturer` VARCHAR(100),       -- Ej: "Neurotechnology"
  `model` VARCHAR(100),              -- Ej: "VeriFinger 12.0"
  `serial_number_hash` VARBINARY(255), -- Hash del número de serie (protege identidad del dispositivo)
  `device_type` VARCHAR(50),         -- "Huella", "Facial", etc.
  `certification` VARCHAR(100),      -- Ej: "FBI Appendix F"
  `registrationdate` DATETIME,       -- Cuando se registró en el sistema
  `lastcalibration` DATETIME,        -- Última calibración
  `active` BIT,                      -- 1=Disponible, 0=Inactivo
  PRIMARY KEY (`deviceid`)
);

-- Ejemplo de inserción:
INSERT INTO vpv_biometric_devices VALUES (
  1, 
  'Crossmatch', 
  'L SCAN 1000', 
  SHA2('SN-XYZ123', 256), 
  'Huella', 
  'ISO/IEC 19794-2', 
  '2024-01-15', 
  '2024-05-01', 
  1
);
```

### 2. `vpv_biometric_types`
**Propósito**: Catalogar tipos de datos biométricos aceptados.  
**Por qué existe**:  
- Los consentimientos se dan por categoría (huella, rostro), no por dato individual, es decir, cuando el usuario quiera actualizar alguna instancia, no tendrá que procesar el consentimeinto nuevamente 
- Cumple con el Artículo 5 de Ley 8968 (consentimiento informado por tipo de dato)  

```sql
CREATE TABLE `vpv_biometric_types` (
  `biotypeid` INT,
  `name` VARCHAR(60),                -- "Huella dactilar", "Reconocimiento facial"
  `description` VARCHAR(200),        -- Descripción detallada
  `enable` BIT,                      -- 1=Tipo activo, 0=Inactivo
  `legal_requirement` VARCHAR(100),  -- Ej: "Ley 8968 Art. 9"
  PRIMARY KEY (`biotypeid`)
);

-- Ejemplo:
INSERT INTO vpv_biometric_types VALUES (
  2, 
  'Reconocimiento Facial', 
  'Geometría facial para autenticación', 
  1, 
  'Ley 8968 Art. 9'
);
```

### 3. `vpv_biometric_consents`
**Propósito**: Registrar consentimientos de usuarios por tipo biométrico.  
**Dato clave**: Relaciona `userid` con `biotypeid` (no con datos específicos).  

```sql
CREATE TABLE `vpv_biometric_consents` (
  `consentid` INT,
  `consent_date` DATETIME,           -- Fecha de consentimiento
  `consent_text` TEXT,               -- Texto completo mostrado al usuario
  `consent_version` VARCHAR(20),     -- Versión del formulario (ej: "v1.2")
  `expiration_date` DATETIME,        -- Fecha de expiración (NULL=sin expiración)
  `active` BIT,                      -- 1=Vigente, 0=Revocado
  `revocation_date` DATETIME,        -- Cuando se revocó (si aplica)
  `revocation_reason` VARCHAR(200),  -- Motivo de revocación
  `userid` INT,                      -- Usuario que consintió
  `biotypeid` INT,                   -- Tipo biométrico consentido
  PRIMARY KEY (`consentid`),
  FOREIGN KEY (`biotypeid`) REFERENCES `vpv_biometric_types`(`biotypeid`)
);

-- Ejemplo:
INSERT INTO vpv_biometric_consents VALUES (
  101,
  '2024-05-20 14:00:00',
  'Autorizo el uso de mi huella dactilar para autenticación...',
  'v2.1',
  NULL,  -- No expira
  1,
  NULL,
  NULL,
  1001,
  1  -- Huella dactilar
);
```

## Flujo de Registro Biométrico

### 4. `vpv_biometric_media`
**Propósito**: Almacenar datos biométricos crudos (imágenes, videos).  
**Seguridad**:  
- `hashvalue` verifica integridad del archivo  
- `encryption_key_id` referencia llave de cifrado (no almacena datos planos)  

```sql
CREATE TABLE `vpv_biometric_media` (
  `biomediaid` INT,
  `filename` VARCHAR(100),           -- "huella_usuario1001.wsq"
  `storage_url` VARCHAR(255),        -- URL segura en S3/Blob Storage
  `file_size` INT,                   -- Tamaño en bytes
  `uploaddate` DATETIME,             -- Fecha de carga
  `hashvalue` VARBINARY(250),        -- SHA-256 del archivo
  `encryption_key_id` VARCHAR(255),  -- ID de llave en AWS KMS/Vault
  `is_original` BIT,                 -- 1=Dato original, 0=Derivado
  `userid` INT,                      -- Dueño del dato
  `biotypeid` INT,                   -- Tipo biométrico
  `mediatypeid` INT,                 -- Formato (imagen, video, etc.)
  PRIMARY KEY (`biomediaid`),
  FOREIGN KEY (`biotypeid`) REFERENCES `vpv_biometric_types`(`biotypeid`),
  FOREIGN KEY (`mediatypeid`) REFERENCES `vpv_mediatypes`(`mediatypeid`)
);

-- Ejemplo:
INSERT INTO vpv_biometric_media VALUES (
  5001,
  'face_user1001.jpg',
  'https://bucket.s3.amazonaws.com/biometric/face123.jpg',
  250000,
  NOW(),
  SHA2('file_content', 256),
  'aws-kms-key-xyz',
  1,
  1001,
  2,  -- Facial
  1   -- JPEG
);
```

### 5. `vpv_biometric_templates`
**Propósito**: Almacenar representaciones matemáticas de datos biométricos.  
**Ventaja**:  
- No guarda imágenes/videos originales  
- Templates son irreversibles (no se puede reconstruir el dato original)  

```sql
CREATE TABLE `vpv_biometric_templates` (
  `templateid` INT,
  `algorithmused` VARCHAR(60),       -- "ISO/IEC 19794-2"
  `templatedata` VARBINARY(2000),    -- Datos del template (cifrados)
  `qualityscore` DECIMAL(5,2),       -- 0-100% de calidad
  `creationdate` DATETIME,
  `version` INT,                     -- Versión del algoritmo
  `enable` BIT,                      -- 1=Activo, 0=Desactualizado
  `biomediaid` INT,                  -- Dato original asociado
  PRIMARY KEY (`templateid`),
  FOREIGN KEY (`biomediaid`) REFERENCES `vpv_biometric_media`(`biomediaid`)
);

-- Ejemplo:
INSERT INTO vpv_biometric_templates VALUES (
  3001,
  'ISO/IEC 19794-2',
  AES_ENCRYPT('template_binary_data', 'encryption_key'),
  98.5,
  NOW(),
  1,
  1,
  5001
);
```

## Auditoría y Seguridad

### 6. `vpv_biometric_audit`
**Propósito**: Registrar todas las acciones con datos biométricos.  
**Cumple con**:  
- Ley 8968 Art. 10 (trazabilidad)  
- GDPR Art. 30 (registro de procesamiento)  

```sql
CREATE TABLE `vpv_biometric_audit` (
  `auditid` INT,
  `event_date` DATETIME,             -- Cuando ocurrió
  `event_type` VARCHAR(20),          -- "ACCESS", "UPDATE", "DELETE"
  `description` VARCHAR(200),        -- "Autenticación fallida"
  `ip_address` VARBINARY(255),       -- IP cifrada del solicitante
  `metadata` TEXT,                   -- Datos técnicos adicionales
  `deviceid` INT,                    -- Dispositivo usado
  `biotypeid` INT,                   -- Tipo de dato afectado
  `userid` INT,                      -- Quién realizó la acción
  `affected_userid` INT,             -- A quién afecta (puede ser distinto)
  PRIMARY KEY (`auditid`),
  FOREIGN KEY (`deviceid`) REFERENCES `vpv_biometric_devices`(`deviceid`),
  FOREIGN KEY (`biotypeid`) REFERENCES `vpv_biometric_types`(`biotypeid`)
);

-- Ejemplo:
INSERT INTO vpv_biometric_audit VALUES (
  2001,
  NOW(),
  'ACCESS',
  'Consulta de template facial',
  AES_ENCRYPT('192.168.1.100', 'ip_key'),
  '{"service": "auth-api"}',
  1,
  2,
  9001,
  1001
);
```
## Pruebas de vida

### 7. `vpv_liveness_checks`
**Razón**: Evitar spoofing (suplantación con fotos/videos). Registra:

- Técnicas de detección de vivacidad
- Nivel de confianza
- Metadatos técnicos para auditoría  

```sql
-- Tabla de pruebas de vida (liveness)
CREATE TABLE vpv_liveness_checks (
  livenessid INT PRIMARY KEY AUTO_INCREMENT,
  userid INT NOT NULL,
  biomediaid INT NOT NULL,
  check_type VARCHAR(50) NOT NULL, -- 'Video', 'Movimiento', 'Desafío-respuesta', etc.
  check_date DATETIME NOT NULL,
  result BIT NOT NULL, -- 1=Pass, 0=Fail
  confidence_score DECIMAL(5,2),
  algorithm_used VARCHAR(100),
  device_info VARCHAR(200), -- Información del dispositivo usado
  requestid INT, -- Relación con la solicitud de validación
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (biomediaid) REFERENCES vpv_biometric_media(biomediaid),
  FOREIGN KEY (requestid) REFERENCES vpv_requests(requestid)
);


-- Ejemplo:
INSERT INTO vpv_liveness_checks
(livenessid, userid, biomediaid, check_type, check_date, 
 result, confidence_score, algorithm_used)
VALUES
(1, 1001, 1, 'Video', NOW(), 
 1, 99.2, 'FaceLiveness SDK 3.2');
```

### 8. `vpv_biometric_validations`
**Razón**: Registrar cada uso del dato biométrico para:

- Cumplir con derecho de acceso (Art. 7)
- Generar evidencia forense
- Monitorear falsos positivos/negativos

Sirve para confirmar que los rasgos biométricos coinciden con los registrados (huella, rostro, etc.).
``` sql
-- Tabla de resultados de validación biométrica
CREATE TABLE vpv_biometric_validations (
  validationid INT PRIMARY KEY AUTO_INCREMENT,
  userid INT NOT NULL,
  templateid INT NOT NULL,
  validation_date DATETIME NOT NULL,
  match_score DECIMAL(5,2),
  threshold DECIMAL(5,2),
  is_match BIT NOT NULL,
  device_used VARCHAR(100),
  ip_address VARBINARY(255), -- Cifrado
  session_id VARCHAR(100),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (templateid) REFERENCES vpv_biometric_templates(templateid)
);

--Validar biometría (al votar)

INSERT INTO vpv_biometric_validations 
  (userid, templateid, match_score, is_match) 
VALUES 
  (1001, 123, 99.2, 1); -- Huella coincide
```



## Consideraciones Legales Clave

1. **Consentimiento por categoría** (`biotypeid` en `vpv_biometric_consents`):  
   - Usuario autoriza "huellas dactilares" en general, no cada huella individual.  
   - Permite actualizar datos sin nuevo consentimiento (ej: nueva huella).  

2. **Minimización de datos**:  
   - `vpv_biometric_templates` no almacena imágenes originales.  
   - `ip_address` siempre cifrado.  

3. **Trazabilidad**:  
   - `vpv_biometric_audit` registra quién, cuándo y cómo accedió a datos.  
   - `vpv_biometric_device_usage` vincula dispositivos con operaciones.  

4. **Seguridad**:  
   - Dispositivos deben estar certificados (`vpv_biometric_devices.certification`).  
   - Plantillas cifradas (`templatedata VARBINARY`).  

Este diseño cumple con los principios de **privacidad desde el diseño** (Privacy by Design) y **protección de datos personales** según la normativa costarricense e internacional.
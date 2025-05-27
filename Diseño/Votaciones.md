# Documentación del Módulo de Solicitudes e Integraciones – Voto Pura Vida

## Tablas Principales

### vote_weight_groups  
**Propósito**: Asignar un peso diferencial a los votos según grupos poblacionales en una sesión de votación.  
**Cumple con**: “Se podrá asignar peso diferenciado a los votos según el grupo poblacional.”

```sql
CREATE TABLE vote_weight_groups (
  weight_group_id TINYINT        PRIMARY KEY,
  weight          DECIMAL(5,2)   NOT NULL,  -- Peso del grupo (p.ej. 1.00, 1.25)
  group_id        INT            NOT NULL,  -- FK → vpv_groups(groupId)
  session_id      INT            NOT NULL,  -- FK → vote_sessions(sessionId)
  FOREIGN KEY (group_id)   REFERENCES vpv_groups(groupId),
  FOREIGN KEY (session_id) REFERENCES vote_sessions(sessionId)
);
```

### vote_notifications
**Propósito**: Configurar cómo y cuándo notificar a los votantes el inicio de una sesión.
**Cumple con**: “Se debe configurar cómo se notificará el inicio de la votación.”

```sql
CREATE TABLE vote_notifications (
  notification_id   INT            PRIMARY KEY,
  notification_date DATETIME       NOT NULL,  -- Fecha y hora de envío
  enabled           BIT            DEFAULT 1, -- 1=Activo, 0=Inactivo
  message           VARCHAR(200)   NOT NULL,  -- Texto o plantilla de la notificación
  params            VARCHAR(500)   NULL,      -- Parámetros JSON (canal, asunto, etc.)
  session_id        INT            NOT NULL,  -- FK → vote_sessions(sessionId)
  contact_type_id   INT            NOT NULL,  -- FK → vpv_contact_types(contact_typeId)
  FOREIGN KEY (session_id)      REFERENCES vote_sessions(sessionId),
  FOREIGN KEY (contact_type_id) REFERENCES vpv_contact_types(contact_typeId)
);

```

### vote_voting_criteria
**Propósito**: Definir los criterios demográficos o de segmento para filtrar quién puede votar en cada sesión.
**Cumple con**: “El sistema debe permitir definir el público objetivo de cada votación usando criterios como edad, nacionalidad, sexo, […] o listas específicas.”
```sql
CREATE TABLE vote_voting_criteria (
  criteria_id  INT          PRIMARY KEY,
  rule_id      INT          NOT NULL,  -- FK → vote_rules(ruleId)
  value        VARCHAR(75)  NOT NULL,  -- Valor del criterio (p.ej. '>=18', 'CR', 'F')
  enabled      BIT          DEFAULT 1, -- 1=Activo, 0=Inactivo
  session_id   INT          NOT NULL,  -- FK → vote_sessions(sessionId)
  FOREIGN KEY (rule_id)    REFERENCES vote_rules(ruleId),
  FOREIGN KEY (session_id) REFERENCES vote_sessions(sessionId)
);

```

### vote_rules
**Propósito**: Catalogar tipos de criterios de segmentación (edad, nacionalidad, sexo, etc.).
**Cumple con**: Soporte para múltiples criterios de filtrado de audiencia.
```sql
CREATE TABLE vote_rules (
  ruleId    TINYINT     PRIMARY KEY,
  name      VARCHAR(50) NOT NULL,  -- E.g. 'age', 'nationality', 'sex'
  dataType  VARCHAR(50) NOT NULL   -- E.g. 'integer', 'string', 'enum'
);

```

### vote_sessions
**Propósito**: Representar una sesión de votación asociada a una propuesta.
**Cumple con**: Plazos definidos y configurables, estado de la votación.
```sql
CREATE TABLE vote_sessions (
  sessionId        INT          PRIMARY KEY,
  proposalId       INT          NOT NULL,  -- FK → vpv_proposal(proposalId)
  voteTypeId       TINYINT      NOT NULL,  -- FK → vote_types(voteTypeId)
  start_date       DATETIME   NOT NULL,  -- Fecha y hora de apertura
  end_date         DATETIME   NOT NULL,  -- Fecha y hora de cierre
  status           SMALLINT     NOT NULL,  -- 0=Pending,1=Open,2=Closed
  visibilityId TINYINT      NOT NULL,  -- FK → vote_result_visibilities(visibilityId)
  FOREIGN KEY (voteTypeId)       REFERENCES vote_types(voteTypeId),
  FOREIGN KEY (visibilityRuleId) REFERENCES vote_result_visibilities(visibilityId)
);

```
###  `vote_eligibility`

**Propósito**: Mantener la lista de ciudadanos habilitados para votar en una sesión virtual, asignarles un identificador anónimo (`anonId`) y garantizar que cada uno emita **un solo voto**.
```sql
CREATE TABLE vote_eligibility (
  eligibilityId  INT               PRIMARY KEY,
  sessionId      INT               NOT NULL,  -- FK → vote_sessions(sessionId)
  userId         INT               NOT NULL,  -- FK → citizen(id)
  anonId         UNIQUEIDENTIFIER  NOT NULL,  -- Permite anonimizar el vínculo entre el usuario real y su boleta cifrada.
  hasVoted       BIT               DEFAULT 0,
  voteDate   DATETIME          DEFAULT GETDATE(),
  FOREIGN KEY (sessionId) REFERENCES vote_sessions(sessionId),
  FOREIGN KEY (userId)    REFERENCES citizen(id),
  UNIQUE (sessionId, userId)
);
```
### vote_ballots
**Propósito**: Almacenar las “boletas virtuales” cifradas, junto con la firma digital de quien las emitió y, opcionalmente, la prueba de validez (ZKP).
```sql
CREATE TABLE vote_ballots (
  ballotId      INT             PRIMARY KEY,
  sessionId     INT             NOT NULL,  -- FK → vote_sessions(sessionId)
  anonId        UNIQUEIDENTIFIER NOT NULL, -- FK → vote_eligibility(anonId)
  encryptedVote VARBINARY(255)  NOT NULL,  -- Voto cifrado (AES/ElGamal)
  proof         VARBINARY(255)  NULL,      -- ZKP de validez (opcional) Demuestra que el voto pertenece al conjunto de opciones válidas (p.ej. “Sí”/“No”), sin revelar cuál.
    checksum    VARBINARY(255)  NOT NULL,  -- Validar que no se modificaron los campos de un registro
  FOREIGN KEY (sessionId) REFERENCES vote_sessions(sessionId),
  FOREIGN KEY (anonId)     REFERENCES vote_eligibility(anonId)
);
```

### vote_commitments
**Propósito**: Soportar un conteo homomórfico de votos y la decriptación distribuida mediante threshold shares.
```sql
CREATE TABLE vote_commitments (
  commitmentId    INT            PRIMARY KEY,
  sessionId       INT            NOT NULL,  -- FK → vote_sessions(sessionId)
  encryptedSum    VARBINARY(255) NOT NULL,  -- Suma homomórfica de boletas de todos los `encryptedVote`
  decryptionShare VARBINARY(255) NOT NULL,  -- Share para decriptación threshold Participación individual para threshold de decriptación
  FOREIGN KEY (sessionId) REFERENCES vote_sessions(sessionId)
);
```
### vote_audit_log
**Propósito**: Mantener un registro inmutable (hash chain) de todos los eventos críticos del proceso de votación, para detectar cualquier manipulación.
```sql
CREATE TABLE vote_audit_log (
  logId         INT            PRIMARY KEY,
  sessionId     INT            NOT NULL,   -- FK → vote_sessions(sessionId)
  eventType     VARCHAR(50)    NOT NULL,   -- 'eligibility','ballot','tally','decrypt'
  eventDataHash VARBINARY(64)  NOT NULL,   -- SHA-256 de payload
  previousHash  VARBINARY(64)  NULL,       -- Hash del evento anterior
  eventDate     DATETIME       DEFAULT GETDATE(),
  FOREIGN KEY (sessionId) REFERENCES vote_sessions(sessionId)
);
```

### vote_result_visibilities
**Propósito**: Definir cuándo los resultados son visibles (al cierre, tras todos los votos, etc.).
**Cumple con**: “Los resultados de una votación no se mostrarán hasta que se cierre el plazo de votación o hasta que todos los votantes elegibles hayan participado.”
```sql
CREATE TABLE vote_result_visibilities (
  visibilityId TINYINT     PRIMARY KEY,
  description  VARCHAR(50) NOT NULL  -- E.g. 'after_close', 'after_all_votes'
);

```

### vote_acceptance_rules
**Propósito**: Establecer las reglas de aceptación, rechazo o calificación en función de los resultados agregados.
**Cumple con**: “Se establecerán reglas claras de aceptación, rechazo o calificación según el resultado de los votos.”
```sql
CREATE TABLE vote_acceptance_rules (
  ruleId       INT          PRIMARY KEY,
  quantity     VARCHAR(75)  NOT NULL,  -- E.g. '>=50%', '>=2/3'
  description  VARCHAR(100) NOT NULL,  -- Texto descriptivo de la regla
  enabled      BIT          DEFAULT 1, -- 1=Activo, 0=Inactivo
  session_id   INT          NOT NULL,  -- FK → vote_sessions(sessionId)
  FOREIGN KEY (session_id) REFERENCES vote_sessions(sessionId)
);

```

### vote_registries
**Propósito**: Registrar cada voto emitido por un usuario en una sesión.
**Cumple con**: “Cada ciudadano podrá emitir un solo voto por propuesta, sin posibilidad de modificación.”
```sql
CREATE TABLE vote_registries (
  vote_registry_id INT            PRIMARY KEY,
  vote_date        DATETIME       NOT NULL,  -- Fecha y hora de votación
  vote             VARBINARY(255) NOT NULL,  -- Valor cifrado o token del voto
  field_name       VARCHAR(50)    NOT NULL,  -- Tipo de voto (p.ej. 'yes_no', 'rating')
  user_id          INT            NOT NULL,  -- FK → citizen(id)
  session_id       INT            NOT NULL,  -- FK → vote_sessions(sessionId)
  FOREIGN KEY (user_id)    REFERENCES citizen(id),
  FOREIGN KEY (session_id) REFERENCES vote_sessions(sessionId),
  UNIQUE (user_id, session_id)
);

```



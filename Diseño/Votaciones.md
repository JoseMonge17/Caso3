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
  sessionId    INT        PRIMARY KEY,
  start_date   DATETIME   NOT NULL,  -- Fecha y hora de apertura
  end_date     DATETIME   NOT NULL,  -- Fecha y hora de cierre
  status       SMALLINT   NOT NULL,  -- 0=Pendiente,1=Abierta,2=Cerrada
  visibilityId TINYINT    NOT NULL,  -- FK → vote_result_visibilities(visibilityId)
  proposal_id  INT        NOT NULL,  -- FK → vpv_proposal(proposalId)
  FOREIGN KEY (visibilityId) REFERENCES vote_result_visibilities(visibilityId),
  FOREIGN KEY (proposal_id)  REFERENCES vpv_proposal(proposalId)
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



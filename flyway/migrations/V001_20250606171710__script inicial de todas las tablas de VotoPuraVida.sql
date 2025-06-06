USE VotoPuraVida;

-- vpv_user_status
CREATE TABLE vpv_user_status (
  statusid        SMALLINT        PRIMARY KEY NOT NULL,
  name            VARCHAR(20)     NOT NULL
);

-- vpv_users
CREATE TABLE vpv_users (
  userid          INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  username        VARCHAR(100)    NOT NULL,
  firstname       VARCHAR(100)    NOT NULL,
  lastname        VARCHAR(100)    NOT NULL,
  identification  VARCHAR(15)     NOT NULL,
  registered      DATETIME        NOT NULL,
  birthdate       DATE            NOT NULL,
  email           VARCHAR(150)    NOT NULL,
  password        VARBINARY(250)  NOT NULL,
  statusid        SMALLINT        NOT NULL,
  FOREIGN KEY (statusid) REFERENCES vpv_user_status(statusid)
);

-- vpv_demographic_types
CREATE TABLE vpv_demographic_types (
  demographic_typeid TINYINT     PRIMARY KEY NOT NULL,
  name            VARCHAR(20)     NOT NULL
);

-- vpv_demographic_data
CREATE TABLE vpv_demographic_data (
  demographicid   INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  code            VARCHAR(10)     NOT NULL,
  description     VARCHAR(100)    NOT NULL,
  demographic_typeid TINYINT      NOT NULL,
  FOREIGN KEY (demographic_typeid) REFERENCES vpv_demographic_types(demographic_typeid)
);

-- vpv_user_demographics
CREATE TABLE vpv_user_demographics (
  user_demographicid SMALLINT     IDENTITY(1,1) PRIMARY KEY NOT NULL,
  enabled         BIT             NOT NULL,
  value           VARCHAR(50)     NOT NULL,
  demographicid   INT             NOT NULL,
  userid          INT             NOT NULL,
  FOREIGN KEY (demographicid) REFERENCES vpv_demographic_data(demographicid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- vpv_roles
CREATE TABLE vpv_roles (
  roleid          INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  rolename        VARCHAR(30)     NOT NULL,
  description     VARCHAR(70)     NOT NULL,
  systemrole      BIT             NOT NULL,
  asignationdate  DATETIME        NOT NULL
);

-- vpv_user_roles
CREATE TABLE vpv_user_roles (
  user_rolid      SMALLINT        IDENTITY(1,1) PRIMARY KEY NOT NULL,
  enabled         BIT             NOT NULL,
  roleid          INT             NOT NULL,
  userid          INT             NOT NULL,
  FOREIGN KEY (roleid) REFERENCES vpv_roles(roleid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- vpv_modules
CREATE TABLE vpv_modules (
  moduleid        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(45)     NOT NULL
);

-- vpv_permissions
CREATE TABLE vpv_permissions (
  permissionid    INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  permissioncode  VARCHAR(10)     NOT NULL,
  description     VARCHAR(70)     NOT NULL,
  htmlObject      VARCHAR(100)    NOT NULL,
  moduleid        INT             NOT NULL,
  FOREIGN KEY (moduleid) REFERENCES vpv_modules(moduleid)
);

-- vpv_rolepermissions
CREATE TABLE vpv_rolepermissions (
  userrolesid     INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  asignationdate  DATETIME        NOT NULL,
  checksum        VARBINARY(255)  NOT NULL,
  enable          BIT             NOT NULL,
  deleted         BIT             NOT NULL,
  lastupdate      DATETIME        NOT NULL,
  roleid          INT             NOT NULL,
  permissionid    INT             NOT NULL,
  FOREIGN KEY (permissionid) REFERENCES vpv_permissions(permissionid),
  FOREIGN KEY (roleid) REFERENCES vpv_roles(roleid)
);


-- vpv_user_groups
CREATE TABLE vpv_user_groups (
  user_groupid    SMALLINT        IDENTITY(1,1) PRIMARY KEY NOT NULL,
  enabled         BIT             NOT NULL,
  groupid         INT             NOT NULL,
  userid          INT             NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- vpv_entity_types
CREATE TABLE vpv_entity_types (
  entity_type_id  INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(50)     NOT NULL,
  description     VARCHAR(255)    NOT NULL
);

-- vpv_legal_id_types
CREATE TABLE vpv_legal_id_types (
  legal_id_type   INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(50)     NOT NULL,
  description     VARCHAR(255)    NOT NULL
);

-- vpv_status_types
CREATE TABLE vpv_status_types (
  status_type_id  INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(50)     NOT NULL,
  description     VARCHAR(255)    NOT NULL
);

-- vpv_entities
CREATE TABLE vpv_entities (
  entity_id           INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  legal_name          VARCHAR(255)    NOT NULL,
  public_name         VARCHAR(255)    NOT NULL,
  legal_id_number     VARCHAR(50)     NOT NULL,
  registration_date   DATETIME        NOT NULL,
  is_active           BIT             NOT NULL,
  status_type_id      INT             NOT NULL,
  legal_id_type       INT             NOT NULL,
  entity_type_id      INT             NOT NULL,
  validator_group_id  INT             NOT NULL,
  FOREIGN KEY (entity_type_id) REFERENCES vpv_entity_types(entity_type_id),
  FOREIGN KEY (legal_id_type) REFERENCES vpv_legal_id_types(legal_id_type),
  FOREIGN KEY (status_type_id) REFERENCES vpv_status_types(status_type_id)
);

-- vpv_entity_representative
CREATE TABLE vpv_entity_representative (
  rep_id                INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  role                  VARCHAR(255)    NOT NULL,
  department            VARCHAR(100)    NOT NULL,
  proof_doc_hash        VARBINARY(255)  NOT NULL,
  start_date            DATETIME        NOT NULL,
  end_date              DATETIME        NOT NULL,
  is_primary            BIT             NOT NULL,
  representation_hash   VARBINARY(255)  NOT NULL,
  entity_id             INT             NOT NULL,
  user_id               INT             NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id),
  FOREIGN KEY (user_id) REFERENCES vpv_users(userid)
);

-- vpv_entity_validations
CREATE TABLE vpv_entity_validations (
  validation_id        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  validation_type      VARCHAR(255)    NOT NULL,
  start_date           DATETIME        NOT NULL,
  end_date             DATETIME        NOT NULL,
  status               VARCHAR(20)     NOT NULL,
  required_approvals   INT             NOT NULL,
  current_approvals    INT             NOT NULL,
  version              INT             NOT NULL,
  entity_id            INT             NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id)
);

-- vpv_entity_audit_log
CREATE TABLE vpv_entity_audit_log (
  log_id              INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  action_type         VARCHAR(50)     NOT NULL,
  action_date         DATETIME        NOT NULL,
  performed_by_user   INT             NOT NULL,
  ip_address          VARBINARY(255)  NOT NULL,
  transaction_hash    VARBINARY(255)  NOT NULL,
  version             INT             NOT NULL,
  entity_id           INT             NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id),
  FOREIGN KEY (performed_by_user) REFERENCES vpv_users(userid)
);

-- vpv_entity_access_controls
CREATE TABLE vpv_entity_access_controls (
  access_id          INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  permission_type    VARCHAR(50)     NOT NULL,
  granted_date       DATETIME        NOT NULL,
  expiration_date    DATETIME        NOT NULL,
  signature          VARBINARY(255)  NOT NULL,
  version            INT             NOT NULL,
  entity_id          INT             NOT NULL,
  user_id            INT             NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id),
  FOREIGN KEY (user_id) REFERENCES vpv_users(userid)
);

-- vpv_entity_proposals
CREATE TABLE vpv_entity_proposals (
  proposal_id        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  proposal_type      VARCHAR(50)     NOT NULL,
  tittle             VARCHAR(255)    NOT NULL,
  summary            VARCHAR(255)    NOT NULL,
  impact_analysis    VARCHAR(255)    NOT NULL,
  submission_date    DATETIME        NOT NULL,
  status             VARCHAR(50)     NOT NULL,
  entity_id          INT             NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id)
);

-- vpv_entiity_documents (Nota: Hay un error de tipeo en el nombre 'entiity')
CREATE TABLE vpv_entity_documents (
  document_id        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  document_type      VARCHAR(100)    NOT NULL,
  document_hash      VARBINARY(255)  NOT NULL,
  storage_reference  VARCHAR(255)    NOT NULL,
  upload_date        DATETIME        NOT NULL,
  version           INT             NOT NULL,
  entity_id         INT             NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES vpv_entities(entity_id)
);

-- vpv_validations_approvals
CREATE TABLE vpv_validations_approvals (
  approval_id        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  validator_id       INT             NOT NULL,
  approval_date      DATETIME        NOT NULL,
  approval_result    VARCHAR(20)     NOT NULL,
  comments           VARCHAR(255)    NOT NULL,
  validator_signature VARBINARY(255) NOT NULL,
  version           INT             NOT NULL,
  validation_id      INT             NOT NULL,
  FOREIGN KEY (validation_id) REFERENCES vpv_entity_validations(validation_id),
  FOREIGN KEY (validator_id) REFERENCES vpv_users(userid)
);

-- vpv_countries
CREATE TABLE vpv_countries (
  countryid       INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(60)     NOT NULL,
  codeISO         VARCHAR(3)      NOT NULL,
  register_enable BIT             NOT NULL
);

-- vpv_whitelist
CREATE TABLE vpv_whitelist (
  whitelistid     INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  initial_IP      VARCHAR(50)     NOT NULL,
  end_IP          VARCHAR(50)     NOT NULL,
  countryid       INT             NOT NULL,
  allowed         BIT             NOT NULL,
  FOREIGN KEY (countryid) REFERENCES vpv_countries(countryid)
);

-- vpv_states
CREATE TABLE vpv_states (
  stateid         INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(60)     NOT NULL,
  countryid       INT             NOT NULL,
  FOREIGN KEY (countryid) REFERENCES vpv_countries(countryid)
);

-- vpv_cities
CREATE TABLE vpv_cities (
  cityid          INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(60)     NOT NULL,
  stateid         INT             NOT NULL,
  FOREIGN KEY (stateid) REFERENCES vpv_states(stateid)
);

-- vpv_address
CREATE TABLE vpv_address (
  addressid       INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  line1           VARCHAR(200)    NOT NULL,
  line2           VARCHAR(200)    NOT NULL,
  zipcode         VARCHAR(9)      NOT NULL,
  location        GEOGRAPHY       NOT NULL,
  cityid          INT             NOT NULL,
  FOREIGN KEY (cityid) REFERENCES vpv_cities(cityid)
);

-- vpv_adressasignations 
CREATE TABLE vpv_addressasignations (
  asignationid    INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  entitytype      VARCHAR(60)     NOT NULL,
  entityid        INT             NOT NULL,
  addressid       INT             NOT NULL,
  FOREIGN KEY (addressid) REFERENCES vpv_address(addressid)
);

-- vpv_document_type
CREATE TABLE vpv_document_type (
  document_typeid    INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name               VARCHAR(100)    NOT NULL,
  description        TEXT            NOT NULL,
  enabled            BIT             NOT NULL,
  workflowid         INT             NOT NULL,
  workflow_name      VARCHAR(100)    NOT NULL,
  parameters         NVARCHAR(MAX)   NOT NULL, -- JSON en SQL Server se maneja como NVARCHAR(MAX)
  schedule_interval  VARCHAR(15)     NOT NULL,
  [order]           INT             NOT NULL, -- order es palabra reservada, se usa [order]
  url                TEXT            NOT NULL
);

-- vpv_section_type
CREATE TABLE vpv_section_type (
  section_typeid    INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name              VARCHAR(100)    NOT NULL,
  description       VARCHAR(255)    NOT NULL,
  enabled           BIT             NOT NULL
);

-- vpv_document_sections
CREATE TABLE vpv_document_sections (
  sectionid        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  required         BIT             NOT NULL,
  order_index      INT             NOT NULL,
  rules            NVARCHAR(MAX)   NOT NULL, -- JSON
  section_typeid   INT             NOT NULL,
  document_typeid  INT             NOT NULL,
  parent_sectionid INT             NULL, -- Puede ser NULL para secciones raíz
  FOREIGN KEY (document_typeid) REFERENCES vpv_document_type(document_typeid),
  FOREIGN KEY (parent_sectionid) REFERENCES vpv_document_sections(sectionid),
  FOREIGN KEY (section_typeid) REFERENCES vpv_section_type(section_typeid)
);

-- vpv_validation_types
CREATE TABLE vpv_validation_types (
  validation_typeid INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name              VARCHAR(50)     NOT NULL,
  description       VARCHAR(100)    NOT NULL, -- Corregido VARHCHAR a VARCHAR
  enabled           BIT             NOT NULL
);

-- vpv_validation_result_type
CREATE TABLE vpv_validation_result_type (
  result_typeid    INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(50)     NOT NULL,
  description      VARCHAR(200)    NOT NULL
);

-- vpv_validation_process_log
CREATE TABLE vpv_validation_process_log (
  processid        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(100)    NOT NULL,
  description      VARCHAR(200)    NOT NULL,
  enabled          BIT             NOT NULL,
  schedule_interval VARCHAR(15)    NOT NULL,
  parameters       NVARCHAR(MAX)   NOT NULL, -- JSON
  startTime        DATETIME        NOT NULL,
  result           INT             NOT NULL,
  FOREIGN KEY (result) REFERENCES vpv_validation_result_type(result_typeid)
);

-- vpv_validation_request
CREATE TABLE vpv_validation_request (
  requestid        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  creation_date    DATETIME        NOT NULL,
  finish_date      DATETIME        NULL, -- Puede ser NULL si no ha finalizado
  global_result    TEXT            NULL, -- Puede ser NULL inicialmente
  userid           INT             NOT NULL,
  validation_typeid INT            NOT NULL,
  processid        INT             NOT NULL,
  FOREIGN KEY (validation_typeid) REFERENCES vpv_validation_types(validation_typeid),
  FOREIGN KEY (processid) REFERENCES vpv_validation_process_log(processid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- vpv_digital_documents
CREATE TABLE vpv_digital_documents (
  documentid       INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(150)    NOT NULL,
  url              TEXT            NOT NULL,
  hash             TEXT            NOT NULL,
  metadata         NVARCHAR(MAX)   NOT NULL, -- JSONB en SQL Server es NVARCHAR(MAX)
  validation_date  DATETIME        NULL, -- Puede ser NULL si no se ha validado
  requestid        INT             NOT NULL,
  document_typeid  INT             NOT NULL,
  FOREIGN KEY (document_typeid) REFERENCES vpv_document_type(document_typeid),
  FOREIGN KEY (requestid) REFERENCES vpv_validation_request(requestid)
);

-- vpv_validation_audit
CREATE TABLE vpv_validation_audit (
  auditid          INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  result           NVARCHAR(MAX)   NOT NULL, -- JSON
  comments         TEXT            NULL, -- Puede ser NULL
  startTime        DATETIME        NOT NULL,
  requestid        INT             NOT NULL,
  processid        INT             NOT NULL,
  FOREIGN KEY (requestid) REFERENCES vpv_validation_request(requestid),
  FOREIGN KEY (processid) REFERENCES vpv_validation_process_log(processid)
);

-- api_providers
CREATE TABLE api_providers (
  providerid           INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  brand_name           VARCHAR(100)    NOT NULL,
  legal_name           VARCHAR(150)    NOT NULL,
  legal_identification VARCHAR(50)     NOT NULL,
  enabled              BIT             NOT NULL
);

-- api_integrations
CREATE TABLE api_integrations (
  apiid            SMALLINT        IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(80)     NOT NULL,
  public_key       VARBINARY(255)  NOT NULL,
  private_key      VARBINARY(255)  NOT NULL,
  url              VARCHAR(200)    NOT NULL,
  creation_date    DATETIME        NOT NULL,
  last_update      DATETIME        NOT NULL,
  enabled          BIT             NOT NULL,
  idProvider       INT             NOT NULL,
  FOREIGN KEY (idProvider) REFERENCES api_providers(providerid)
);

-- vpv_validation_process_steps_log
CREATE TABLE vpv_validation_process_steps_log (
  process_stepid   INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  [order]         INT             NOT NULL, -- order es palabra reservada
  required         BIT             NOT NULL,
  processid        INT             NOT NULL,
  FOREIGN KEY (processid) REFERENCES vpv_validation_process_log(processid)
);

-- vpv_identity_validations
CREATE TABLE vpv_identity_validations (
  validationid     INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  approved         BIT             NOT NULL,
  validation_date  DATETIME        NOT NULL,
  observations     VARCHAR(255)    NULL, -- Puede ser NULL
  rejected_data    VARCHAR(255)    NULL, -- Corregido espacio extra en el nombre
  next_validation  DATE            NULL, -- Puede ser NULL
  process_stepid   INT             NOT NULL,
  apiid            SMALLINT        NOT NULL,
  FOREIGN KEY (apiid) REFERENCES api_integrations(apiid),
  FOREIGN KEY (process_stepid) REFERENCES vpv_validation_process_steps_log(process_stepid)
);


-- vpv_log_severity
CREATE TABLE vpv_log_severity (
  log_severityid  INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(50)     NOT NULL,
  severity_level  BIT             NOT NULL
);

-- vpv_log_source
CREATE TABLE vpv_log_source (
  log_sourceid    INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(100)    NOT NULL,
  system_component VARCHAR(100)    NOT NULL
);

-- vpv_log_type
CREATE TABLE vpv_log_type (
  log_typeid      INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(100)    NOT NULL,
  description     TEXT            NOT NULL
);

-- vpv_logs
CREATE TABLE vpv_logs (
  logid           INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  description     VARCHAR(200)    NOT NULL,
  posttime        DATETIME        NOT NULL,
  computer        VARCHAR(100)    NOT NULL,
  trace           TEXT            NOT NULL,
  reference_id1   BIGINT          NOT NULL,
  reference_id2   BIGINT          NOT NULL,
  value1          VARCHAR(180)    NOT NULL,
  value2          VARCHAR(180)    NOT NULL,
  checksum        VARCHAR(45)     NOT NULL,
  log_typeid      INT             NOT NULL,
  log_sourceid    INT             NOT NULL,
  log_severityid  INT             NOT NULL,
  FOREIGN KEY (log_typeid) REFERENCES vpv_log_type(log_typeid),
  FOREIGN KEY (log_sourceid) REFERENCES vpv_log_source(log_sourceid),
  FOREIGN KEY (log_severityid) REFERENCES vpv_log_severity(log_severityid)
);

-- vpv_mfa_devices
CREATE TABLE vpv_mfa_devices (
  deviceid            INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  userid              INT             NOT NULL,
  device_name         VARCHAR(50)     NOT NULL,
  registration_date   DATETIME        NOT NULL,
  last_used_date      DATETIME        NULL,
  device_status       VARCHAR(20)     NOT NULL,
  serial_hash         VARBINARY(255)  NOT NULL,
  authentication_factor VARCHAR(50)   NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- vpv_auth_methods
CREATE TABLE vpv_auth_methods (
  method_id           INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  userid              INT             NOT NULL,
  device_id           INT             NULL,
  method_type         VARCHAR(50)     NOT NULL,
  identifier_hash     VARCHAR(255)    NOT NULL,
  registration_date   DATETIME        NOT NULL,
  last_used_date      DATETIME        NULL,
  method_status       VARCHAR(20)     NOT NULL,
  priority            INT             NOT NULL,
  is_primary          BIT             NOT NULL,
  FOREIGN KEY (device_id) REFERENCES vpv_mfa_devices(deviceid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- vpv_user_keys
CREATE TABLE vpv_user_keys (
  key_id              INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  userid              INT             NOT NULL,
  key_type            VARCHAR(50)     NOT NULL,
  algorithm           VARCHAR(50)     NOT NULL,
  creation_date       DATETIME        NOT NULL,
  expiration_date     DATETIME        NULL,
  key_status          VARCHAR(20)     NOT NULL,
  key_identifier      VARBINARY(255)  NOT NULL,
  secure_storage      VARCHAR(255)    NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- vpv_digital_certificates
CREATE TABLE vpv_digital_certificates (
  certificate_id      INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  key_id              INT             NOT NULL,
  issuer              VARCHAR(255)    NOT NULL,
  issue_date          DATETIME        NOT NULL,
  expiration_date     DATETIME        NOT NULL,
  serial_number       VARCHAR(20)     NOT NULL,
  certificate_status  VARCHAR(20)     NOT NULL,
  crl_distribution    VARCHAR(255)    NULL,
  certificate_signature VARCHAR(255)  NOT NULL,
  FOREIGN KEY (key_id) REFERENCES vpv_user_keys(key_id)
);

-- vpv_auth_sessions
CREATE TABLE vpv_auth_sessions (
  sessionid           INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  method_id           INT             NOT NULL,
  device_id           INT             NULL,
  start_date          DATETIME        NOT NULL,
  last_activity_date  DATETIME        NOT NULL,
  expiration_date     DATETIME        NULL,
  session_status      VARCHAR(20)     NOT NULL,
  session_token_hash  VARBINARY(255)  NOT NULL,
  used_factors        VARCHAR(255)    NOT NULL,
  device_hash         VARBINARY(255)  NULL,
  ip_hash             VARBINARY(255)  NULL,
  FOREIGN KEY (device_id) REFERENCES vpv_mfa_devices(deviceid),
  FOREIGN KEY (method_id) REFERENCES vpv_auth_methods(method_id)
);

-- vpv_cryptographic_operations
CREATE TABLE vpv_cryptographic_operations (
  operation_id        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  session_id          INT             NOT NULL,
  key_id              INT             NOT NULL,
  operation_type      VARCHAR(50)     NOT NULL,
  operation_date      DATETIME        NOT NULL,
  document_hash       VARCHAR(255)    NOT NULL,
  result_hash         VARCHAR(255)    NOT NULL,
  device_hash         VARCHAR(255)    NULL,
  ip_hash             VARCHAR(255)    NULL,
  op_signature        VARCHAR(255)    NOT NULL,
  FOREIGN KEY (key_id) REFERENCES vpv_user_keys(key_id),
  FOREIGN KEY (session_id) REFERENCES vpv_auth_sessions(sessionid)
);

-- vpv_auth_events
CREATE TABLE vpv_auth_events (
  event_id            INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  session_id          INT             NOT NULL,
  event_type          VARCHAR(50)     NOT NULL,
  event_date          DATETIME        NOT NULL,
  method_used         VARCHAR(50)     NOT NULL,
  success             BIT             NOT NULL,
  error_code          VARCHAR(100)    NULL,
  ip_hash             VARBINARY(255)  NULL,
  device_hash         VARBINARY(255)  NULL,
  approx_location     VARCHAR(255)    NULL,
  FOREIGN KEY (session_id) REFERENCES vpv_auth_sessions(sessionid)
);

-- vpv_mfa_codes 
CREATE TABLE vpv_mfa_codes (
  code_id             INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  method_id           INT             NOT NULL,
  device_id           INT             NULL,
  code_hash           VARBINARY(255)  NOT NULL,
  generation_date     DATETIME        NOT NULL,
  expiration_date     DATETIME        NOT NULL,
  remaining_attempts  INT             NOT NULL,
  code_status         VARCHAR(20)     NOT NULL,
  request_context     VARCHAR(255)    NULL,
  request_ip_hash     VARBINARY(255)  NULL,
  request_device_hash VARBINARY(255)  NULL,
  FOREIGN KEY (method_id) REFERENCES vpv_auth_methods(method_id),
  FOREIGN KEY (device_id) REFERENCES vpv_mfa_devices(deviceid)
);

-- vpv_security_questions (corrected DATETIMTE to DATETIME)
CREATE TABLE vpv_security_questions (
  question_id         INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  userid              INT             NOT NULL,
  question_hash       VARCHAR(255)    NOT NULL,
  answer_hash         VARCHAR(255)    NOT NULL,
  creation_date       DATETIME        NOT NULL,
  last_modified_date  DATETIME        NOT NULL,
  failed_attempts     INT             NOT NULL,
  question_status     VARCHAR(20)     NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- vpv_key_rotation (corrected table name from vpv_key_rotation*)
CREATE TABLE vpv_key_rotation (
  rotation_id         INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  old_key_id          INT             NOT NULL,
  new_key_id          INT             NOT NULL,
  rotation_date       DATETIME        NOT NULL,
  rotation_reason     VARCHAR(100)    NOT NULL,
  initiated_by        VARCHAR(50)     NOT NULL,
  rotation_signature  VARCHAR(255)    NOT NULL,
  FOREIGN KEY (new_key_id) REFERENCES vpv_user_keys(key_id),
  FOREIGN KEY (old_key_id) REFERENCES vpv_user_keys(key_id)
);

-- vpv_key_backups
CREATE TABLE vpv_key_backups (
  backup_id           INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  key_id              INT             NOT NULL,
  backup_date         DATETIME        NOT NULL,
  storage_method      VARCHAR(50)     NOT NULL,
  backup_location_hash VARCHAR(255)   NOT NULL,
  backup_status       VARCHAR(50)     NOT NULL,
  backup_signature    VARBINARY(255)  NOT NULL,
  FOREIGN KEY (key_id) REFERENCES vpv_user_keys(key_id)
);

-- vpv_mediatypes
CREATE TABLE vpv_mediatypes (
  mediatypeid      INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(20)     NOT NULL,
  formattype       VARCHAR(30)     NOT NULL,
  enable           BIT             NOT NULL
);

-- vpv_biometric_types
CREATE TABLE vpv_biometric_types (
  biotypeid        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(60)     NOT NULL,
  description      VARCHAR(200)    NOT NULL,
  enable           BIT             NOT NULL,
  legal_requirement VARCHAR(100)   NOT NULL
);

-- vpv_biometric_media
CREATE TABLE vpv_biometric_media (
  biomediaid       INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  filename         VARCHAR(100)    NOT NULL,
  storage_url      VARCHAR(255)    NOT NULL,
  file_size        INT             NOT NULL, -- Changed from BIT to INT as file size should be numeric
  uploaddate       DATETIME        NOT NULL,
  hashvalue        VARBINARY(250)  NOT NULL,
  encryption_key_id VARCHAR(255)   NOT NULL,
  is_original      BIT             NOT NULL,
  userid           INT             NOT NULL,
  biotypeid        INT             NOT NULL,
  mediatypeid      INT             NOT NULL,
  FOREIGN KEY (mediatypeid) REFERENCES vpv_mediatypes(mediatypeid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (biotypeid) REFERENCES vpv_biometric_types(biotypeid)
);

-- vpv_livenesschecks
CREATE TABLE vpv_livenesschecks (
  livenessid       INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  check_type       VARCHAR(50)     NOT NULL,
  check_date       DATETIME        NOT NULL,
  result           BIT             NOT NULL,
  confidence_score DECIMAL(5,2)    NOT NULL,
  algorithm_used   VARCHAR(100)    NOT NULL,
  device_info      VARCHAR(200)    NOT NULL,
  userid           INT             NOT NULL,
  requestid        INT             NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (requestid) REFERENCES vpv_validation_request(requestid)
);

-- vpv_livenesschecks_media
CREATE TABLE vpv_livenesschecks_media (
  livemediaid      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  livenessid       INT           NOT NULL,
  biomediaid       INT           NOT NULL,
  FOREIGN KEY (biomediaid) REFERENCES vpv_biometric_media(biomediaid),
  FOREIGN KEY (livenessid) REFERENCES vpv_livenesschecks(livenessid)
);

-- vpv_biometric_consents
CREATE TABLE vpv_biometric_consents (
  consentid        INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  consent_date     DATETIME        NOT NULL,
  consent_text     TEXT            NOT NULL,
  consent_version  VARCHAR(20)     NOT NULL,
  expiration_date  DATETIME        NULL,
  active           BIT             NOT NULL,
  revocation_date  DATETIME        NULL,
  revocation_reason VARCHAR(200)   NULL,
  userid           INT             NOT NULL,
  biotypeid        INT             NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (biotypeid) REFERENCES vpv_biometric_types(biotypeid)
);

-- vpv_biometric_status
CREATE TABLE vpv_biometric_status (
  biostatusid      INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  status           VARCHAR(50)     NOT NULL,
  statusdate       DATETIME        NOT NULL,
  changed_by       INT             NOT NULL,
  comments         VARCHAR(200)    NULL,
  [current]          BIT             NOT NULL,
  biomediaid       INT             NOT NULL,
  FOREIGN KEY (biomediaid) REFERENCES vpv_biometric_media(biomediaid),
  FOREIGN KEY (changed_by) REFERENCES vpv_users(userid)
);

-- vpv_biometric_templates
CREATE TABLE vpv_biometric_templates (
  templateid       INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  algorithmused    VARCHAR(60)     NOT NULL,
  templatedata     VARBINARY(2000) NOT NULL,
  qualityscore     DECIMAL(5,2)    NOT NULL,
  creationdate     DATETIME        NOT NULL,
  version          INT             NOT NULL,
  enable           BIT             NOT NULL,
  biomediaid       INT             NOT NULL,
  FOREIGN KEY (biomediaid) REFERENCES vpv_biometric_media(biomediaid)
);

-- vpv_eventtypes
CREATE TABLE vpv_eventtypes (
  event_typeid     INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(20)     NOT NULL
);

-- vpv_devicetypes
CREATE TABLE vpv_devicetypes (
  devicetypeid     INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(20)     NOT NULL
);

-- vpv_biometric_devices
CREATE TABLE vpv_biometric_devices (
  deviceid         INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  manufacturer     VARCHAR(100)    NOT NULL,
  model            VARCHAR(100)    NOT NULL,
  serial_number_hash VARBINARY(255) NOT NULL,
  device_typeid    INT             NOT NULL,
  certification    VARCHAR(100)    NOT NULL,
  registrationdate DATETIME        NOT NULL,
  lastcalibration  DATETIME        NULL,
  active           BIT             NOT NULL,
  FOREIGN KEY (device_typeid) REFERENCES vpv_devicetypes(devicetypeid)
);

-- vpv_biometric_audit
CREATE TABLE vpv_biometric_audit (
  auditid          INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  event_date       DATETIME        NOT NULL,
  event_type       INT             NOT NULL,
  description      VARCHAR(200)    NOT NULL,
  ip_address       VARBINARY(255)  NOT NULL,
  metadata         TEXT            NULL,
  deviceid         INT             NULL,
  biotypeid        INT             NULL,
  userid           INT             NOT NULL,
  affected_userid  INT             NULL,
  FOREIGN KEY (deviceid) REFERENCES vpv_biometric_devices(deviceid),
  FOREIGN KEY (affected_userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (event_type) REFERENCES vpv_eventtypes(event_typeid),
  FOREIGN KEY (biotypeid) REFERENCES vpv_biometric_types(biotypeid)
);

-- vpv_biometric_validations
CREATE TABLE vpv_biometric_validations (
  validationid     INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  validation_date  DATETIME        NOT NULL,
  match_score      DECIMAL(5,2)    NOT NULL,
  threshold        DECIMAL(5,2)    NOT NULL,
  is_match         BIT             NOT NULL,
  ip_address       VARBINARY(250)  NOT NULL,
  session_id       VARCHAR(100)    NOT NULL,
  templateid       INT             NOT NULL,
  deviceusedid     INT             NOT NULL,
  userid           INT             NOT NULL,
  FOREIGN KEY (templateid) REFERENCES vpv_biometric_templates(templateid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (deviceusedid) REFERENCES vpv_biometric_devices(deviceid)
);

-- vpv_operationtypes
CREATE TABLE vpv_operationtypes (
  operationtypeid  INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(20)     NOT NULL
);

-- vpv_biometric_device_usage
CREATE TABLE vpv_biometric_device_usage (
  usageid          INT             IDENTITY(1,1) PRIMARY KEY NOT NULL,
  use_date         DATETIME        NOT NULL,
  operation_typeid INT             NOT NULL,
  result           BIT             NOT NULL,
  session_id       VARCHAR(100)    NOT NULL,
  deviceid         INT             NOT NULL,
  userid           INT             NOT NULL,
  FOREIGN KEY (deviceid) REFERENCES vpv_biometric_devices(deviceid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (operation_typeid) REFERENCES vpv_operationtypes(operationtypeid)
);

-- vpv_validator_groups
CREATE TABLE vpv_validator_groups (
  validator_group_id INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  group_name         VARCHAR(100)  NOT NULL,
  min_approvals      INT           NOT NULL,
  total_members      INT           NOT NULL,
  is_active          BIT           NOT NULL,
  created_at         DATETIME      NOT NULL
);

-- vpv_group_type 
CREATE TABLE vpv_group_type (
  grouptypeid       TINYINT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name              VARCHAR(60)   NOT NULL
);

-- vpv_groups
CREATE TABLE vpv_groups (
  groupid           INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  description       VARCHAR(100)  NOT NULL,
  name              VARCHAR(50)   NOT NULL,
  grouptypeid       TINYINT       NOT NULL,
  entityid          INT           NOT NULL,
  FOREIGN KEY (entityid) REFERENCES vpv_entities(entity_id),
  FOREIGN KEY (grouptypeid) REFERENCES vpv_group_type(grouptypeid)
);

-- vpv_group_keys
CREATE TABLE vpv_group_keys (
  combination_id    INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  key_name          VARCHAR(100)  NOT NULL,
  encrypted_key     VARBINARY(255) NOT NULL,
  key_combination_hash VARBINARY(255) NOT NULL,
  is_active         BIT           NOT NULL,
  created_at        DATETIME      NOT NULL,
  validator_group_id INT          NOT NULL,
  FOREIGN KEY (validator_group_id) REFERENCES vpv_validator_groups(validator_group_id)
);

-- vpv_group_approvals_status 
CREATE TABLE vpv_group_approvals_status (
  approval_status_id TINYINT      IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name              VARCHAR(60)   NOT NULL
);

-- vpv_group_approvals
CREATE TABLE vpv_group_approvals (
  approval_id       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  created_at        DATETIME      NOT NULL,
  completed_at      DATETIME      NULL,
  approval_status_id TINYINT      NOT NULL,
  request_id        INT           NOT NULL,
  validator_group_id INT          NOT NULL,
  combination_id    INT           NOT NULL,
  FOREIGN KEY (combination_id) REFERENCES vpv_group_keys(combination_id),
  FOREIGN KEY (validator_group_id) REFERENCES vpv_validator_groups(validator_group_id),
  FOREIGN KEY (approval_status_id) REFERENCES vpv_group_approvals_status(approval_status_id)
);

-- vpv_validator_group_members
CREATE TABLE vpv_validator_group_members (
  member_id         INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  is_active         BIT           NOT NULL,
  added_at          DATETIME      NOT NULL,
  validator_group_id INT          NOT NULL,
  user_id           INT           NOT NULL,
  FOREIGN KEY (validator_group_id) REFERENCES vpv_validator_groups(validator_group_id),
  FOREIGN KEY (user_id) REFERENCES vpv_users(userid)
);

-- vpv_group_approval_signatures
CREATE TABLE vpv_group_approval_signatures (
  signature_id      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  signature_data    VARBINARY(255) NOT NULL,
  signature_timestamp DATETIME    NOT NULL,
  is_final_approval BIT           NOT NULL,
  participants_json VARCHAR(255)  NOT NULL,
  approval_id       INT           NOT NULL,
  user_Id           INT           NOT NULL,
  FOREIGN KEY (user_Id) REFERENCES vpv_users(userid),
  FOREIGN KEY (approval_id) REFERENCES vpv_group_approvals(approval_id)
);

-- vpv_final_approval_records
CREATE TABLE vpv_final_approval_records (
  record_id         INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  completed_timestamp DATETIME    NOT NULL,
  required_signatures INT         NOT NULL,
  final_signatures_json VARCHAR(255) NOT NULL,
  combined_signature VARBINARY(255) NOT NULL,
  version           INT           NOT NULL,
  approval_id       INT           NOT NULL,
  FOREIGN KEY (approval_id) REFERENCES vpv_group_approvals(approval_id)
);

-- vpv_contact_types
CREATE TABLE vpv_contact_types (
  contact_typeid    INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name              VARCHAR(50)   NOT NULL,
  description       VARCHAR(255)  NOT NULL,
  isActive          BIT           NOT NULL
);

-- vpv_contact_info
CREATE TABLE vpv_contact_info (
  contact_infoid    INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  value             VARCHAR(255)  NOT NULL,
  notes             VARCHAR(255)  NULL,
  enabled           BIT           NOT NULL,
  userid            INT           NOT NULL,
  contact_typeid    INT           NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (contact_typeid) REFERENCES vpv_contact_types(contact_typeid)
);

-- vote_sessions_status
CREATE TABLE vote_sessions_status (
  sessionStatuslid SMALLINT      IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(50)   NOT NULL
);

-- vote_criterias
CREATE TABLE vote_criterias (
  criteriaid      TINYINT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  type            VARCHAR(50)   NOT NULL,
  datatype        VARCHAR(200)  NOT NULL,
  demographicid   INT           NOT NULL,
  FOREIGN KEY (demographicid) REFERENCES vpv_demographic_data(demographicid)
);

-- vote_types
CREATE TABLE vote_types (
  voteTypeid      TINYINT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(50)   NOT NULL,
  description     VARCHAR(200)  NOT NULL,
  singleWeight    BIT           NOT NULL
);

-- vote_result_visibilities
CREATE TABLE vote_result_visibilities (
  visibilityid    TINYINT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  description     VARCHAR(50)   NOT NULL
);

-- vote_sessions
CREATE TABLE vote_sessions (
  sessionid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  startDate       DATETIME      NOT NULL,
  endDate         DATETIME      NOT NULL,
  public_key      VARBINARY(255) NOT NULL,
  threshold       TINYINT       NOT NULL,
  key_shares      TINYINT       NOT NULL,
  sessionStatusid SMALLINT      NOT NULL,
  voteTypeid      TINYINT       NOT NULL,
  visibilityid    TINYINT      NOT NULL,
  FOREIGN KEY (voteTypeid) REFERENCES vote_types(voteTypeid),
  FOREIGN KEY (sessionStatusid) REFERENCES vote_sessions_status(sessionStatuslid),
  FOREIGN KEY (visibilityid) REFERENCES vote_result_visibilities(visibilityid)
);

-- vote_voting_criteria
CREATE TABLE vote_voting_criteria (
  ruleid          INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  value           VARCHAR(75)   NOT NULL,
  weight          DECIMAL(5,2)  NOT NULL,
  enabled         BIT           NOT NULL,
  sessionid       INT           NOT NULL,
  criteriaid      TINYINT       NOT NULL,
  FOREIGN KEY (criteriaid) REFERENCES vote_criterias(criteriaid),
  FOREIGN KEY (sessionid) REFERENCES vote_sessions(sessionid)
);

-- vote_notifications
CREATE TABLE vote_notifications (
  notificationid  INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  notificationDate DATETIME      NOT NULL,
  enabled         BIT           NOT NULL,
  message         VARCHAR(200)  NOT NULL,
  params          VARCHAR(500)  NOT NULL,
  sessionid       INT           NOT NULL,
  contact_typeid  INT           NOT NULL,
  FOREIGN KEY (sessionid) REFERENCES vote_sessions(sessionid),
  FOREIGN KEY (contact_typeid) REFERENCES vpv_contact_types(contact_typeid)
);

-- vote_elegibility
CREATE TABLE vote_elegibility (
  elegibilityid   INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  anonid          UNIQUEIDENTIFIER NOT NULL,
  voted           BIT           NOT NULL,
  registeredDate  DATETIME      NOT NULL,
  sessionid       INT           NOT NULL,
  userid          INT           NOT NULL,
  FOREIGN KEY (sessionid) REFERENCES vote_sessions(sessionid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- vote_ballots
CREATE TABLE vote_ballots (
  vote_registryid INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  voteDate        DATETIME      NOT NULL,
  signature       VARBINARY(255) NOT NULL,
  encryptedVote   VARBINARY(256) NOT NULL,
  proof           VARBINARY(255) NOT NULL,
  checksum        VARBINARY(255) NOT NULL,
  anonid          INT           NOT NULL,
  sessionid       INT           NOT NULL,
  FOREIGN KEY (anonid) REFERENCES vote_elegibility(elegibilityid),
  FOREIGN KEY (sessionid) REFERENCES vote_sessions(sessionid)
);

-- vote_key_share_participants
CREATE TABLE vote_key_share_participants (
  participantid   TINYINT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(100)  NOT NULL,
  public_share    VARBINARY(255) NOT NULL,
  sessionid       INT           NOT NULL,
  FOREIGN KEY (sessionid) REFERENCES vote_sessions(sessionid)
);

-- vote_backup
CREATE TABLE vote_backup (
  backupid        TINYINT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  register        TEXT          NOT NULL
);

-- vote_rules
CREATE TABLE vote_rules (
  ruleid          TINYINT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(50)   NOT NULL,
  dataType        VARCHAR(50)   NOT NULL
);

-- vote_acceptance_rules 
CREATE TABLE vote_acceptance_rules (
  acceptance_ruleid INT         IDENTITY(1,1) PRIMARY KEY NOT NULL,
  quantity        INT           NOT NULL,
  description     VARCHAR(100)  NOT NULL,
  enabled         BIT           NOT NULL,
  sessionid       INT           NOT NULL,
  rule_typeid     TINYINT       NOT NULL,
  FOREIGN KEY (sessionid) REFERENCES vote_sessions(sessionid),
  FOREIGN KEY (rule_typeid) REFERENCES vote_rules(ruleid)
);

-- vote_auditLog
CREATE TABLE vote_auditLog (
  auditid         INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  eventType       VARCHAR(50)   NOT NULL,
  eventDataHash   VARBINARY(255) NOT NULL,
  previousHash    VARBINARY(255) NOT NULL,
  eventDate       DATETIME      NOT NULL,
  sessionid       INT           NOT NULL,
  FOREIGN KEY (sessionid) REFERENCES vote_sessions(sessionid)
);

-- vote_commitments 
CREATE TABLE vote_commitments (
  commitmentid    INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  encryptedSum    VARBINARY(255) NOT NULL,
  ciphertext_sum  VARBINARY(255) NOT NULL,
  value           VARCHAR(100)  NOT NULL,
  demographicid   INT           NOT NULL,
  sessionid       INT           NOT NULL,
  FOREIGN KEY (demographicid) REFERENCES vpv_demographic_data(demographicid),
  FOREIGN KEY (sessionid) REFERENCES vote_sessions(sessionid)
);

-- vote_decryption_shares
CREATE TABLE vote_decryption_shares (
  shareid         INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  share_value     VARBINARY(255) NOT NULL,
  participantid   TINYINT           NOT NULL,
  commitment_id   INT           NOT NULL,
  FOREIGN KEY (participantid) REFERENCES vote_key_share_participants(participantid),
  FOREIGN KEY (commitment_id) REFERENCES vote_commitments(commitmentid)
);

-- vpv_origin_type
CREATE TABLE vpv_origin_type (
  origin_typeid   INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(100)  NOT NULL,
  description     VARCHAR(255)  NOT NULL,
  enabled         BIT           NOT NULL
);

-- vpv_proposal_status
CREATE TABLE vpv_proposal_status (
  statusid        INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(150)  NOT NULL,
  description     VARCHAR(255)  NOT NULL,
  enabled         BIT           NOT NULL
);

-- vpv_proposal_type
CREATE TABLE vpv_proposal_type (
  proposal_typeid INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(150)  NOT NULL,
  description     VARCHAR(255)  NOT NULL,
  enabled         BIT           NOT NULL
);

-- vpv_proposal
CREATE TABLE vpv_proposal (
  proposalid      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name            VARCHAR(100)  NOT NULL,
  enabled         BIT           NOT NULL,
  current_version INT           NOT NULL,
  description     VARCHAR(255)  NOT NULL,
  submission_date DATETIME      NOT NULL,
  version         INT           NOT NULL,
  origin_typeid   INT           NOT NULL,
  userid          INT           NOT NULL,
  statusid        INT           NOT NULL,
  proposal_typeid INT           NOT NULL,
  entityid        INT           NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid),
  FOREIGN KEY (statusid) REFERENCES vpv_proposal_status(statusid),
  FOREIGN KEY (proposal_typeid) REFERENCES vpv_proposal_type(proposal_typeid),
  FOREIGN KEY (origin_typeid) REFERENCES vpv_origin_type(origin_typeid),
  FOREIGN KEY (entityid) REFERENCES vpv_entities(entity_id)
);

-- vpv_proposal_documents
CREATE TABLE vpv_proposal_documents (
  proposal_documentid INT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  is_required     BIT           NOT NULL,
  proposalid      INT           NOT NULL,
  documentid      INT           NOT NULL,
  FOREIGN KEY (proposalid) REFERENCES vpv_proposal(proposalid),
  FOREIGN KEY (documentid) REFERENCES vpv_digital_documents(documentid)
);

-- vpv_proposal_versions
CREATE TABLE vpv_proposal_versions (
  versionid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  version         INT           NOT NULL,
  changes_description TEXT       NOT NULL,
  created_at      DATETIME      NOT NULL,
  approved        BIT           NOT NULL,
  proposal_documentid INT       NOT NULL,
  FOREIGN KEY (proposal_documentid) REFERENCES vpv_proposal_documents(proposal_documentid)
);

-- cf_proposal_votes
CREATE TABLE cf_proposal_votes (
  proposal_voteid INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  date            DATETIME      NOT NULL,
  result          BIT           NOT NULL,
  sessionid       INT           NOT NULL,
  proposalid      INT           NOT NULL,
  FOREIGN KEY (proposalid) REFERENCES vpv_proposal(proposalid),
  FOREIGN KEY (sessionid) REFERENCES vote_sessions(sessionid)
);

-- vpv_recurrencetypes
CREATE TABLE vpv_recurrencetypes (
  recurrencetypeid INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(20)   NOT NULL
);

-- vpv_schedules
CREATE TABLE vpv_schedules (
  scheduleid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(100)  NOT NULL,
  description      TEXT          NOT NULL,
  recurrencetypeid INT           NOT NULL,
  active           BIT           NOT NULL,
  [interval]       INT           NOT NULL,
  startdate        DATETIME      NOT NULL,
  endtype          VARCHAR(20)   NOT NULL CHECK (endtype IN ('DATE', 'REPETITIONS', 'NEVER')),
  repetitions      INT           NULL,
  FOREIGN KEY (recurrencetypeid) REFERENCES vpv_recurrencetypes(recurrencetypeid)
);

-- vpv_schedulesdetails
CREATE TABLE vpv_schedulesdetails (
  scheduledetailid INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  deleted          BIT           NOT NULL,
  basedate         DATETIME      NOT NULL,
  datepart         VARCHAR(20)   NOT NULL,
  executiontime    DATETIME      NOT NULL,
  scheduleid       INT           NOT NULL,
  timezone         VARCHAR(50)   NOT NULL,
  FOREIGN KEY (scheduleid) REFERENCES vpv_schedules(scheduleid)
);

-- vpv_pay_methods
CREATE TABLE vpv_pay_methods (
  id               INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(75)   NOT NULL,
  secret_key       VARBINARY(255) NOT NULL,
  logo_icon_url    VARCHAR(200)  NOT NULL,
  enabled          BIT           NOT NULL,
  idApiIntegration SMALLINT      NOT NULL,
  FOREIGN KEY (idApiIntegration) REFERENCES api_integrations(apiid)
);

-- vpv_available_pay_methods
CREATE TABLE vpv_available_pay_methods (
  id               INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(50)   NOT NULL,
  token            VARCHAR(255)  NOT NULL,
  exp_token        DATE          NOT NULL,
  mask_account     VARCHAR(50)   NOT NULL,
  idMethod         INT           NOT NULL,
  FOREIGN KEY (idMethod) REFERENCES vpv_pay_methods(id)
);

-- vpv_paymentstatus
CREATE TABLE vpv_paymentstatus (
  paymentstatusid  INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(50)   NOT NULL
);

-- vpv_payments
CREATE TABLE vpv_payments (
  paymentid        INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  amount           DECIMAL(10,2) NOT NULL,
  taxamount        DECIMAL(10,2) NOT NULL,
  discountporcent  DECIMAL(5,2)  NOT NULL,
  realamount       DECIMAL(10,2) NOT NULL,
  result           VARCHAR(10)   NOT NULL,
  authcode         VARCHAR(100)  NOT NULL,
  referencenumber  VARCHAR(100)  NOT NULL,
  chargetoken      VARBINARY(200) NOT NULL,
  [date]           DATETIME      NOT NULL,
  checksum         VARBINARY(250) NOT NULL,
  statusid         INT           NOT NULL,
  paymentmethodid  INT           NOT NULL,
  availablemethodid INT          NOT NULL,
  FOREIGN KEY (availablemethodid) REFERENCES vpv_available_pay_methods(id),
  FOREIGN KEY (statusid) REFERENCES vpv_paymentstatus(paymentstatusid),
  FOREIGN KEY (paymentmethodid) REFERENCES vpv_pay_methods(id)
);

-- vpv_paymentschedules
CREATE TABLE vpv_paymentschedules (
  paymentscheduleid INT          IDENTITY(1,1) PRIMARY KEY NOT NULL,
  paymentid        INT           NOT NULL,
  scheduledetailid INT           NOT NULL,
  nextpayment      DATETIME      NOT NULL,
  lastpayment      DATETIME      NULL,
  remainingpayments INT          NULL,
  active           BIT           NOT NULL,
  FOREIGN KEY (scheduledetailid) REFERENCES vpv_schedulesdetails(scheduledetailid),
  FOREIGN KEY (paymentid) REFERENCES vpv_payments(paymentid)
);

-- vpv_currencies
CREATE TABLE vpv_currencies (
  currencyid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(50)   NOT NULL,
  acronym          VARCHAR(15)   NOT NULL,
  country          VARCHAR(45)   NOT NULL,
  symbol           VARCHAR(5)    NOT NULL
);

-- vpv_exchangerates 
CREATE TABLE vpv_exchangerates (
  exchangerateid   INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  startdate        DATETIME      NOT NULL,
  enddate          DATETIME      NULL,
  exchangerate     DECIMAL(10,4) NOT NULL,
  currentexchangerate BIT        NOT NULL,
  currencyidsource INT           NOT NULL,
  currencyiddestiny INT          NOT NULL,
  FOREIGN KEY (currencyiddestiny) REFERENCES vpv_currencies(currencyid),
  FOREIGN KEY (currencyidsource) REFERENCES vpv_currencies(currencyid)
);

-- vpv_transactiontypes
CREATE TABLE vpv_transactiontypes (
  transactiontypeid INT          IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(30)   NOT NULL
);

-- vpv_transactionsubtypes
CREATE TABLE vpv_transactionsubtypes (
  transactionsubtypeid INT       IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(30)   NOT NULL
);

-- vpv_transactions
CREATE TABLE vpv_transactions (
  transactionid    INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(75)   NOT NULL,
  description      TEXT          NOT NULL,
  amount           DECIMAL(10,4) NOT NULL,
  referencenumber  VARCHAR(100)  NOT NULL,
  transactiondate  DATETIME      NOT NULL,
  officetime       DATETIME      NOT NULL,
  checksum         VARBINARY(250) NOT NULL,
  transactiontypeid INT          NOT NULL,
  transactionsubtypeid INT       NOT NULL,
  currencyid       INT           NOT NULL,
  exchangerateid   INT           NULL,
  payid            INT           NULL,
  FOREIGN KEY (currencyid) REFERENCES vpv_currencies(currencyid),
  FOREIGN KEY (transactiontypeid) REFERENCES vpv_transactiontypes(transactiontypeid),
  FOREIGN KEY (transactionsubtypeid) REFERENCES vpv_transactionsubtypes(transactionsubtypeid),
  FOREIGN KEY (payid) REFERENCES vpv_payments(paymentid),
  FOREIGN KEY (exchangerateid) REFERENCES vpv_exchangerates(exchangerateid)
);

-- cf_fee_type (fixed primary key definition)
CREATE TABLE cf_fee_type (
  fee_typeid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(30)   NOT NULL
);

-- cf_fee_structures
CREATE TABLE cf_fee_structures (
  structureid      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  value            DECIMAL(10,2) NOT NULL,
  fee_typeid       INT           NOT NULL,
  applicable_to    VARCHAR(100)  NOT NULL,
  effective_date   DATETIME      NOT NULL,
  end_date         DATETIME      NULL,
  groupid          INT           NOT NULL,
  FOREIGN KEY (fee_typeid) REFERENCES cf_fee_type(fee_typeid),
  FOREIGN KEY (groupid) REFERENCES vpv_groups(groupid)
);

-- cf_project_types
CREATE TABLE cf_project_types (
  pjtypeid         INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(100)  NOT NULL
);

-- cf_sectors
CREATE TABLE cf_sectors (
  sectorid         INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(50)   NOT NULL
);

-- cf_status_types
CREATE TABLE cf_status_types (
  statusid         INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(50)   NOT NULL,
  module           VARCHAR(30)   NOT NULL
);

-- cf_projects
CREATE TABLE cf_projects (
  projectid        INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  budget           DECIMAL(12,2) NOT NULL,
  equity_offered   DECIMAL(5,2)  NOT NULL,
  sectorid         INT           NOT NULL,
  startdate        DATETIME      NOT NULL,
  statusid         INT           NOT NULL,
  total_invested   DECIMAL(12,2) NOT NULL,
  proposalid       INT           NOT NULL,
  projecttypeid    INT           NOT NULL,
  min_funding_target DECIMAL(12,2) NOT NULL,
  max_funding_target DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (projecttypeid) REFERENCES cf_project_types(pjtypeid),
  FOREIGN KEY (sectorid) REFERENCES cf_sectors(sectorid),
  FOREIGN KEY (proposalid) REFERENCES vpv_proposal(proposalid),
  FOREIGN KEY (statusid) REFERENCES cf_status_types(statusid)
);

-- cf_project_fee_configurations
CREATE TABLE cf_project_fee_configurations (
  fee_configurationid INT        IDENTITY(1,1) PRIMARY KEY NOT NULL,
  projectid        INT           NOT NULL,
  structureid      INT           NOT NULL,
  start_date       DATETIME      NOT NULL,
  end_date         DATETIME      NULL,
  payment_scheduleid INT         NULL,
  statusid         INT           NOT NULL,
  FOREIGN KEY (structureid) REFERENCES cf_fee_structures(structureid),
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
  FOREIGN KEY (payment_scheduleid) REFERENCES vpv_paymentschedules(paymentscheduleid),
  FOREIGN KEY (statusid) REFERENCES cf_status_types(statusid)
);

-- cf_condition_types
CREATE TABLE cf_condition_types (
  condition_typeid INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(100)  NOT NULL
);

-- cf_approval_status_types
CREATE TABLE cf_approval_status_types (
  approvalid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(50)   NOT NULL
);

-- cf_project_conditions
CREATE TABLE cf_project_conditions (
  conditionid      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  description      VARCHAR(300)  NOT NULL,
  condition_typeid INT           NOT NULL,
  value            VARCHAR(100)  NOT NULL,
  approval_statusid INT          NOT NULL,
  approval_date    DATETIME      NULL,
  approval_voteid  INT           NULL,
  approved_by      INT           NULL,
  projectid        INT           NOT NULL,
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
  FOREIGN KEY (condition_typeid) REFERENCES cf_condition_types(condition_typeid),
  FOREIGN KEY (approved_by) REFERENCES vpv_users(userid),
  FOREIGN KEY (approval_voteid) REFERENCES vote_sessions(sessionid),
  FOREIGN KEY (approval_statusid) REFERENCES cf_approval_status_types(approvalid)
);

-- cf_goverment_conditions
CREATE TABLE cf_goverment_conditions (
  conditionid      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  description      VARCHAR(300)  NOT NULL,
  value            VARCHAR(100)  NOT NULL,
  approved         BIT           NOT NULL,
  condition_typeid INT           NOT NULL,
  projectid        INT           NOT NULL,
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
  FOREIGN KEY (condition_typeid) REFERENCES cf_condition_types(condition_typeid)
);

-- cf_benefit_types
CREATE TABLE cf_benefit_types (
  benefit_typeid   INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(50)   NOT NULL
);

-- cf_goverment_benefits
CREATE TABLE cf_goverment_benefits (
  goverbenefitid   INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  benefit_typeid   INT           NOT NULL,
  terms            TEXT          NOT NULL,
  description      VARCHAR(300)  NOT NULL,
  approval_statusid INT          NOT NULL,
  approval_date    DATETIME      NULL,
  negotiationid    INT           NULL,
  approved_by      INT           NULL,
  projectid        INT           NOT NULL,
  FOREIGN KEY (approval_statusid) REFERENCES cf_approval_status_types(approvalid),
  FOREIGN KEY (benefit_typeid) REFERENCES cf_benefit_types(benefit_typeid),
  FOREIGN KEY (approved_by) REFERENCES vpv_users(userid),
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid)
);

-- cf_project_complains
CREATE TABLE cf_project_complains (
  complainid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  description      VARCHAR(300)  NOT NULL,
  evidence_hash    VARBINARY(255) NOT NULL,
  submission_date  DATETIME      NOT NULL,
  legal_escalated  BIT           NOT NULL,
  projectid        INT           NOT NULL,
  userid           INT           NOT NULL,
  statusid         INT           NOT NULL,
  FOREIGN KEY (statusid) REFERENCES cf_status_types(statusid),
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- cf_project_complains_resolution
CREATE TABLE cf_project_complains_resolution (
  resolutionid     INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  resolution       TEXT          NOT NULL,
  date             DATETIME      NOT NULL,
  resolved_by      INT           NOT NULL,
  complainid       INT           NOT NULL,
  FOREIGN KEY (complainid) REFERENCES cf_project_complains(complainid),
  FOREIGN KEY (resolved_by) REFERENCES vpv_users(userid)
);

-- cf_project_endorsements
CREATE TABLE cf_project_endorsements (
  endorsementid    INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  approval_statusid INT          NOT NULL,
  approval_date    DATETIME      NULL,
  projectid        INT           NOT NULL,
  groupid          INT           NOT NULL,
  approved_by      INT           NULL,
  documentid       INT           NULL,
  vote_sessionid   INT           NULL,
  FOREIGN KEY (approval_statusid) REFERENCES cf_approval_status_types(approvalid),
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
  FOREIGN KEY (groupid) REFERENCES vpv_groups(groupid),
  FOREIGN KEY (approved_by) REFERENCES vpv_users(userid),
  FOREIGN KEY (documentid) REFERENCES vpv_digital_documents(documentid),
  FOREIGN KEY (vote_sessionid) REFERENCES vote_sessions(sessionid)
);

-- cf_report_types
CREATE TABLE cf_report_types (
  reporttypeid     INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(100)  NOT NULL
);

-- cf_financial_reports
CREATE TABLE cf_financial_reports (
  reportid         INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  period           VARCHAR(20)   NOT NULL,
  reporttypeid     INT           NOT NULL,
  document_hash    VARBINARY(255) NOT NULL,
  submission_date  DATETIME      NOT NULL,
  approved         BIT           NOT NULL,
  projectid        INT           NOT NULL,
  documentid       INT           NULL,
  uploaded_by      INT           NOT NULL,
  FOREIGN KEY (reporttypeid) REFERENCES cf_report_types(reporttypeid),
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
  FOREIGN KEY (uploaded_by) REFERENCES vpv_users(userid),
  FOREIGN KEY (documentid) REFERENCES vpv_digital_documents(documentid)
);

-- cf_investments
CREATE TABLE cf_investments (
  investmentid     INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  amount           DECIMAL(12,2) NOT NULL,
  investmentdate   DATETIME      NOT NULL,
  equity_obtained  DECIMAL(5,2)  NOT NULL,
  statusid         INT           NOT NULL,
  investment_hash  VARBINARY(255) NOT NULL,
  projectid        INT           NOT NULL,
  paymentid        INT           NULL,
  userid           INT           NOT NULL,
  FOREIGN KEY (statusid) REFERENCES cf_status_types(statusid),
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
  FOREIGN KEY (paymentid) REFERENCES vpv_payments(paymentid),
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- cf_projects_milestones
CREATE TABLE cf_projects_milestones (
  milestoneid      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(100)  NOT NULL,
  description      VARCHAR(255)  NOT NULL,
  target_date      DATETIME      NOT NULL,
  completion_date  DATETIME      NULL,
  disbursement_porcentage DECIMAL(5,2) NOT NULL,
  statusid         INT           NOT NULL,
  validation_required BIT        NOT NULL,
  projectid        INT           NOT NULL,
  vote_sessionid   INT           NULL,
  FOREIGN KEY (statusid) REFERENCES cf_status_types(statusid),
  FOREIGN KEY (vote_sessionid) REFERENCES vote_sessions(sessionid),
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid)
);

-- cf_project_disbursements
CREATE TABLE cf_project_disbursements (
  disbursementid   INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  amount           DECIMAL(12,2) NOT NULL,
  request_date     DATETIME      NOT NULL,
  approval_date    DATETIME      NULL,
  statusid         INT           NOT NULL,
  projectid        INT           NOT NULL,
  milestoneid      INT           NOT NULL,
  approved_by      INT           NULL,
  paymentid        INT           NULL,
  FOREIGN KEY (milestoneid) REFERENCES cf_projects_milestones(milestoneid),
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
  FOREIGN KEY (approved_by) REFERENCES vpv_users(userid),
  FOREIGN KEY (paymentid) REFERENCES vpv_payments(paymentid),
  FOREIGN KEY (statusid) REFERENCES cf_status_types(statusid)
);

-- cf_measurement_units
CREATE TABLE cf_measurement_units (
  unitid           INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(50)   NOT NULL,
  symbol           VARCHAR(10)   NOT NULL,
  description      VARCHAR(255)  NOT NULL
);

-- cf_milestone_kpis
CREATE TABLE cf_milestone_kpis (
  kpiid            INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  value            DECIMAL(10,2) NOT NULL,
  description      VARCHAR(255)  NOT NULL,
  unitid           INT           NOT NULL,
  FOREIGN KEY (unitid) REFERENCES cf_measurement_units(unitid)
);

-- cf_milestones_tasks
CREATE TABLE cf_milestones_tasks (
  taskid           INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  description      VARCHAR(255)  NOT NULL,
  fixed_amount     DECIMAL(12,2) NOT NULL,
  porcentage_amount DECIMAL(5,2) NOT NULL,
  completed        BIT           NOT NULL,
  kpiid            INT           NULL,
  statusid         INT           NOT NULL,
  milestoneid      INT           NOT NULL,
  validation_required BIT        NOT NULL,
  FOREIGN KEY (kpiid) REFERENCES cf_milestone_kpis(kpiid),
  FOREIGN KEY (milestoneid) REFERENCES cf_projects_milestones(milestoneid),
  FOREIGN KEY (statusid) REFERENCES cf_status_types(statusid)
);

-- cf_movement_types
CREATE TABLE cf_movement_types (
  movementid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(40)   NOT NULL
);

-- cf_investment_portfolios
CREATE TABLE cf_investment_portfolios (
  portfolioid      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  available_balance DECIMAL(12,2) NOT NULL,
  invested_balance DECIMAL(12,2) NOT NULL,
  last_update      DATETIME      NOT NULL,
  pending_returns  DECIMAL(12,2) NOT NULL,
  userid           INT           NOT NULL,
  FOREIGN KEY (userid) REFERENCES vpv_users(userid)
);

-- cf_agreement_types
CREATE TABLE cf_agreement_types (
  agreementid      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  name             VARCHAR(100)  NOT NULL
);

-- cf_investment_agreements
CREATE TABLE cf_investment_agreements (
  agreementid      INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  investmentid     INT           NOT NULL,
  agreement_type   INT           NOT NULL,
  expected_returns DECIMAL(5,2)  NOT NULL,
  equity_porcentage DECIMAL(5,2) NOT NULL,
  payment_scheduleid INT         NULL,
  signed_date      DATETIME      NOT NULL,
  statusid         INT           NOT NULL,
  last_modifies    DATETIME      NOT NULL,
  terms_documentedid INT         NULL,
  terms_hash       VARBINARY(255) NOT NULL,
  FOREIGN KEY (agreement_type) REFERENCES cf_agreement_types(agreementid),
  FOREIGN KEY (payment_scheduleid) REFERENCES vpv_paymentschedules(paymentscheduleid),
  FOREIGN KEY (statusid) REFERENCES cf_status_types(statusid),
  FOREIGN KEY (terms_documentedid) REFERENCES vpv_digital_documents(documentid),
  FOREIGN KEY (investmentid) REFERENCES cf_investments(investmentid)
);

-- cf_financial_movements
CREATE TABLE cf_financial_movements (
  movementid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  reference_code   VARCHAR(40)   NOT NULL,
  movement_typeid  INT           NOT NULL,
  amount           DECIMAL(12,2) NOT NULL,
  statusid         INT           NOT NULL,
  execution_date   DATETIME      NOT NULL,
  registered_date  DATETIME      NOT NULL,
  description      VARCHAR(300)  NOT NULL,
  investmentid     INT           NULL,
  source_portfolioid INT         NULL,
  destination_portfolioid INT    NULL,
  agreementid      INT           NULL,
  paymentid        INT           NULL,
  FOREIGN KEY (investmentid) REFERENCES cf_investments(investmentid),
  FOREIGN KEY (movement_typeid) REFERENCES cf_movement_types(movementid),
  FOREIGN KEY (statusid) REFERENCES cf_status_types(statusid),
  FOREIGN KEY (source_portfolioid) REFERENCES cf_investment_portfolios(portfolioid),
  FOREIGN KEY (paymentid) REFERENCES vpv_payments(paymentid),
  FOREIGN KEY (destination_portfolioid) REFERENCES cf_investment_portfolios(portfolioid),
  FOREIGN KEY (agreementid) REFERENCES cf_investment_agreements(agreementid)
);

-- cf_project_kpis
CREATE TABLE cf_project_kpis (
  kpiid            INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  projectid        INT           NOT NULL,
  value            DECIMAL(10,2) NOT NULL,
  description      VARCHAR(255)  NOT NULL,
  unitid           INT           NOT NULL,
  FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
  FOREIGN KEY (unitid) REFERENCES cf_measurement_units(unitid)
);

-- cf_tasks_evidences 
CREATE TABLE cf_tasks_evidences (
  evidenceid       INT           IDENTITY(1,1) PRIMARY KEY NOT NULL,
  upload_date      DATETIME      NOT NULL,
  description      VARCHAR(255)  NOT NULL,
  verification_hash VARBINARY(255) NOT NULL,
  validation_date  DATETIME      NULL,
  rejection_reason VARCHAR(200)  NULL,
  taskid           INT           NOT NULL,
  documentid       INT           NULL,
  uploaded_by      INT           NOT NULL,
  validation_status INT          NOT NULL,
  FOREIGN KEY (validation_status) REFERENCES cf_status_types(statusid),
  FOREIGN KEY (uploaded_by) REFERENCES vpv_users(userid),
  FOREIGN KEY (documentid) REFERENCES vpv_digital_documents(documentid),
  FOREIGN KEY (taskid) REFERENCES cf_milestones_tasks(taskid)
);
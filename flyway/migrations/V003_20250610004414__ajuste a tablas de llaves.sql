DROP TABLE dbo.vpv_digital_certificates;

DROP TABLE dbo.vpv_cryptographic_operations;

DROP TABLE dbo.vpv_security_questions;

DROP TABLE dbo.vpv_key_rotation;

DROP TABLE dbo.vpv_key_backups;

ALTER TABLE dbo.vpv_user_keys
ADD key_usage VARCHAR(20) NOT NULL;

ALTER TABLE dbo.vpv_user_keys
ADD public_key VARBINARY(255) NOT NULL;

ALTER TABLE dbo.vpv_user_keys
DROP COLUMN key_type,expiration_date,key_identifier,secure_storage;

ALTER TABLE dbo.vpv_mfa_devices
DROP COLUMN device_status;

ALTER TABLE dbo.vpv_mfa_devices
ADD is_primary BIT NOT NULL;

CREATE TABLE vpv_recovery_tokens (
  token_id INT,
  device_id INT,
  userid INT,
  token_hash VARCHAR(255),
  creation_date DATETIME,
  expiration_date DATETIME,
  remaining_attemps INT,
  token_status VARCHAR(20),
  request_ip_hash VARBINARY(255),
  request_device_hash VARBINARY(255),
  PRIMARY KEY (token_id),
  CONSTRAINT FK_recovery_devices
  FOREIGN KEY (device_id) REFERENCES dbo.vpv_mfa_devices(deviceid),
  CONSTRAINT FK_recovery_user
  FOREIGN KEY(userid) REFERENCES dbo.vpv_users(userid)
);

ALTER TABLE dbo.vpv_auth_methods
DROP COLUMN method_status,priority;

ALTER TABLE dbo.vpv_auth_sessions
DROP COLUMN session_status,used_factors,device_hash,ip_hash;

ALTER TABLE dbo.vpv_auth_sessions
DROP CONSTRAINT FK__vpv_auth___metho__5CA1C101;

ALTER TABLE dbo.vpv_auth_sessions
DROP COLUMN method_id;

ALTER TABLE dbo.vpv_auth_sessions
ADD key_id INT NOT NULL;

ALTER TABLE dbo.vpv_auth_sessions
ADD FOREIGN KEY (key_id) REFERENCES dbo.vpv_user_keys(key_id);
ALTER TABLE vpv_validation_process_log DROP CONSTRAINT FK_vpv_validation_process_log_result;
DROP TABLE vpv_validation_result_type

ALTER TABLE vpv_identity_validations DROP CONSTRAINT FK_vpv_identity_validations_process_stepid

ALTER TABLE vpv_validation_process_steps_log DROP CONSTRAINT FK_vpv_validation_process_steps_log_processid

ALTER TABLE vpv_validation_audit DROP CONSTRAINT FK_vpv_validation_audit_processid
ALTER TABLE vpv_validation_audit DROP CONSTRAINT FK_vpv_validation_audit_requestid


ALTER TABLE vpv_validation_request DROP CONSTRAINT FK_vpv_validation_request_processid;
ALTER TABLE vpv_validation_request DROP COLUMN processid;


DROP TABLE IF EXISTS vpv_validation_audit;
DROP TABLE IF EXISTS vpv_validation_process_steps_log;
DROP TABLE IF EXISTS vpv_validation_process_log;
DROP TABLE IF EXISTS vpv_validation_result_type;


ALTER TABLE vpv_document_type DROP COLUMN workflowid;
ALTER TABLE vpv_document_type DROP COLUMN workflow_name;
ALTER TABLE vpv_document_type DROP COLUMN parameters;
ALTER TABLE vpv_document_type DROP COLUMN schedule_interval;
ALTER TABLE vpv_document_type DROP COLUMN [order];
ALTER TABLE vpv_document_type DROP COLUMN url;



CREATE TABLE vpv_validation_workflow (
  workflowid         INT PRIMARY KEY NOT NULL,
  workflow_name      VARCHAR(100)    NOT NULL,
  description        VARCHAR(200)    NOT NULL,
  parameter          NVARCHAR(MAX)   NOT NULL, -- JSON
  schedule_interval  VARCHAR(15)     NOT NULL,
  url                VARCHAR(MAX)    NOT NULL,
  enabled            BIT             NOT NULL
);

CREATE TABLE vpv_document_workflows (
  workflow_order     TINYINT,
  creation_date      DATETIME,
  documentid         INT,
  workflowid         INT,
  enabled            BIT
);

ALTER TABLE vpv_document_workflows
ADD CONSTRAINT FK_vpv_document_workflows_documentid FOREIGN KEY (documentid) REFERENCES vpv_document_type(document_typeid);

ALTER TABLE vpv_document_workflows
ADD CONSTRAINT FK_vpv_document_workflows_workflowid FOREIGN KEY (workflowid) REFERENCES vpv_validation_workflow(workflowid);
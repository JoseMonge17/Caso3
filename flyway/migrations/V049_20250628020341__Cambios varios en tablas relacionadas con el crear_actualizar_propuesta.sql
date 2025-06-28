-- Tabla target propuesta

CREATE TABLE vpv_proposal_target (
    proposalid INT NOT NULL,
    demographicid INT NOT NULL,
    asignation_date DATETIME NOT NULL DEFAULT GETDATE(),
    assigned_by INT NOT NULL, -- usuario que configuró esta población meta
    enabled BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_vpv_proposal_target PRIMARY KEY (proposalid, demographicid),
    CONSTRAINT FK_vpv_proposal_target_proposal FOREIGN KEY (proposalid) REFERENCES vpv_proposal(proposalid),
    CONSTRAINT FK_vpv_proposal_target_demographic FOREIGN KEY (demographicid) REFERENCES vpv_demographic_data(demographicid)
);

-- Agregar cheksum en vpv_proposal_versions

ALTER TABLE vpv_proposal_versions
ADD checksum VARBINARY(64) NULL; -- SHA-256

-- Datos de log_source para sp_crear_actualizar
INSERT INTO vpv_log_source (name, system_component)
VALUES 
('Procedimiento sp_crear_actualizar_propuesta', 'Propuestas'),
('Procedimiento sp_revisar_propuesta', 'Propuestas');
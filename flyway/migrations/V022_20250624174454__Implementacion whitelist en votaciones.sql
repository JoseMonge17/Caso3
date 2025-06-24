ALTER TABLE [dbo].[vpv_addressasignations]
ALTER COLUMN [userid] INT NULL;

ALTER TABLE [dbo].[vpv_addressasignations]
ALTER COLUMN [entityid] INT NULL;

ALTER TABLE [dbo].[vpv_addressasignations]
ADD CONSTRAINT FK_addressasignations_entities
FOREIGN KEY ([entityid]) REFERENCES [dbo].[vpv_entities] ([entity_id]);

CREATE TABLE [dbo].[vote_session_ip_permissions] (
    [permissionid] INT IDENTITY(1,1) NOT NULL,
    [sessionid] INT NOT NULL,
    [whitelistid] INT NOT NULL,
    [allowed] BIT NOT NULL,
    [created_date] DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (permissionid),
    FOREIGN KEY ([sessionid]) REFERENCES [dbo].[vote_sessions] ([sessionid]),
    FOREIGN KEY ([whitelistid]) REFERENCES [dbo].[vpv_whitelist] ([whitelistid])
);

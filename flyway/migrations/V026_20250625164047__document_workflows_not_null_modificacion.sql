ALTER TABLE [dbo].[vpv_document_workflows]
ALTER COLUMN workflow_order TINYINT NOT NULL;

ALTER TABLE [dbo].[vpv_document_workflows]
ALTER COLUMN creation_date DATETIME NOT NULL;

ALTER TABLE [dbo].[vpv_document_workflows]
ALTER COLUMN documentid INT NOT NULL;

ALTER TABLE [dbo].[vpv_document_workflows]
ALTER COLUMN workflowid INT NOT NULL;

ALTER TABLE [dbo].[vpv_document_workflows]
ALTER COLUMN enabled BIT NOT NULL;

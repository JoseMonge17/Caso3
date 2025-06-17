ALTER TABLE [dbo].[vpv_addressasignations]
ADD [userid] INT NOT NULL;

ALTER TABLE [dbo].[vpv_addressasignations]  WITH CHECK 
ADD CONSTRAINT FK_addressasignations_users FOREIGN KEY ([userid])
REFERENCES [dbo].[vpv_users] ([userid]);
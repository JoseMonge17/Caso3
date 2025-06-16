-- Paso 1: Agregar la columna userid como NULLABLE
ALTER TABLE [dbo].[vote_ballots]
ADD [userid] INT NULL;
GO

-- Paso 2: Agregar la restricción de clave foránea
ALTER TABLE [dbo].[vote_ballots]  WITH CHECK 
ADD CONSTRAINT [FK_vote_ballots_vpv_users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[vpv_users] ([userid]);
GO
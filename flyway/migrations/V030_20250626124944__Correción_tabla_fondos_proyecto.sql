-- Primero eliminar la tabla existente (si tiene dependencias)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'cf_project_funds')
BEGIN
    -- Eliminar restricciones FK que puedan referenciar esta tabla
    DECLARE @sql NVARCHAR(MAX) = '';
    
    SELECT @sql = @sql + 'ALTER TABLE ' + OBJECT_NAME(parent_object_id) + 
                  ' DROP CONSTRAINT ' + name + ';' + CHAR(10)
    FROM sys.foreign_keys
    WHERE referenced_object_id = OBJECT_ID('cf_project_funds');
    
    EXEC sp_executesql @sql;
    
    -- Eliminar la tabla
    DROP TABLE cf_project_funds;
END

-- Crear la nueva versión correcta de la tabla
CREATE TABLE cf_project_funds (
    fundid INT IDENTITY(1,1) PRIMARY KEY,
    projectid INT NOT NULL,
    total_funds DECIMAL(12,2) NOT NULL DEFAULT 0,
    available_funds DECIMAL(12,2) NOT NULL DEFAULT 0,
    distributed_funds DECIMAL(12,2) NOT NULL DEFAULT 0,
    last_updated DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (projectid) REFERENCES cf_projects(projectid)
);

-- Crear índice para mejorar búsquedas por proyecto
CREATE UNIQUE INDEX IX_cf_project_funds_projectid ON cf_project_funds(projectid);
-- Tabla de fondos del proyecto
CREATE TABLE cf_project_funds (
    projectid INT PRIMARY KEY,
    total_funds DECIMAL(12,2) NOT NULL,
    available_funds DECIMAL(12,2) NOT NULL,
    distributed_funds DECIMAL(12,2) NOT NULL,
    last_updated DATETIME NOT NULL,
    FOREIGN KEY (projectid) REFERENCES cf_projects(projectid)
);
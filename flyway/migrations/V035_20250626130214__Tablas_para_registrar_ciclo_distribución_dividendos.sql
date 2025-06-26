 CREATE TABLE cf_dividend_distributions (
    distributionid INT IDENTITY(1,1) PRIMARY KEY,
    projectid INT NOT NULL,
    reportid INT NOT NULL,
    total_amount DECIMAL(18,2) NOT NULL,
    fees_amount DECIMAL(18,2) NOT NULL,
    distributed_amount DECIMAL(18,2) NOT NULL,
    distribution_date DATETIME NOT NULL,
    master_transactionid INT NOT NULL,
    created_by INT NOT NULL,
    FOREIGN KEY (projectid) REFERENCES cf_projects(projectid),
    FOREIGN KEY (reportid) REFERENCES cf_financial_reports(reportid),
    FOREIGN KEY (master_transactionid) REFERENCES vpv_transactions(transactionid),
    FOREIGN KEY (created_by) REFERENCES vpv_users(userid)
);

-- Tabla adicional para detalles y almacenar transacciones 
CREATE TABLE cf_distribution_transaction_types (
    transaction_typeid INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(20) NOT NULL, 
);

INSERT INTO cf_distribution_transaction_types (name)
VALUES 
    ('Inversionista'),
    ('Grupo');

CREATE TABLE cf_distribution_transactions (
    distribution_transactionid INT IDENTITY(1,1) PRIMARY KEY,
    distributionid INT NOT NULL,
    transactionid INT NOT NULL,
    transaction_typeid INT NOT NULL,
    related_id INT NOT NULL, -- Puede ser investmentid o groupid según el tipo
    amount DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (distributionid) REFERENCES cf_dividend_distributions(distributionid),
    FOREIGN KEY (transactionid) REFERENCES vpv_transactions(transactionid),
    FOREIGN KEY (transaction_typeid) REFERENCES cf_distribution_transaction_types(transaction_typeid)
);
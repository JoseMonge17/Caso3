-- Modificar las columnas DECIMAL(10,2) a DECIMAL(12,2)
ALTER TABLE vpv_payments 
ALTER COLUMN amount DECIMAL(12,2) NOT NULL;

ALTER TABLE vpv_payments 
ALTER COLUMN taxamount DECIMAL(12,2) NOT NULL;

ALTER TABLE vpv_payments 
ALTER COLUMN realamount DECIMAL(12,2) NOT NULL;
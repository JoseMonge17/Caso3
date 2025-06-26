-- 3. Cambiar a NOT NULL una vez que todos los registros tienen valor
ALTER TABLE cf_investment_portfolios
ALTER COLUMN portfoliotype INT NOT NULL;
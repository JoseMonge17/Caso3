-- 1. Agregar la columna portfoliotype (permite NULL temporalmente)
ALTER TABLE cf_investment_portfolios
ADD portfoliotype INT NULL
CONSTRAINT FK_cf_investment_portfolios_type 
REFERENCES cf_portfolio_types(foliotype);

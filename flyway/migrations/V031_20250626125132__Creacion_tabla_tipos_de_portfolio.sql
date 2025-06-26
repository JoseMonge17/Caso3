CREATE TABLE cf_portfolio_types (
  foliotype INT PRIMARY KEY,
  name VARCHAR(40) NOT NULL
);

INSERT INTO cf_portfolio_types (foliotype, name)
VALUES 
  (1, 'Usuario'),
  (2, 'Grupo');
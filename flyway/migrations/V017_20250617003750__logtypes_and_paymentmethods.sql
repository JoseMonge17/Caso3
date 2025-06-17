-- Severities (Nivel de criticidad)
INSERT INTO vpv_log_severity (name, severity_level)
VALUES 
('Información', 0),
('Advertencia', 0),
('Error', 1),
('Crítico', 1);

-- Sources (Origen del log)
INSERT INTO vpv_log_source (name, system_component)
VALUES 
('Procedimiento SP_CF_ProcesarInversion', 'Inversiones');

-- Types (Tipo de log)
INSERT INTO vpv_log_type (name, description)
VALUES 
('Error SQL', 'Error ocurrido durante la ejecución de un procedimiento almacenado SQL');


INSERT INTO api_providers (brand_name, legal_name, legal_identification, enabled)
VALUES
  ('BAC Credomatic', 'BAC International Bank, Inc.', '3101023456', 1),
  ('BNCR', 'Banco Nacional de Costa Rica', '3102001234', 1),
  ('BCR', 'Banco de Costa Rica', '3103005678', 1),
  ('PayPal', 'PayPal Inc.', '3104009876', 1);

INSERT INTO api_integrations (name, public_key, private_key, url, creation_date, last_update, enabled, idProvider)
VALUES
  ('Integración BAC',    CONVERT(VARBINARY(255), 'pk_bac'),    CONVERT(VARBINARY(255), 'sk_bac'),    'https://api.baccredomatic.com', GETDATE(), GETDATE(), 1, 1),
  ('Integración SINPE',  CONVERT(VARBINARY(255), 'pk_sinpe'),  CONVERT(VARBINARY(255), 'sk_sinpe'),  'https://api.sinpe.fi.cr',        GETDATE(), GETDATE(), 1, 2),
  ('Integración BCR',    CONVERT(VARBINARY(255), 'pk_bcr'),    CONVERT(VARBINARY(255), 'sk_bcr'),    'https://api.bancobcr.com',       GETDATE(), GETDATE(), 1, 3),
  ('Integración PayPal', CONVERT(VARBINARY(255), 'pk_paypal'), CONVERT(VARBINARY(255), 'sk_paypal'), 'https://api.paypal.com',         GETDATE(), GETDATE(), 1, 4);

INSERT INTO vpv_pay_methods (name, secret_key, logo_icon_url, enabled, idApiIntegration)
VALUES
  ('Tarjeta BAC',            CONVERT(VARBINARY(255), 'clave_bac'),    'https://cdn.baccredomatic.com/logo.png',   1, 1),
  ('SINPE Móvil',            CONVERT(VARBINARY(255), 'clave_sinpe'),  'https://sinpe.fi.cr/logo.png',             1, 2),
  ('Transferencia BCR',      CONVERT(VARBINARY(255), 'clave_bcr'),    'https://bancobcr.com/logo.png',            1, 3),
  ('PayPal',                 CONVERT(VARBINARY(255), 'clave_paypal'), 'https://www.paypalobjects.com/logo.png',   1, 4);

INSERT INTO vpv_available_pay_methods (name, token, exp_token, mask_account, idMethod)
VALUES
  ('Visa BAC 4321',        'tok_bac_4321',     DATEADD(MONTH, 6, GETDATE()), '****4321',         1),
  ('SINPE 88881234',       'tok_sinpe_8888',   DATEADD(MONTH, 6, GETDATE()), '8888-1234',        2),
  ('Cuenta IBAN BCR',      'tok_bcr_iban',     DATEADD(MONTH, 6, GETDATE()), 'CR05-01**-****',   3),
  ('Cuenta PayPal CR',     'tok_paypal_cr',    DATEADD(MONTH, 6, GETDATE()), 'usuario@****.com', 4);

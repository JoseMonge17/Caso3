-- Insertar estados de usuario
INSERT INTO vpv_user_status (statusid, name) VALUES
(1, 'Activo'),
(2, 'Inactivo'),
(3, 'Suspendido');

select * from vpv_user_status


-- Inserción Temporal de 25 Usuarios

INSERT INTO vpv_users (
    username, firstname, lastname, identification,
    registered, birthdate, email, password, statusid
) VALUES
('lgarcia', 'Luis', 'García', '1-234-5678', GETDATE(), '1990-05-12', 'lgarcia@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena1')), 1),
('mperez', 'María', 'Pérez', '2-345-6789', GETDATE(), '1988-10-04', 'mperez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena2')), 2),
('jlopez', 'José', 'López', '3-456-7890', GETDATE(), '1992-03-25', 'jlopez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena3')), 1),
('cfernandez', 'Carla', 'Fernández', '4-567-8901', GETDATE(), '1995-11-20', 'cfernandez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena4')), 3),
('rrodriguez', 'Raúl', 'Rodríguez', '5-678-9012', GETDATE(), '1987-07-09', 'rrodriguez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena5')), 1),
('dcastro', 'Diana', 'Castro', '6-789-0123', GETDATE(), '1991-12-30', 'dcastro@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena6')), 2),
('jmartinez', 'Javier', 'Martínez', '7-890-1234', GETDATE(), '1985-08-15', 'jmartinez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena7')), 1),
('agomez', 'Ana', 'Gómez', '8-901-2345', GETDATE(), '1993-06-28', 'agomez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena8')), 3),
('hnavarro', 'Héctor', 'Navarro', '9-012-3456', GETDATE(), '1990-01-18', 'hnavarro@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena9')), 1),
('sbautista', 'Sofía', 'Bautista', '0-123-4567', GETDATE(), '1989-04-22', 'sbautista@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena10')), 2),
('cmendoza', 'Carlos', 'Mendoza', '1-321-7654', GETDATE(), '1994-09-12', 'cmendoza@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena11')), 1),
('aalvarez', 'Andrea', 'Álvarez', '2-432-8765', GETDATE(), '1986-02-05', 'aalvarez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena12')), 2),
('fdominguez', 'Francisco', 'Domínguez', '3-543-9876', GETDATE(), '1992-07-30', 'fdominguez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena13')), 1),
('lruiz', 'Laura', 'Ruiz', '4-654-0987', GETDATE(), '1988-03-11', 'lruiz@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena14')), 3),
('gortega', 'Gabriel', 'Ortega', '5-765-1098', GETDATE(), '1991-06-03', 'gortega@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena15')), 1),
('rcruz', 'Rocío', 'Cruz', '6-876-2109', GETDATE(), '1987-11-17', 'rcruz@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena16')), 2),
('jmorales', 'Jorge', 'Morales', '7-987-3210', GETDATE(), '1993-01-25', 'jmorales@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena17')), 1),
('nvaldez', 'Natalia', 'Valdez', '8-098-4321', GETDATE(), '1990-09-09', 'nvaldez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena18')), 3),
('cpalacios', 'Cristian', 'Palacios', '9-109-5432', GETDATE(), '1995-05-20', 'cpalacios@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena19')), 1),
('ebeltran', 'Elena', 'Beltrán', '0-210-6543', GETDATE(), '1989-08-29', 'ebeltran@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena20')), 2),
('aduran', 'Alejandro', 'Durán', '1-321-7654', GETDATE(), '1986-12-08', 'aduran@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena21')), 1),
('mmolina', 'Mónica', 'Molina', '2-432-8765', GETDATE(), '1992-04-14', 'mmolina@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena22')), 2),
('oparedes', 'Oscar', 'Paredes', '3-543-9876', GETDATE(), '1987-10-01', 'oparedes@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena23')), 3),
('ymarquez', 'Yolanda', 'Márquez', '4-654-0987', GETDATE(), '1991-03-16', 'ymarquez@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena24')), 1),
('ivanrios', 'Iván', 'Ríos', '5-765-1098', GETDATE(), '1985-06-05', 'ivanrios@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'contrasena25')), 2);


-- select * from vpv_users
-- DELETE FROM vpv_users
-- DBCC CHECKIDENT ('vpv_users', RESEED, 0);


-- 1. Tipos de datos demográficos
INSERT INTO vpv_demographic_types (demographic_typeid, name)
VALUES (1, 'Género'), (2, 'Nivel educativo'), (3, 'Ocupación');

select * from vpv_demographic_types

-- Género
INSERT INTO vpv_demographic_data (code, description, demographic_typeid)
VALUES 
('M', 'Masculino', 1),
('F', 'Femenino', 1);

-- Nivel Educativo
INSERT INTO vpv_demographic_data (code, description, demographic_typeid)
VALUES
('PRIM', 'Primaria', 2),
('SEC', 'Secundaria', 2),
('UNI', 'Universitario', 2),
('POS', 'Profesional', 2);

-- Ocupación
INSERT INTO vpv_demographic_data (code, description, demographic_typeid)
VALUES
('EST', 'Estudiante', 3),
('EMP', 'Empleado', 3),
('DES', 'Desempleado', 3),
('AUT', 'Autónomo', 3);

select * from vpv_demographic_data

-- DELETE FROM vpv_demographic_data
-- DBCC CHECKIDENT ('vpv_demographic_data', RESEED, 0);

-- Género
INSERT INTO vpv_user_demographics (enabled, value, demographicid, userid)
VALUES (1, 'Masculino', 1, 1);

-- Nivel educativo
INSERT INTO vpv_user_demographics (enabled, value, demographicid, userid)
VALUES (1, 'Universitario', 2, 1);

-- Ocupación
INSERT INTO vpv_user_demographics (enabled, value, demographicid, userid)
VALUES (1, 'Empleado', 3, 1);





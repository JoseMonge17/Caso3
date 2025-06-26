ALTER TABLE vpv_permissions ALTER COLUMN permissioncode VARCHAR(20);

-- 1. Primero, insertamos los estados de usuario
INSERT INTO [dbo].[vpv_user_status] (statusid, name)
VALUES
(1, 'Active'),
(2, 'Inactive'),
(3, 'Pending'),
(4, 'Suspended'),
(5, 'Deleted');
GO


-- 2. Procedimiento para insertar usuarios
CREATE OR ALTER PROCEDURE [dbo].[insert_vpv_users]
AS
BEGIN
    DECLARE @i INT = 0;
    DECLARE @num_users INT = 1050; -- Poco más de 1000 usuarios
    DECLARE @nombre_usado VARCHAR(45);
    DECLARE @apellido_usado VARCHAR(45);
    DECLARE @email_base VARCHAR(80);
    DECLARE @identification VARCHAR(15);
    DECLARE @creation_date DATETIME;
    DECLARE @birthdate DATE;
    DECLARE @random_numbers VARCHAR(3);
    
    -- Tablas temporales con más nombres y apellidos para variedad
    CREATE TABLE #nombres (nombre VARCHAR(45));
    CREATE TABLE #apellidos (apellido VARCHAR(45));
    
    -- Ampliamos la lista de nombres
    INSERT INTO #nombres (nombre) VALUES
    ('Alejandro'),('Andrés'),('Antonio'),('Beatriz'),('Camila'),('Carlos'),('Carolina'),('Daniel'),
    ('David'),('Diego'),('Eduardo'),('Elena'),('Elizabeth'),('Fernando'),('Francisco'),('Gabriel'),
    ('Gloria'),('Guadalupe'),('Guillermo'),('Isabel'),('Javier'),('Jessica'),('Jorge'),('José'),
    ('Juan'),('Julia'),('Laura'),('Leticia'),('Luis'),('Manuel'),('María'),('Mario'),('Marta'),
    ('Martín'),('Miguel'),('Patricia'),('Paula'),('Pedro'),('Rafael'),('Raúl'),('Ricardo'),
    ('Roberto'),('Rosa'),('Sandra'),('Santiago'),('Sara'),('Sergio'),('Silvia'),('Sofía'),
    ('Teresa'),('Verónica'),('Victoria'),('Víctor'),('Alberto'),('Alejandra'),('Alicia'),
    ('Ana'),('Andrea'),('Ángel'),('Antonia'),('Arturo'),('Blanca'),('Claudia'),('Cristian'),
    ('Cristina'),('Diana'),('Enrique'),('Erica'),('Erick'),('Eva'),('Felipe'),('Gerardo'),
    ('Gilberto'),('Héctor'),('Hugo'),('Irene'),('Iván'),('Jaime'),('Jesús'),('Joaquín'),
    ('Jorge'),('Leonardo'),('Lorena'),('Lucía'),('Marcela'),('Marco'),('Margarita'),('Mariana'),
    ('Martha'),('Mayra'),('Mercedes'),('Minerva'),('Natalia'),('Norma'),('Óscar'),('Pablo'),
    ('Paulina'),('Ramón'),('Raquel'),('Reina'),('René'),('Rocío'),('Rodolfo'),('Rogelio'),
    ('Rubén'),('Samuel'),('Susana'),('Tania'),('Vanessa'),('Vicente'),('Yolanda');
    
    -- Ampliamos la lista de apellidos
    INSERT INTO #apellidos (apellido) VALUES
    ('Aguilar'),('Alvarado'),('Álvarez'),('Arroyo'),('Bautista'),('Benítez'),('Blanco'),('Bravo'),
    ('Cabrera'),('Calderón'),('Campos'),('Cano'),('Cárdenas'),('Carmona'),('Carrasco'),('Castañeda'),
    ('Castillo'),('Castro'),('Cervantes'),('Contreras'),('Cortés'),('Cruz'),('Delgado'),('Díaz'),
    ('Domínguez'),('Duarte'),('Durán'),('Espinoza'),('Estrada'),('Flores'),('Franco'),('Fuentes'),
    ('García'),('Garza'),('Gómez'),('González'),('Guerrero'),('Gutiérrez'),('Guzmán'),('Hernández'),
    ('Herrera'),('Hidalgo'),('Jiménez'),('Juárez'),('Lara'),('León'),('López'),('Luna'),
    ('Maldonado'),('Marín'),('Márquez'),('Mendoza'),('Mejía'),('Meléndez'),('Méndez'),('Molina'),
    ('Monroy'),('Montes'),('Morales'),('Moreno'),('Munguía'),('Muñoz'),('Nájera'),('Nava'),
    ('Navarro'),('Núñez'),('Ojeda'),('Olivares'),('Ortiz'),('Otero'),('Pacheco'),('Padilla'),
    ('Palacios'),('Paredes'),('Parra'),('Patiño'),('Paz'),('Peña'),('Pérez'),('Pineda'),
    ('Plascencia'),('Quintero'),('Ramírez'),('Ramos'),('Rangel'),('Reyes'),('Ríos'),('Rivera'),
    ('Robles'),('Rodríguez'),('Rojas'),('Romero'),('Rosales'),('Rosas'),('Ruiz'),('Salazar'),
    ('Salgado'),('Sánchez'),('Santana'),('Santiago'),('Santos'),('Saucedo'),('Segura'),('Sepúlveda'),
    ('Serrano'),('Sierra'),('Silva'),('Solís'),('Soto'),('Suárez'),('Tapia'),('Torres'),
    ('Trujillo'),('Valdez'),('Valencia'),('Valenzuela'),('Vargas'),('Vázquez'),('Vega'),('Velasco'),
    ('Vélez'),('Vera'),('Villa'),('Villanueva'),('Zamora'),('Zúñiga');
    
    -- Insertar más de 1000 usuarios activos
    WHILE @i < @num_users 
    BEGIN
        BEGIN TRY
            SELECT TOP 1 @nombre_usado = nombre FROM #nombres ORDER BY NEWID();
            SELECT TOP 1 @apellido_usado = apellido FROM #apellidos ORDER BY NEWID();
            
            -- Generar 3 números aleatorios para el username
            SET @random_numbers = RIGHT('000' + CAST(FLOOR(RAND() * 1000) AS VARCHAR(3)), 3);
            
            -- Generar email más realista
            SET @email_base = LOWER(
                SUBSTRING(@nombre_usado, 1, 1) + 
                @apellido_usado + 
                CAST(FLOOR(RAND() * 100) AS VARCHAR(2))
            );
            
            -- Generar identificación costarricense válida (cédula física)
            DECLARE @part1 INT = FLOOR(1 + RAND() * 8); -- Primer dígito (1-8)
            DECLARE @part2 INT = FLOOR(RAND() * 10000); -- Parte media (0000-9999)
            DECLARE @part3 INT = FLOOR(RAND() * 10000); -- Parte final (0000-9999)
            
            -- Asegurar que los números tengan ceros a la izquierda
            SET @identification = 
                CAST(@part1 AS VARCHAR(1)) + '-' + 
                RIGHT('0000' + CAST(@part2 AS VARCHAR(4)), 4) + '-' + 
                RIGHT('0000' + CAST(@part3 AS VARCHAR(4)), 4);
            
            -- Fechas más realistas
            SET @creation_date = DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE());
            SET @creation_date = DATEADD(HOUR, FLOOR(RAND() * 24), @creation_date);
            SET @creation_date = DATEADD(MINUTE, FLOOR(RAND() * 60), @creation_date);
            
            -- Fecha de nacimiento (entre 18 y 70 años atrás)
            SET @birthdate = DATEADD(YEAR, -(18 + FLOOR(RAND() * 52)), GETDATE());
            SET @birthdate = DATEADD(DAY, FLOOR(RAND() * 365), @birthdate);
            
            -- Insertar usuario
            INSERT INTO [dbo].[vpv_users] 
            (username, firstname, lastname, identification, registered, birthdate, email, password, statusid) 
            VALUES 
            (
                LOWER(@nombre_usado + '_' + @apellido_usado + @random_numbers), 
                @nombre_usado, 
                @apellido_usado,
                @identification,
                @creation_date,
                @birthdate,
                @email_base + '@' + 
                    CASE FLOOR(RAND() * 3)
                        WHEN 0 THEN 'gmail.com'
                        WHEN 1 THEN 'hotmail.com'
                        ELSE 'outlook.com'
                    END,
                CONVERT(VARBINARY(250), 'TempPass' + CAST(FLOOR(RAND() * 10000) AS VARCHAR(5))),
                CASE 
                    WHEN @i % 100 = 0 THEN 2 -- Inactive
                    WHEN @i % 50 = 0 THEN 3 -- Pending
                    WHEN @i % 20 = 0 THEN 4 -- Suspended
                    ELSE 1 -- Active
                END
            );
            
            SET @i = @i + 1;
            
            IF @i % 100 = 0
                PRINT 'Insertados ' + CAST(@i AS VARCHAR) + ' usuarios de ' + CAST(@num_users AS VARCHAR);
        END TRY
        BEGIN CATCH
            PRINT 'Error al insertar usuario: ' + ERROR_MESSAGE();
            PRINT 'Intento con nuevo conjunto de datos...';
        END CATCH
    END;
    
    DROP TABLE #nombres;
    DROP TABLE #apellidos;
    
    SELECT 'Proceso completado. Se insertaron ' + CAST(COUNT(*) AS VARCHAR) + ' usuarios.' AS resultado
    FROM [dbo].[vpv_users];
END;
GO

-- 3. Procedimiento para insertar módulos
CREATE OR ALTER PROCEDURE [dbo].[insert_vpv_modules]
AS
BEGIN
    INSERT INTO [dbo].[vpv_modules] (name) 
    VALUES 
    ('Administración de Usuarios'),
    ('Gestión de Propuestas'),
    ('Sesiones de Votación'),
    ('Resultados y Estadísticas'),
    ('Configuración del Sistema'),
    ('Validación de Identidad'),
    ('Participación Ciudadana');
    
    SELECT 'Insertados ' + CAST(@@ROWCOUNT AS VARCHAR) + ' módulos para sistema de votación' AS resultado;
END;
GO

-- 4. Procedimiento para insertar roles básicos
CREATE OR ALTER PROCEDURE [dbo].[insert_vpv_roles]
AS
BEGIN
    -- Insertar los 3 roles básicos
    INSERT INTO [dbo].[vpv_roles] 
    (rolename, description, systemrole, asignationdate)
    VALUES 
    ('Ciudadano', 'Usuario estándar que puede votar y crear propuestas', 1, GETDATE()),
    ('Administrador', 'Acceso completo al sistema', 1, GETDATE()),
    ('Moderador', 'Puede revisar y aprobar propuestas', 1, GETDATE()),
    ('Representante', 'Representante de entidades que pueden proponer iniciativas', 1, GETDATE()),
    ('Auditor', 'Solo acceso a reportes y resultados', 1, GETDATE());
    
	SELECT 'Insertados ' + CAST(@@ROWCOUNT AS VARCHAR) + ' roles para sistema de votación' AS resultado;
END;
GO

-- 5. Procedimiento para insertar permisos
CREATE OR ALTER PROCEDURE [dbo].[insert_vpv_permissions]
AS
BEGIN

    -- Obtener IDs de módulos
    DECLARE @admin_mod INT, @propuestas_mod INT, @votacion_mod INT, 
            @resultados_mod INT, @config_mod INT, @validacion_mod INT, @participacion_mod INT;
    
    SELECT @admin_mod = moduleid FROM [dbo].[vpv_modules] WHERE name = 'Administración de Usuarios';
    SELECT @propuestas_mod = moduleid FROM [dbo].[vpv_modules] WHERE name = 'Gestión de Propuestas';
    SELECT @votacion_mod = moduleid FROM [dbo].[vpv_modules] WHERE name = 'Sesiones de Votación';
    SELECT @resultados_mod = moduleid FROM [dbo].[vpv_modules] WHERE name = 'Resultados y Estadísticas';
    SELECT @config_mod = moduleid FROM [dbo].[vpv_modules] WHERE name = 'Configuración del Sistema';
    SELECT @validacion_mod = moduleid FROM [dbo].[vpv_modules] WHERE name = 'Validación de Identidad';
    SELECT @participacion_mod = moduleid FROM [dbo].[vpv_modules] WHERE name = 'Participación Ciudadana';


    -- Permisos para el módulo de User Management
    INSERT INTO [dbo].[vpv_permissions] 
    (permissioncode, description, htmlObject, moduleid)
    VALUES 
    -- Administración de Usuarios
    ('USR_VIEW', 'Ver usuarios', 'user-view-btn', @admin_mod),
    ('USR_EDIT', 'Editar usuarios', 'user-edit-btn', @admin_mod),
    ('USR_CREATE', 'Crear usuarios', 'user-create-btn', @admin_mod),
    
    -- Gestión de Propuestas
    ('PROP_CREATE', 'Crear propuestas', 'prop-create-btn', @propuestas_mod),
    ('PROP_REVIEW', 'Revisar propuestas', 'prop-review-btn', @propuestas_mod),
    ('PROP_APPROVE', 'Aprobar propuestas', 'prop-approve-btn', @propuestas_mod),
    ('PROP_COMMENT', 'Comentar propuestas', 'prop-comment-btn', @propuestas_mod),
    
    -- Sesiones de Votación
    ('VOTE_CREATE', 'Crear sesiones de votación', 'vote-create-btn', @votacion_mod),
    ('VOTE_MANAGE', 'Gestionar votaciones', 'vote-manage-btn', @votacion_mod),
    ('VOTE_PARTICIPATE', 'Participar en votaciones', 'vote-participate-btn', @votacion_mod),
    
    -- Resultados y Estadísticas
    ('RES_VIEW', 'Ver resultados', 'res-view-btn', @resultados_mod),
    ('RES_EXPORT', 'Exportar resultados', 'res-export-btn', @resultados_mod),
    ('RES_ANALYZE', 'Analizar estadísticas', 'res-analyze-btn', @resultados_mod),
    
    -- Configuración del Sistema
    ('CFG_SYSTEM', 'Configurar sistema', 'cfg-system-btn', @config_mod),
    ('CFG_ROLES', 'Gestionar roles', 'cfg-roles-btn', @config_mod),
    
    -- Validación de Identidad
    ('VAL_IDENTIFY', 'Validar identidad', 'val-identify-btn', @validacion_mod),
    
    -- Participación Ciudadana
    ('PART_COMMUNITY', 'Participación comunitaria', 'part-community-btn', @participacion_mod);

    SELECT 'Insertados ' + CAST(@@ROWCOUNT AS VARCHAR) + ' permisos para sistema de votación' AS resultado;
END;
GO

-- 6. Procedimiento para asignar permisos a roles
CREATE OR ALTER PROCEDURE [dbo].[assign_vpv_permissions_to_roles]
AS
BEGIN
    -- Asignar permisos completos a Administrador
    INSERT INTO [dbo].[vpv_rolepermissions] 
    (asignationdate, checksum, enable, deleted, lastupdate, roleid, permissionid)
    SELECT 
        GETDATE(), 
        HASHBYTES('SHA2_256', 'admin-perm-' + CAST(p.permissionid AS VARCHAR)), 
        1, 
        0, 
        GETDATE(), 
        (SELECT roleid FROM vpv_roles WHERE rolename = 'Administrador'), 
        p.permissionid
    FROM vpv_permissions p;
    
    -- Permisos para Moderador
    INSERT INTO [dbo].[vpv_rolepermissions] 
    (asignationdate, checksum, enable, deleted, lastupdate, roleid, permissionid)
    SELECT 
        GETDATE(), 
        HASHBYTES('SHA2_256', 'mod-perm-' + CAST(p.permissionid AS VARCHAR)), 
        1, 
        0, 
        GETDATE(), 
        (SELECT roleid FROM vpv_roles WHERE rolename = 'Moderador'), 
        p.permissionid
    FROM vpv_permissions p
    WHERE p.permissioncode IN ('PROP_REVIEW', 'PROP_APPROVE', 'PROP_COMMENT', 'RES_VIEW');
    
    -- Permisos para Representante
    INSERT INTO [dbo].[vpv_rolepermissions] 
    (asignationdate, checksum, enable, deleted, lastupdate, roleid, permissionid)
    SELECT 
        GETDATE(), 
        HASHBYTES('SHA2_256', 'rep-perm-' + CAST(p.permissionid AS VARCHAR)), 
        1, 
        0, 
        GETDATE(), 
        (SELECT roleid FROM vpv_roles WHERE rolename = 'Representante'), 
        p.permissionid
    FROM vpv_permissions p
    WHERE p.permissioncode IN ('PROP_CREATE', 'PROP_COMMENT', 'VOTE_PARTICIPATE', 'RES_VIEW');
    
    -- Permisos para Ciudadano
    INSERT INTO [dbo].[vpv_rolepermissions] 
    (asignationdate, checksum, enable, deleted, lastupdate, roleid, permissionid)
    SELECT 
        GETDATE(), 
        HASHBYTES('SHA2_256', 'cit-perm-' + CAST(p.permissionid AS VARCHAR)), 
        1, 
        0, 
        GETDATE(), 
        (SELECT roleid FROM vpv_roles WHERE rolename = 'Ciudadano'), 
        p.permissionid
    FROM vpv_permissions p
    WHERE p.permissioncode IN ('PROP_CREATE', 'PROP_COMMENT', 'VOTE_PARTICIPATE', 'RES_VIEW');
    
    -- Permisos para Auditor
    INSERT INTO [dbo].[vpv_rolepermissions] 
    (asignationdate, checksum, enable, deleted, lastupdate, roleid, permissionid)
    SELECT 
        GETDATE(), 
        HASHBYTES('SHA2_256', 'audit-perm-' + CAST(p.permissionid AS VARCHAR)), 
        1, 
        0, 
        GETDATE(), 
        (SELECT roleid FROM vpv_roles WHERE rolename = 'Auditor'), 
        p.permissionid
    FROM vpv_permissions p
    WHERE p.permissioncode IN ('RES_VIEW', 'RES_EXPORT', 'RES_ANALYZE');
    
	SELECT 'Asignación de permisos completada para sistema de votación' AS resultado;
END;
GO

-- 7. Procedimiento para asignar roles a usuarios
CREATE OR ALTER PROCEDURE [dbo].[assign_vpv_roles_to_users]
AS
BEGIN
    DECLARE @admin_count INT = 5;
    DECLARE @moderator_count INT = 10;
    DECLARE @representative_count INT = 20;
    DECLARE @auditor_count INT = 5;
    DECLARE @i INT = 0;
    DECLARE @user_id INT;
    
    -- Asignar rol de administrador a los primeros 5 usuarios
    WHILE @i < @admin_count 
    BEGIN
        SET @user_id = @i + 1;
        
        INSERT INTO [dbo].[vpv_user_roles] 
        (enabled, roleid, userid)
        VALUES 
        (1, 
         (SELECT roleid FROM vpv_roles WHERE rolename = 'Administrador'), 
         @user_id);
         
        SET @i = @i + 1;
    END;
    
    -- Asignar rol de moderador a los siguientes 10 usuarios
    SET @i = 0;
    WHILE @i < @moderator_count 
    BEGIN
        SET @user_id = @i + @admin_count + 1;
        
        INSERT INTO [dbo].[vpv_user_roles] 
        (enabled, roleid, userid)
        VALUES 
        (1, 
         (SELECT roleid FROM vpv_roles WHERE rolename = 'Moderador'), 
         @user_id);
         
        SET @i = @i + 1;
    END;
    
    -- Asignar rol de representante a los siguientes 20 usuarios
    SET @i = 0;
    WHILE @i < @representative_count 
    BEGIN
        SET @user_id = @i + @admin_count + @moderator_count + 1;
        
        INSERT INTO [dbo].[vpv_user_roles] 
        (enabled, roleid, userid)
        VALUES 
        (1, 
         (SELECT roleid FROM vpv_roles WHERE rolename = 'Representante'), 
         @user_id);
         
        SET @i = @i + 1;
    END;
    
    -- Asignar rol de auditor a los siguientes 5 usuarios
    SET @i = 0;
    WHILE @i < @auditor_count 
    BEGIN
        SET @user_id = @i + @admin_count + @moderator_count + @representative_count + 1;
        
        INSERT INTO [dbo].[vpv_user_roles] 
        (enabled, roleid, userid)
        VALUES 
        (1, 
         (SELECT roleid FROM vpv_roles WHERE rolename = 'Auditor'), 
         @user_id);
         
        SET @i = @i + 1;
    END;
    
    -- Todos los demás usuarios obtienen rol de ciudadano
    INSERT INTO [dbo].[vpv_user_roles] 
    (enabled, roleid, userid)
    SELECT 
        1, 
        (SELECT roleid FROM vpv_roles WHERE rolename = 'Ciudadano'), 
        userid
    FROM vpv_users
    WHERE userid > (@admin_count + @moderator_count + @representative_count + @auditor_count)
    AND userid <= 1050; -- Asumiendo que hay al menos 1000 usuarios
    
    SELECT 'Asignación de roles completada: ' +
           CAST((SELECT COUNT(*) FROM vpv_user_roles WHERE roleid = (SELECT roleid FROM vpv_roles WHERE rolename = 'Administrador')) AS VARCHAR) + ' administradores, ' +
           CAST((SELECT COUNT(*) FROM vpv_user_roles WHERE roleid = (SELECT roleid FROM vpv_roles WHERE rolename = 'Moderador')) AS VARCHAR) + ' moderadores, ' +
           CAST((SELECT COUNT(*) FROM vpv_user_roles WHERE roleid = (SELECT roleid FROM vpv_roles WHERE rolename = 'Representante')) AS VARCHAR) + ' representantes, ' +
           CAST((SELECT COUNT(*) FROM vpv_user_roles WHERE roleid = (SELECT roleid FROM vpv_roles WHERE rolename = 'Auditor')) AS VARCHAR) + ' auditores, ' +
           CAST((SELECT COUNT(*) FROM vpv_user_roles WHERE roleid = (SELECT roleid FROM vpv_roles WHERE rolename = 'Ciudadano')) AS VARCHAR) + ' ciudadanos' AS resultado;
END;
GO

-- 8. Procedimiento para insertar tipos de entidad, estados y tipos de ID legal
CREATE PROCEDURE [dbo].[insert_vpv_entity_reference_data]
AS
BEGIN
    -- Insertar tipos de estado
    INSERT INTO [dbo].[vpv_status_types] (name, description)
    VALUES 
    ('Active', 'Entidad activa y operativa'),
    ('Inactive', 'Entidad inactiva temporalmente'),
    ('Pending Approval', 'Entidad pendiente de aprobación'),
    ('Suspended', 'Entidad suspendida por incumplimiento'),
    ('Deleted', 'Entidad eliminada del sistema');

    -- Insertar tipos de identificación legal
    INSERT INTO [dbo].[vpv_legal_id_types] (name, description)
    VALUES 
    ('Cédula Física', 'Documento de identificación para personas físicas'),
    ('Cédula Jurídica', 'Documento de identificación para empresas'),
    ('DIMEX', 'Documento de identificación para extranjeros'),
    ('NITE', 'Número de identificación tributaria especial');

    -- Insertar tipos de entidad
    INSERT INTO [dbo].[vpv_entity_types] (name, description)
    VALUES 
    ('Persona Física', 'Individuo o persona natural'),
    ('Empresa Privada', 'Empresa o negocio privado'),
    ('Gobierno', 'Entidad gubernamental'),
    ('ONG', 'Organización no gubernamental'),
    ('Asociación', 'Asociación o grupo organizado');
    
    SELECT 'Datos de referencia para entidades insertados' AS resultado;
END;
GO

-- 9. Procedimiento para insertar entidades
CREATE OR ALTER PROCEDURE [dbo].[insert_vpv_entities]
AS
BEGIN
    
    -- Verificar y crear tipos de entidad específicos para sistema de votación
    IF NOT EXISTS (SELECT 1 FROM [dbo].[vpv_entity_types] WHERE name = 'Gobierno Local')
    BEGIN
        INSERT INTO [dbo].[vpv_entity_types] (name, description)
        VALUES 
        ('Gobierno Local', 'Municipalidades y gobiernos locales'),
        ('ONG', 'Organizaciones no gubernamentales'),
        ('Asociación Comunitaria', 'Asociaciones de desarrollo comunal'),
        ('Partido Político', 'Organizaciones políticas'),
        ('Empresa Pública', 'Instituciones estatales');
    END
    
    -- Obtener ID para cédula jurídica (debe existir)
    DECLARE @legal_id_type INT;
    SELECT @legal_id_type = legal_id_type FROM [dbo].[vpv_legal_id_types] WHERE name = 'Cédula Jurídica';
    
    IF @legal_id_type IS NULL
    BEGIN
        RAISERROR('No se encontró el tipo de identificación legal "Cédula Jurídica". Ejecute insert_vpv_entity_reference_data primero.', 16, 1);
        RETURN;
    END
    
    -- Insertar entidades con nombres coherentes para sistema de votación
    DECLARE @i INT = 0;
    DECLARE @num_entities INT = 50; -- Cantidad de entidades a crear
    DECLARE @legal_name VARCHAR(255);
    DECLARE @public_name VARCHAR(255);
    DECLARE @legal_id VARCHAR(50);
    DECLARE @reg_date DATETIME;
    DECLARE @entity_type INT;
    DECLARE @status_type INT = 1; -- Todas activas por defecto
    
    -- Tablas temporales con nombres para diferentes tipos de entidades
    CREATE TABLE #municipalidades (id INT IDENTITY(1,1), nombre VARCHAR(100));
    INSERT INTO #municipalidades VALUES
    ('San José'), ('Alajuela'), ('Cartago'), ('Heredia'), ('Liberia'),
    ('Puntarenas'), ('Limón'), ('Desamparados'), ('Escazú'), ('Curridabat');
    
    CREATE TABLE #asociaciones (id INT IDENTITY(1,1), nombre VARCHAR(100));
    INSERT INTO #asociaciones VALUES
    ('Moravia'), ('Sabanilla'), ('San Pedro'), ('Rohrmoser'), ('La Sabana'),
    ('Tibás'), ('San Sebastián'), ('Goicoechea'), ('Purral'), ('Guadalupe');
    
    CREATE TABLE #ongs (id INT IDENTITY(1,1), nombre VARCHAR(100));
    INSERT INTO #ongs VALUES
    ('Ambiental Costarricense'), ('Derechos Humanos CR'), ('Transparencia Internacional'), 
    ('Desarrollo Sostenible'), ('Educación para Todos'), ('Mujeres Líderes'),
    ('Tecnología Cívica'), ('Participación Ciudadana'), ('Acción Social'), ('Voluntarios CR');
    
    CREATE TABLE #partidos (id INT IDENTITY(1,1), nombre VARCHAR(100));
    INSERT INTO #partidos VALUES
    ('Unidad Social'), ('Renovación Democrática'), ('Alianza Verde'), 
    ('Progreso Nacional'), ('Fuerza Ciudadana'), ('Integración Popular'),
    ('Nueva República'), ('Movimiento Activo'), ('Unión Patriótica'), ('Opción Joven');
    
    WHILE @i < @num_entities 
    BEGIN
        BEGIN TRY
            -- Determinar tipo de entidad según el índice
            IF @i < 10 -- Municipalidades
            BEGIN
                SELECT @public_name = 'Municipalidad de ' + nombre 
                FROM #municipalidades 
                WHERE id = @i + 1;
                
                SET @legal_name = @public_name;
                SELECT @entity_type = entity_type_id FROM vpv_entity_types WHERE name = 'Gobierno Local';
            END
            ELSE IF @i < 20 -- Asociaciones
            BEGIN
                SELECT @public_name = 'Asociación de Desarrollo de ' + nombre 
                FROM #asociaciones
                WHERE id = @i - 9;
                
                SET @legal_name = @public_name;
                SELECT @entity_type = entity_type_id FROM vpv_entity_types WHERE name = 'Asociación Comunitaria';
            END
            ELSE IF @i < 30 -- ONGs
            BEGIN
                SELECT @public_name = 'ONG ' + nombre 
                FROM #ongs
                WHERE id = @i - 19;
                
                SET @legal_name = @public_name;
                SELECT @entity_type = entity_type_id FROM vpv_entity_types WHERE name = 'ONG';
            END
            ELSE -- Partidos políticos
            BEGIN
                SELECT @public_name = 'Partido ' + nombre 
                FROM #partidos
                WHERE id = @i - 29;
                
                SET @legal_name = @public_name + ' - Comité Político';
                SELECT @entity_type = entity_type_id FROM vpv_entity_types WHERE name = 'Partido Político';
            END
            
            -- Generar ID legal (cédula jurídica) con formato correcto
            DECLARE @random_part VARCHAR(9) = RIGHT('000000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999999 AS VARCHAR(9)), 9);
            SET @legal_id = '3-' + @random_part;
            
            -- Fecha de registro (últimos 5 años)
            SET @reg_date = DATEADD(DAY, -FLOOR(RAND() * 1825), GETDATE());
            
            -- Validar que no tengamos valores NULL
            IF @legal_name IS NULL OR @public_name IS NULL OR @legal_id IS NULL OR @entity_type IS NULL
            BEGIN
                PRINT 'Advertencia: Valores NULL detectados para entidad ' + CAST(@i AS VARCHAR);
                CONTINUE;
            END
            
            -- Insertar entidad
            INSERT INTO [dbo].[vpv_entities] 
            (legal_name, public_name, legal_id_number, registration_date, is_active, 
             status_type_id, legal_id_type, entity_type_id, validator_group_id)
            VALUES 
            (
                @legal_name,
                @public_name,
                @legal_id,
                @reg_date,
                1, -- is_active
                @status_type,
                @legal_id_type, -- cédula jurídica
                @entity_type,
                1 -- validator_group_id
            );
            
            SET @i = @i + 1;
        END TRY
        BEGIN CATCH
            PRINT 'Error al insertar entidad ' + CAST(@i AS VARCHAR) + ': ' + ERROR_MESSAGE();
            -- Continuar con la siguiente entidad
            SET @i = @i + 1;
        END CATCH
    END;
    
    -- Limpiar tablas temporales
    DROP TABLE #municipalidades;
    DROP TABLE #asociaciones;
    DROP TABLE #ongs;
    DROP TABLE #partidos;
    
    SELECT 'Proceso completado. Se insertaron ' + CAST(COUNT(*) AS VARCHAR) + ' entidades para sistema de votación.' AS resultado
    FROM [dbo].[vpv_entities];
END;
GO

-- 10. Procedimiento para insertar representantes de entidades
CREATE OR ALTER PROCEDURE [dbo].[insert_vpv_entity_representatives]
AS
BEGIN
    DECLARE @i INT = 0;
    DECLARE @num_reps INT = 200; -- Aprox. 2 por entidad
    DECLARE @entity_id INT;
    DECLARE @user_id INT;
    DECLARE @start_date DATETIME;
    DECLARE @end_date DATETIME;
    
    -- Verificar que hay entidades y usuarios disponibles
    IF NOT EXISTS (SELECT 1 FROM [dbo].[vpv_entities]) OR NOT EXISTS (SELECT 1 FROM [dbo].[vpv_users])
    BEGIN
        RAISERROR('No hay entidades o usuarios disponibles. Ejecute insert_vpv_entities e insert_vpv_users primero.', 16, 1);
        RETURN;
    END
    
    -- Insertar representantes
    WHILE @i < @num_reps 
    BEGIN
        BEGIN TRY
            -- Seleccionar entidad y usuario aleatorios existentes
            SELECT TOP 1 @entity_id = entity_id FROM vpv_entities ORDER BY NEWID();
            SELECT TOP 1 @user_id = userid FROM vpv_users ORDER BY NEWID();
            
            -- Fechas de representación
            SET @start_date = DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE());
            SET @end_date = DATEADD(DAY, 365 + FLOOR(RAND() * 730), @start_date);
            
            -- Insertar representante
            INSERT INTO [dbo].[vpv_entity_representative] 
            (role, department, proof_doc_hash, start_date, end_date, is_primary, 
             representation_hash, entity_id, user_id)
            VALUES 
            (
                CASE FLOOR(RAND() * 5)
                    WHEN 0 THEN 'Representante Legal'
                    WHEN 1 THEN 'Presidente'
                    WHEN 2 THEN 'Secretario'
                    WHEN 3 THEN 'Tesorero'
                    ELSE 'Vocal'
                END,
                CASE FLOOR(RAND() * 5)
                    WHEN 0 THEN 'Junta Directiva'
                    WHEN 1 THEN 'Comisión Electoral'
                    WHEN 2 THEN 'Comité Ejecutivo'
                    WHEN 3 THEN 'Consejo Municipal'
                    ELSE 'Comisión de Votación'
                END,
                CONVERT(VARBINARY(255), 'hash_documento_' + CAST(@i AS VARCHAR)),
                @start_date,
                @end_date,
                CASE WHEN @i % 10 = 0 THEN 1 ELSE 0 END, -- 10% son primarios
                CONVERT(VARBINARY(255), 'hash_representacion_' + CAST(@i AS VARCHAR)),
                @entity_id,
                @user_id
            );
            
            SET @i = @i + 1;
        END TRY
        BEGIN CATCH
            PRINT 'Error al insertar representante: ' + ERROR_MESSAGE();
        END CATCH
    END;
    
    SELECT 'Proceso completado. Se insertaron ' + CAST(COUNT(*) AS VARCHAR) + ' representantes de entidades.' AS resultado
    FROM [dbo].[vpv_entity_representative];
END;
GO

-- 11. Procedimiento para insertar claves de usuario
CREATE PROCEDURE [dbo].[insert_vpv_user_keys]
AS
BEGIN
    DECLARE @i INT = 0;
    DECLARE @num_keys INT = 500; -- Aprox. la mitad de los usuarios tendrán claves
    DECLARE @user_id INT;
    DECLARE @creation_date DATETIME;
    
    -- Insertar claves
    WHILE @i < @num_keys 
    BEGIN
        -- Seleccionar usuario aleatorio que no tenga clave aún
        SELECT TOP 1 @user_id = u.userid 
        FROM vpv_users u
        LEFT JOIN vpv_user_keys k ON u.userid = k.userid
        WHERE k.key_id IS NULL
        ORDER BY NEWID();
        
        IF @user_id IS NULL
            BREAK; -- Todos los usuarios tienen clave
        
        -- Fecha de creación
        SET @creation_date = DATEADD(DAY, -FLOOR(RAND() * 180), GETDATE());
        
        -- Insertar clave
        INSERT INTO [dbo].[vpv_user_keys] 
        (userid, algorithm, creation_date, key_status, public_key, key_usage)
        VALUES 
        (
            @user_id,
            'RSA-2048',
            @creation_date,
            'Active',
            CONVERT(VARBINARY(255), 'public_key_' + CAST(@i AS VARCHAR)),
            'Authentication'
        );
        
        SET @i = @i + 1;
    END;
    
    SELECT 'Proceso completado. Se insertaron ' + CAST(COUNT(*) AS VARCHAR) + ' claves de usuario.' AS resultado
    FROM [dbo].[vpv_user_keys];
END;
GO

-- 12. Procedimiento para insertar datos de auditoría de entidades
CREATE OR ALTER PROCEDURE [dbo].[insert_vpv_entity_audit_logs]
AS
BEGIN
    DECLARE @i INT = 0;
    DECLARE @num_logs INT = 1000;
    DECLARE @entity_id INT;
    DECLARE @user_id INT;
    DECLARE @action_date DATETIME;
    
    -- Verificar que hay entidades y usuarios disponibles
    IF NOT EXISTS (SELECT 1 FROM [dbo].[vpv_entities]) OR NOT EXISTS (SELECT 1 FROM [dbo].[vpv_users])
    BEGIN
        RAISERROR('No hay entidades o usuarios disponibles. Ejecute insert_vpv_entities e insert_vpv_users primero.', 16, 1);
        RETURN;
    END
    
    -- Insertar logs de auditoría
    WHILE @i < @num_logs 
    BEGIN
        BEGIN TRY
            -- Seleccionar entidad y usuario aleatorios existentes
            SELECT TOP 1 @entity_id = entity_id FROM vpv_entities ORDER BY NEWID();
            SELECT TOP 1 @user_id = userid FROM vpv_users ORDER BY NEWID();
            
            -- Fecha de acción (últimos 6 meses)
            SET @action_date = DATEADD(DAY, -FLOOR(RAND() * 180), GETDATE());
            
            -- Insertar log con acciones específicas para sistema de votación
            INSERT INTO [dbo].[vpv_entity_audit_log] 
            (action_type, action_date, performed_by_user, ip_address, 
             transaction_hash, version, entity_id)
            VALUES 
            (
                CASE FLOOR(RAND() * 8)
                    WHEN 0 THEN 'Creación de Propuesta'
                    WHEN 1 THEN 'Modificación de Propuesta'
                    WHEN 2 THEN 'Votación Registrada'
                    WHEN 3 THEN 'Cambio de Estado'
                    WHEN 4 THEN 'Acceso a Resultados'
                    WHEN 5 THEN 'Registro de Representante'
                    WHEN 6 THEN 'Actualización de Datos'
                    ELSE 'Revisión de Auditoría'
                END,
                @action_date,
                @user_id,
                CONVERT(VARBINARY(255), '192.168.' + 
                    CAST(FLOOR(RAND() * 255) AS VARCHAR) + '.' + 
                    CAST(FLOOR(RAND() * 255) AS VARCHAR)),
                CONVERT(VARBINARY(255), 'tx_hash_' + CAST(@i AS VARCHAR)),
                1,
                @entity_id
            );
            
            SET @i = @i + 1;
        END TRY
        BEGIN CATCH
            PRINT 'Error al insertar log de auditoría: ' + ERROR_MESSAGE();
        END CATCH
    END;
    
    SELECT 'Proceso completado. Se insertaron ' + CAST(COUNT(*) AS VARCHAR) + ' logs de auditoría.' AS resultado
    FROM [dbo].[vpv_entity_audit_log];
END;
GO

-- Ejecutar todos los procedimientos en orden
EXEC [dbo].[insert_vpv_users];
EXEC [dbo].[insert_vpv_modules];Add commentMore actions
EXEC [dbo].[insert_vpv_roles];
EXEC [dbo].[insert_vpv_permissions];
EXEC [dbo].[assign_vpv_permissions_to_roles];
EXEC [dbo].[assign_vpv_roles_to_users];
EXEC [dbo].[insert_vpv_entity_reference_data];
EXEC [dbo].[insert_vpv_entities];
EXEC [dbo].[insert_vpv_entity_representatives];
EXEC [dbo].[insert_vpv_user_keys];
EXEC [dbo].[insert_vpv_entity_audit_logs];
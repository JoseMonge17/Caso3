INSERT INTO vpv_proposal (
  name, enabled, current_version, description, submission_date,
  version, origin_typeid, allows_comments, userid, statusid, proposal_typeid, entityid
) VALUES (
  'Eliminar impuestos a la canasta básica',
  1,
  1,
  'Propuesta ciudadana para eliminar impuestos a productos esenciales',
  GETDATE(),
  1,
  1,  -- origin_typeid
  1,
  1,  -- userid (ajustar si es otro)
  1,  -- statusid
  1,  -- proposal_typeid
  1   -- entityid
),
(
    'Reducir IVA en servicios esenciales',
    1,
    1,
    'Propuesta ciudadana para reducir el IVA aplicado a servicios de agua y electricidad',
    '2025-06-17T10:00:00.000',
    1,
    1,
	1,
    2,
    1,
    1,
    1
);

INSERT INTO vote_sessions (
  startDate, endDate, public_key,
  sessionStatusid, voteTypeid, visibilityid
) VALUES (
  GETDATE(),
  DATEADD(DAY, 7, GETDATE()),
  CONVERT(VARBINARY(255), 'clave_publica_ficticia'),
  2, -- estado 'En Progreso'
  2,
  1
);

INSERT INTO [dbo].[cf_proposal_votes] ([date]
           ,[result]
           ,[sessionid]
           ,[proposalid])
     VALUES
           (GETDATE()
           ,0
           ,8
           ,11)
GO

-- Asignación de valor demográfico al usuario
INSERT INTO vpv_user_demographics (enabled, value, demographicid, userid)
VALUES (1, 'Masculino', 1, 2),(1, 'San José', 11, 2);

-- Regla: solo pueden votar quienes tengan 'Masculino'
INSERT INTO vote_voting_criteria (value, weight, enabled, sessionid, criteriaid) 
VALUES ('Masculino', 1.00, 1, 8, 1), ('San José', 1.00, 1, 8, 11);

INSERT INTO vote_questions (
  description, required, max_answers, createDate, updateDate, question_typeid, sessionid
)
VALUES (
  '¿Está usted de acuerdo con eliminar los impuestos a los productos de la canasta básica?',
  1,            -- requerida
  1,            -- una sola respuesta
  GETDATE(),    -- fecha de creación
  NULL,         -- sin actualización
  1,            -- tipo "Sí / No"
  8            -- sesión 1
);

INSERT INTO vote_options (
  description, value, url, [order], checksum, createDate, updateDate, questionid
)
VALUES 
-- Opción Sí
('Sí', '1', '', 1, CONVERT(VARBINARY(255), '1'), GETDATE(), NULL, 15),
-- Opción No
('No', '0', '', 2, CONVERT(VARBINARY(255), '0'), GETDATE(), NULL, 15);

INSERT INTO vpv_mfa_devices (userid, device_name, registration_date, last_used_date, serial_hash, authentication_factor, is_primary)
VALUES (2, 'iPhone de Juan', GETDATE(), NULL, 0xDEADBEEF01, 'OTP',1);

INSERT INTO vpv_auth_methods (userid, device_id, method_type, identifier_hash, registration_date, last_used_date, is_primary)
VALUES (2, 1, 'email', 'juan@example.com', GETDATE(), NULL, 1);

-- El código real es '123456' y fue hasheado con SHA-256
INSERT INTO vpv_mfa_codes (method_id, device_id, code_hash, generation_date, expiration_date, remaining_attempts, code_status, request_context)
VALUES (1, 1, HASHBYTES('SHA2_256', '123456'), GETDATE(), DATEADD(WEEK, 1, GETDATE()), 3, 'PENDING', 'login desde web');

INSERT INTO vpv_mediatypes (name, formattype, enable)
VALUES
('Imagen', 'image/jpeg', 1),
('Video', 'video/mp4', 1),
('Audio', 'audio/wav', 1);

INSERT INTO vpv_biometric_types (name, description, enable, legal_requirement)
VALUES
('Reconocimiento facial', 'Verificación mediante imagen facial', 1, 'Requiere consentimiento explícito'),
('Huella dactilar', 'Identificación por huella digital', 1, 'Permitido por ley local'),
('Reconocimiento de voz', 'Identificación por patrón de voz', 1, 'Requiere doble validación legal');

INSERT INTO vpv_log_type (name, description) VALUES
('Operación exitosa', 'Se registró correctamente una acción esperada por el sistema.'),
('Error de base de datos', 'Fallo relacionado con una consulta, conexión o transacción en la base de datos.'),
('Error de desencriptación', 'Fallo al intentar desencriptar un voto o dato sensible.'),
('Validación fallida', 'Error durante una validación de integridad o elegibilidad.'),
('Debug', 'Información técnica útil para desarrolladores en modo de depuración.');

INSERT INTO vpv_log_source (name, system_component) VALUES
('Consulta últimas votaciones', 'VoteService'),
('Realizar una votacion', 'VoteService'),
('Configurar una votacion', 'VoteService')

INSERT INTO vote_rules (name, dataType) VALUES
('Rechazo falta de votos', 'INT'),
('Restricción IP', 'BIT'),
('Restricción Horario', 'BIT');

INSERT INTO vpv_countries (name, codeISO, register_enable) VALUES
('Costa Rica', 'CRC', 1),
('United States', 'USA', 1),
('Canada', 'CAN', 1),
('Mexico', 'MEX', 1),
('Germany', 'DEU', 1);

INSERT INTO vpv_states (name, countryid) VALUES
('San José', 1),
('California', 2),
('Ontario', 3),
('Jalisco', 4),
('Bavaria', 5);

INSERT INTO vpv_cities (name, stateid) VALUES
('San Pedro', 1),
('Los Angeles', 2),
('Toronto', 3),
('Guadalajara', 4),
('Munich', 5);

INSERT INTO vpv_address (line1, line2, zipcode, location, cityid) VALUES
('Av. Central 123', '2nd Floor', '10101', 'POINT(-84.09072 9.92807)', 2);

INSERT INTO vpv_addressasignations (entitytype, addressid, userid) VALUES
('Customer', 1, 2);

INSERT INTO vpv_impact_level ([name]) VALUES
('Bajo'),
('Moderado'),
('Alto'),
('Crítico'),
('Desconocido');

INSERT INTO vpv_zone_type ([name]) VALUES
('Ciudadanos'),
('Empleados'),
('Recursos Naturales'),
('Instituciones Públicas'),
('Infraestructura'),
('Zonas Educativas'),
('Población Vulnerable'),
('Países'),
('Regiones Fronterizas'),
('Empresas Privadas');

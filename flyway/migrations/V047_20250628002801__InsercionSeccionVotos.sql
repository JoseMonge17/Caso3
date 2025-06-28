INSERT INTO vote_result_visibilities (description)
VALUES
  ('Después del cierre'),         -- Se cierra el plazo de votación (AC)
  ('Después de que todos voten'); -- Todos los elegibles ya votaron (AV)

INSERT INTO [dbo].[vote_question_types] ( [description])
VALUES 
('Selección simple'),
('Selección múltiple'),
('Escala Likert'),
('Texto abierto'),
('Ordenación');

INSERT INTO vote_rules (name, dataType) VALUES
('Aceptación por mayoría', 'BIT'),
('Aceptación por porcentaje', 'DECIMAL'),
('Rechazo por mayoria', 'BIT');

INSERT INTO vote_types (name, description, singleWeight)
VALUES
  ('Publico', 'Se puede ver quien voto en una sesión particular', 0),
  ('Privado', 'No se puede ver quien voto en una sesión particular', 0);

INSERT INTO [dbo].[vote_sessions_status] ([name])
VALUES 
('Programada'),
('En Progreso'),
('Concluida'),
('Cancelada'),
('Suspendida');
 

 -- Insertar sesiones de votación
INSERT INTO [dbo].[vote_sessions] (
    [startDate], [endDate], [public_key], 
    [sessionStatusid], [voteTypeid], [visibilityid]
)
VALUES 
-- Sesión 1: Votación pública ordinaria
('2023-01-10 09:00:00', '2023-01-15 18:00:00', 0x1A2B3C4D, 3, 1, 1),

-- Sesión 2: Votación calificada privada
('2023-02-05 10:00:00', '2023-02-07 16:00:00', 0x2B3C4D5E, 3, 2, 2),

-- Sesión 3: Votación ponderada para comité
('2023-03-12 08:30:00', '2023-03-17 17:30:00', 0x3C4D5E6F, 3, 1, 1),

-- Sesión 4: Votación especial rápida
('2023-04-03 14:00:00', '2023-04-05 20:00:00', 0x4D5E6F7A, 3, 1, 1),

-- Sesión 5: Votación unánime técnica
('2023-05-08 09:00:00', '2023-05-13 18:00:00', 0x5E6F7A8B, 3, 2, 2),

-- Sesión 6: Votación pública de emergencia
('2023-06-20 08:00:00', '2023-06-22 22:00:00', 0x6F7A8B9C, 3, 1, 2),

-- Sesión 7: Votación calificada extendida
('2023-07-10 09:00:00', '2023-07-15 18:00:00', 0x7A8B9CAD, 3, 2, 2);


-- Inserción de votos para las 10 propuestas en diferentes sesiones
INSERT INTO [dbo].[cf_proposal_votes] ([date], [result], [sessionid], [proposalid])
VALUES 
-- Propuesta 1: Expansión Boulevard Cartago (proposalid=1)
('2023-09-20 10:15:00', 1, 1, 1),  -- Sesión 1

-- Propuesta 2: Planta Solar Guanacaste (proposalid=2)
('2024-01-15 09:45:00', 1, 3, 2),  -- Sesión 3

-- Propuesta 3: AgriTech CR (proposalid=3)
('2024-04-10 14:20:00', 1, 2, 3),  -- Sesión 2

-- Propuesta 4: Bicicletas Públicas (proposalid=4)
('2024-02-25 09:30:00', 1, 4, 4),  -- Sesión 4

-- Propuesta 5: EcoBarrios (proposalid=5)
('2023-11-15 13:25:00', 1, 6, 5),   -- Sesión 6

-- Propuesta 6: Mercado Heredia (proposalid=6)
('2024-03-18 11:10:00', 1, 7, 6),   -- Sesión 7

-- Propuesta 7: Plataforma Mi Voz (proposalid=7)
('2023-12-10 10:20:00', 1, 5, 7);    -- Sesión 5

-- Preguntas para las sesiones (2-3 preguntas por sesión)
INSERT INTO [dbo].[vote_questions] (
    [description], [required], [max_answers], 
    [createDate], [updateDate], [question_typeid], [sessionid]
)
VALUES 
-- Sesión 1
('¿Aprueba la expansión del Boulevard Cartago?', 1, 1, '2023-01-05', NULL, 1, 1),
('Seleccione las mejoras prioritarias para el proyecto', 0, 3, '2023-01-05', NULL, 2, 1),

-- Sesión 2
('¿Considera útil la plataforma AgriTech para pequeños agricultores?', 1, 1, '2024-04-01', NULL, 1, 3),
('Seleccione las funcionalidades más importantes', 0, 2, '2024-04-01', NULL, 2, 3),

-- Sesión 3
('¿Apoya la construcción de la Planta Solar Guanacaste?', 1, 1, '2024-01-05', NULL, 1, 2),
('Valore el impacto ambiental del proyecto (1-5)', 1, 1, '2024-01-05', NULL, 3, 2),

-- Sesión 4
('¿Aprueba el sistema de bicicletas públicas en San José?', 1, 1, '2024-02-15', NULL, 1, 4),
('Indique las zonas prioritarias para estaciones', 0, 5, '2024-02-15', NULL, 2, 4),

-- Sesión 5
('¿Considera necesaria la plataforma "Mi Voz" para participación ciudadana?', 1, 1, '2023-12-01', NULL, 1, 7),
('Ordene por prioridad las funcionalidades deseadas', 0, 5, '2023-12-01', NULL, 5, 7),

-- Sesión 6
('¿Apoya el programa EcoBarrios de reciclaje comunitario?', 1, 1, '2023-11-03', NULL, 1, 5),
('Valore la importancia de los componentes del programa (1-5)', 0, 1, '2023-11-03', NULL, 3, 5),


-- Sesión 7
('¿Aprueba la remodelación del Mercado Central de Heredia?', 1, 1, '2024-03-08', NULL, 1, 6),
('Seleccione las mejoras más urgentes', 0, 2, '2024-03-08', NULL, 2, 6);

ALTER TABLE vote_options ALTER COLUMN url VARCHAR(250) null
-- Opciones para todas las preguntas (completas)
INSERT INTO [dbo].[vote_options] (
    [description], [value], [url], [order], 
    [checksum], [createDate], [updateDate], [questionid]
)
VALUES 
-- Pregunta 1 (Sesión 1 - Aprobación Boulevard Cartago)
('Sí', 'approve', NULL, 1, 0x1A2B3C4D, '2023-01-05', NULL, 1),
('No', 'reject', NULL, 2, 0x2B3C4D5E, '2023-01-05', NULL, 1),
('Abstención', 'abstention', NULL, 3, 0x3C4D5E6F, '2023-01-05', NULL, 1),

-- Pregunta 2 (Sesión 1 - Mejoras prioritarias Boulevard)
('Ampliación de carriles', 'lanes', 'http://docs.example.com/boulevard/lanes.pdf', 1, 0x4D5E6F7A, '2023-01-05', NULL, 2),
('Nuevas aceras peatonales', 'sidewalks', 'http://docs.example.com/boulevard/sidewalks.pdf', 2, 0x5E6F7A8B, '2023-01-05', NULL, 2),
('Ciclovía integrada', 'bike_lane', 'http://docs.example.com/boulevard/bike_lane.pdf', 3, 0x6F7A8B9C, '2023-01-05', NULL, 2),
('Mejor iluminación nocturna', 'lighting', 'http://docs.example.com/boulevard/lighting.pdf', 4, 0x7A8B9CAD, '2023-01-05', NULL, 2),
('Áreas verdes y jardines', 'green_areas', 'http://docs.example.com/boulevard/green_areas.pdf', 5, 0x8B9CADBE, '2023-01-05', NULL, 2),
('Señalización inteligente', 'smart_signs', 'http://docs.example.com/boulevard/smart_signs.pdf', 6, 0x9CADBECF, '2023-01-05', NULL, 2),

-- Pregunta 3 (Sesión 3 - Aprobación Planta Solar)
('Sí, totalmente de acuerdo', 'fully_approve', NULL, 1, 0xADBECFD0, '2024-01-05', NULL, 5),
('Sí, con condiciones', 'approve_with_conditions', NULL, 2, 0xBECFD0E1, '2024-01-05', NULL, 5),
('No, me opongo al proyecto', 'reject', NULL, 3, 0xCFD0E1F2, '2024-01-05', NULL, 5),
('No tengo suficiente información', 'not_enough_info', NULL, 4, 0xD0E1F203, '2024-01-05', NULL, 5),

-- Pregunta 4 (Sesión 3 - Impacto ambiental Planta Solar)
('1 - Impacto mínimo', '1_minimal', NULL, 1, 0xE1F20314, '2024-01-05', NULL, 6),
('2', '2_low', NULL, 2, 0xF2031425, '2024-01-05', NULL, 6),
('3 - Impacto moderado', '3_moderate', NULL, 3, 0x03142536, '2024-01-05', NULL, 6),
('4', '4_high', NULL, 4, 0x14253647, '2024-01-05', NULL, 6),
('5 - Impacto muy alto', '5_very_high', NULL, 5, 0x25364758, '2024-01-05', NULL, 6),

-- Pregunta 5 (Sesión 2 - Utilidad Plataforma AgriTech)
('Sí, sería muy útil', 'very_useful', NULL, 1, 0x36475869, '2024-04-01', NULL, 3),
('Sí, pero con ajustes', 'useful_with_changes', NULL, 2, 0x4758697A, '2024-04-01', NULL, 3),
('No, no la usaría', 'not_useful', NULL, 3, 0x58697A8B, '2024-04-01', NULL, 3),
('No estoy seguro', 'unsure', NULL, 4, 0x697A8B9C, '2024-04-01', NULL, 3),

-- Pregunta 6 (Sesión 2 - Funcionalidades AgriTech)
('Monitoreo de cultivos en tiempo real', 'real_time_monitoring', 'http://docs.example.com/agritech/monitoring.pdf', 1, 0x7A8B9CAD, '2024-04-01', NULL, 4),
('Recomendaciones de riego automatizado', 'irrigation_recommendations', 'http://docs.example.com/agritech/irrigation.pdf', 2, 0x8B9CADBE, '2024-04-01', NULL, 4),
('Alertas tempranas de plagas', 'pest_alerts', 'http://docs.example.com/agritech/pests.pdf', 3, 0x9CADBECF, '2024-04-01', NULL, 4),
('Mercado en línea para productos', 'online_marketplace', 'http://docs.example.com/agritech/marketplace.pdf', 4, 0xADBECFD0, '2024-04-01', NULL, 4),
('Asesoría agronómica virtual', 'virtual_consultation', 'http://docs.example.com/agritech/consultation.pdf', 5, 0xBECFD0E1, '2024-04-01', NULL, 4),
('Historial de clima y predicciones', 'weather_history', 'http://docs.example.com/agritech/weather.pdf', 6, 0xCFD0E1F2, '2024-04-01', NULL, 4),

-- Pregunta 7 (Sesión 4 - Aprobación Bicicletas Públicas)
('Sí, totalmente necesario', 'strongly_approve', NULL, 1, 0xD0E1F203, '2024-02-15', NULL, 7),
('Sí, pero con ciertas condiciones', 'approve_with_conditions', NULL, 2, 0xE1F20314, '2024-02-15', NULL, 7),
('No, no es prioritario', 'not_priority', NULL, 3, 0xF2031425, '2024-02-15', NULL, 7),
('No, me opongo al proyecto', 'reject', NULL, 4, 0x03142536, '2024-02-15', NULL, 7),

-- Pregunta 8 (Sesión 4 - Zonas para estaciones de bicicletas)
('Centro histórico y comercial', 'downtown', 'http://maps.example.com/zones/downtown.pdf', 1, 0x14253647, '2024-02-15', NULL, 8),
('Zona universitaria (UCR, UNA, TEC)', 'university_area', 'http://maps.example.com/zones/universities.pdf', 2, 0x25364758, '2024-02-15', NULL, 8),
('Parques metropolitanos (La Sabana, Morazán)', 'parks', 'http://maps.example.com/zones/parks.pdf', 3, 0x36475869, '2024-02-15', NULL, 8),
('Estaciones de tren (Atlantic, Pacific)', 'train_stations', 'http://maps.example.com/zones/train_stations.pdf', 4, 0x4758697A, '2024-02-15', NULL, 8),
('Zonas residenciales (Rohrmoser, Escalante)', 'residential', 'http://maps.example.com/zones/residential.pdf', 5, 0x58697A8B, '2024-02-15', NULL, 8),
('Centros comerciales principales', 'shopping_malls', 'http://maps.example.com/zones/malls.pdf', 6, 0x697A8B9C, '2024-02-15', NULL, 8),

-- Pregunta 9 (Sesión 6 - Aprobación EcoBarrios)
('Sí, implementar inmediatamente', 'approve_immediately', NULL, 1, 0x7A8B9CAD, '2023-11-03', NULL, 11),
('Sí, pero con ajustes al plan', 'approve_with_changes', NULL, 2, 0x8B9CADBE, '2023-11-03', NULL, 11),
('No, el plan necesita rediseño', 'needs_redesign', NULL, 3, 0x9CADBECF, '2023-11-03', NULL, 11),
('No, me opongo al programa', 'reject', NULL, 4, 0xADBECFD0, '2023-11-03', NULL, 11),

-- Pregunta 10 (Sesión 6 - Importancia componentes EcoBarrios)
('1 - Sin importancia', '1_unimportant', NULL, 1, 0xBECFD0E1, '2023-11-03', NULL, 12),
('2', '2_low', NULL, 2, 0xCFD0E1F2, '2023-11-03', NULL, 12),
('3 - Importancia media', '3_medium', NULL, 3, 0xD0E1F203, '2023-11-03', NULL, 12),
('4', '4_high', NULL, 4, 0xE1F20314, '2023-11-03', NULL, 12),
('5 - Críticamente importante', '5_critical', NULL, 5, 0xF2031425, '2023-11-03', NULL, 12),

-- Pregunta 11 (Sesión 7 - Aprobación Remodelación Mercado)
('Sí, urgente remodelación', 'approve_urgent', NULL, 1, 0x03142536, '2024-03-08', NULL, 13),
('Sí, pero por fases', 'approve_phased', NULL, 2, 0x14253647, '2024-03-08', NULL, 13),
('No, solo mantenimiento', 'maintenance_only', NULL, 3, 0x25364758, '2024-03-08', NULL, 13),
('No, dejar como está', 'reject', NULL, 4, 0x36475869, '2024-03-08', NULL, 13),

-- Pregunta 12 (Sesión 7 - Mejoras urgentes Mercado)
('Infraestructura sanitaria', 'sanitary', 'http://docs.example.com/market/sanitary.pdf', 1, 0x4758697A, '2024-03-08', NULL, 14),
('Sistema eléctrico y seguridad', 'electrical', 'http://docs.example.com/market/electrical.pdf', 2, 0x58697A8B, '2024-03-08', NULL, 14),
('Accesibilidad para discapacitados', 'accessibility', 'http://docs.example.com/market/accessibility.pdf', 3, 0x697A8B9C, '2024-03-08', NULL, 14),
('Espacios para nuevos vendedores', 'new_vendors', 'http://docs.example.com/market/vendors.pdf', 4, 0x7A8B9CAD, '2024-03-08', NULL, 14),
('Áreas de carga y descarga', 'loading_zones', 'http://docs.example.com/market/loading.pdf', 5, 0x8B9CADBE, '2024-03-08', NULL, 14),

-- Pregunta 13 (Sesión 5 - Necesidad Plataforma "Mi Voz")
('Sí, muy necesaria', 'strongly_agree', NULL, 1, 0x9CADBECF, '2023-12-01', NULL, 9),
('Sí, pero con ajustes', 'agree_with_changes', NULL, 2, 0xADBECFD0, '2023-12-01', NULL, 9),
('Neutral', 'neutral', NULL, 3, 0xBECFD0E1, '2023-12-01', NULL, 9),
('No, no es prioridad', 'not_priority', NULL, 4, 0xCFD0E1F2, '2023-12-01', NULL, 9),
('No, me opongo', 'reject', NULL, 5, 0xD0E1F203, '2023-12-01', NULL, 9),

-- Pregunta 14 (Sesión 5 - Prioridad funcionalidades "Mi Voz")
('Sistema de propuestas ciudadanas', 'proposals', 'http://docs.example.com/mivoz/proposals.pdf', 1, 0xE1F20314, '2023-12-01', NULL, 10),
('Consultas públicas', 'polls', 'http://docs.example.com/mivoz/polls.pdf', 2, 0xF2031425, '2023-12-01', NULL, 10),
('Seguimiento de proyectos', 'project_tracking', 'http://docs.example.com/mivoz/tracking.pdf', 3, 0x03142536, '2023-12-01', NULL, 10),
('Reporte de problemas', 'issue_reporting', 'http://docs.example.com/mivoz/issues.pdf', 4, 0x14253647, '2023-12-01', NULL, 10),
('Presupuesto participativo', 'participatory_budget', 'http://docs.example.com/mivoz/budget.pdf', 5, 0x25364758, '2023-12-01', NULL, 10),
('Foros de discusión', 'forums', 'http://docs.example.com/mivoz/forums.pdf', 6, 0x36475869, '2023-12-01', NULL, 10);

INSERT INTO [dbo].[vpv_demographic_types] ([demographic_typeid], [name])
VALUES 
(1, 'Género'),
(2, 'Grupo Edad'),
(3, 'Región'),
(4, 'Nivel Educativo'),
(5, 'Ocupación'),
(6, 'Ingresos'),
(7, 'Discapacidad');


INSERT INTO [dbo].[vpv_demographic_data] ([code], [description], [demographic_typeid])
VALUES 
-- Género (tipo 1)
('GEN01', 'Masculino', 1),
('GEN02', 'Femenino', 1),
('GEN03', 'No binario', 1),
('GEN04', 'Prefiero no decir', 1),

-- Grupos de edad (tipo 2)
('AGE01', '18-25 años', 2),
('AGE02', '26-35 años', 2),
('AGE03', '36-45 años', 2),
('AGE04', '46-55 años', 2),
('AGE05', '56-65 años', 2),
('AGE06', '66+ años', 2),

-- Regiones (tipo 3)
('REG01', 'San José Central', 3),
('REG02', 'Heredia', 3),
('REG03', 'Alajuela', 3),
('REG04', 'Cartago', 3),
('REG05', 'Limón', 3),
('REG06', 'Puntarenas', 3),
('REG07', 'Guanacaste', 3),
('REG08', 'Zona Sur', 3),

-- Nivel educativo (tipo 4)
('EDU01', 'Primaria', 4),
('EDU02', 'Secundaria', 4),
('EDU03', 'Técnico', 4),
('EDU04', 'Universitario', 4),
('EDU05', 'Posgrado', 4),

-- Ocupación (tipo 5)
('OCC01', 'Estudiante', 5),
('OCC02', 'Empleado sector público', 5),
('OCC03', 'Empleado sector privado', 5),
('OCC04', 'Empresario', 5),
('OCC05', 'Independiente', 5),
('OCC06', 'Jubilado', 5),
('OCC07', 'Desempleado', 5),

-- Nivel de ingresos (tipo 6)
('INC01', 'Menos de ¢300,000', 6),
('INC02', '¢300,000 - ¢600,000', 6),
('INC03', '¢600,001 - ¢900,000', 6),
('INC04', '¢900,001 - ¢1,200,000', 6),
('INC05', 'Más de ¢1,200,000', 6),

-- Discapacidad (tipo 7)
('DIS01', 'Sin discapacidad', 7),
('DIS02', 'Discapacidad física', 7),
('DIS03', 'Discapacidad visual', 7),
('DIS04', 'Discapacidad auditiva', 7),
('DIS05', 'Otra discapacidad', 7);

INSERT INTO [dbo].[vpv_user_demographics] ([enabled], [value], [demographicid], [userid])
VALUES 
-- Usuario 101 (ejecutivo de proyecto)
(1, 'Masculino', 1, 101),
(1, '36-45 años', 3, 101),
(1, 'San José Central', 11, 101),
(1, 'Universitario', 16, 101),
(1, 'Empleado sector privado', 19, 101),
(1, '¢900,001 - ¢1,200,000', 24, 101),
(1, 'Sin discapacidad', 26, 101),

-- Usuario 201 (representante organización)
(1, 'Femenino', 2, 201),
(1, '26-35 años', 2, 201),
(1, 'Guanacaste', 17, 201),
(1, 'Posgrado', 20, 201),
(1, 'Empresario', 22, 201),
(1, 'Más de ¢1,200,000', 25, 201),
(1, 'Sin discapacidad', 26, 201),

-- Usuario 301 (agricultor)
(1, 'Masculino', 1, 301),
(1, '46-55 años', 4, 301),
(1, 'Limón', 15, 301),
(1, 'Secundaria', 14, 301),
(1, 'Independiente', 23, 301),
(1, '¢300,000 - ¢600,000', 22, 301),
(1, 'Discapacidad física', 27, 301),

-- Continuar con otros usuarios...
-- Usuario 102 (planificador urbano)
(1, 'Femenino', 2, 102),
(1, '26-35 años', 2, 102),
(1, 'Heredia', 12, 102),
(1, 'Universitario', 16, 102),
(1, 'Empleado sector público', 18, 102),
(1, '¢600,001 - ¢900,000', 23, 102),
(1, 'Sin discapacidad', 26, 102),

-- Usuario 45 (ciudadano activo)
(1, 'No binario', 3, 45),
(1, '18-25 años', 1, 45),
(1, 'Alajuela', 13, 45),
(1, 'Técnico', 15, 45),
(1, 'Estudiante', 17, 45),
(1, 'Menos de ¢300,000', 21, 45),
(1, 'Discapacidad visual', 28, 45),

-- Usuario 104 (funcionario público)
(1, 'Masculino', 1, 104),
(1, '56-65 años', 5, 104),
(1, 'Cartago', 14, 104),
(1, 'Posgrado', 20, 104),
(1, 'Empleado sector público', 18, 104),
(1, 'Más de ¢1,200,000', 25, 104),
(1, 'Sin discapacidad', 26, 104),

-- Usuario 103 (arquitecto)
(1, 'Femenino', 2, 103),
(1, '36-45 años', 3, 103),
(1, 'Puntarenas', 16, 103),
(1, 'Universitario', 16, 103),
(1, 'Independiente', 23, 103),
(1, '¢900,001 - ¢1,200,000', 24, 103),
(1, 'Sin discapacidad', 26, 103),

-- Usuario 202 (gestor cultural)
(1, 'Femenino', 2, 202),
(1, '26-35 años', 2, 202),
(1, 'Guanacaste', 17, 202),
(1, 'Universitario', 16, 202),
(1, 'Empleado sector privado', 19, 202),
(1, '¢600,001 - ¢900,000', 23, 202),
(1, 'Sin discapacidad', 26, 202),

-- Usuario 46 (docente)
(1, 'Femenino', 2, 46),
(1, '46-55 años', 4, 46),
(1, 'Zona Sur', 18, 46),
(1, 'Posgrado', 20, 46),
(1, 'Empleado sector público', 18, 46),
(1, '¢600,001 - ¢900,000', 23, 46),
(1, 'Discapacidad auditiva', 29, 46),

-- Usuario 105 (ingeniero)
(1, 'Masculino', 1, 105),
(1, '36-45 años', 3, 105),
(1, 'San José Central', 11, 105),
(1, 'Universitario', 16, 105),
(1, 'Empleado sector privado', 19, 105),
(1, 'Más de ¢1,200,000', 25, 105),
(1, 'Sin discapacidad', 26, 105);



INSERT INTO [dbo].[vote_criterias] ([type], [datatype], [demographicid])
SELECT 
    CASE 
        WHEN dd.demographic_typeid = 1 THEN 'Ponderación por Género'
        WHEN dd.demographic_typeid = 2 THEN 'Ponderación por Edad'
        WHEN dd.demographic_typeid = 3 THEN 'Ponderación por Región'
        WHEN dd.demographic_typeid = 4 THEN 'Ponderación por Educación'
        WHEN dd.demographic_typeid = 5 THEN 'Ponderación por Ocupación'
        WHEN dd.demographic_typeid = 6 THEN 'Ponderación por Ingresos'
        WHEN dd.demographic_typeid = 7 THEN 'Ponderación por Discapacidad'
    END AS [type],
    'decimal(3,2)' AS [datatype],
    dd.demographicid
FROM [dbo].[vpv_demographic_data] dd
WHERE dd.code IN (
    'GEN01', 'GEN02', 'GEN03', 'GEN04',
    'AGE01', 'AGE02', 'AGE03', 'AGE04', 'AGE05', 'AGE06',
    'REG01', 'REG02', 'REG03', 'REG04', 'REG05', 'REG06', 'REG07', 'REG08',
    'EDU01', 'EDU02', 'EDU03', 'EDU04', 'EDU05',
    'OCC01', 'OCC02', 'OCC03', 'OCC04', 'OCC05', 'OCC06', 'OCC07',
    'INC01', 'INC02', 'INC03', 'INC04', 'INC05',
    'DIS01', 'DIS02', 'DIS03', 'DIS04', 'DIS05'
);

-- Sesión 1: Todos los votos valen igual
INSERT INTO [dbo].[vote_voting_criteria] ([value], [weight], [enabled], [sessionid], [criteriaid])
SELECT 
    dd.description,
    1.00 AS weight,
    1 AS enabled,
    1 AS sessionid,
    c.criteriaid
FROM [dbo].[vote_criterias] c
JOIN [dbo].[vpv_demographic_data] dd ON c.demographicid = dd.demographicid;

-- Sesión 2: Votación calificada privada
INSERT INTO [dbo].[vote_voting_criteria] ([value], [weight], [enabled], [sessionid], [criteriaid])
SELECT 
    dd.description,
    CASE 
        WHEN dd.code = 'EDU04' THEN 1.5
        WHEN dd.code = 'EDU05' THEN 1.7
        WHEN dd.code IN ('DIS02', 'DIS03', 'DIS04', 'DIS05') THEN 1.4
        WHEN dd.code IN ('OCC01', 'OCC07') THEN 0.7
        WHEN dd.code = 'OCC04' THEN 1.3
        ELSE 1.0
    END AS weight,
    1 AS enabled,
    2 AS sessionid,
    c.criteriaid
FROM [dbo].[vote_criterias] c
JOIN [dbo].[vpv_demographic_data] dd ON c.demographicid = dd.demographicid;

-- Sesión 3: Votación ponderada para comité (énfasis en región y edad)
INSERT INTO [dbo].[vote_voting_criteria] ([value], [weight], [enabled], [sessionid], [criteriaid])
SELECT 
    dd.description,
    CASE 
        WHEN dd.code = 'REG07' THEN 1.8  -- Guanacaste
        WHEN dd.code IN ('AGE03', 'AGE04', 'AGE05') THEN 1.5
        WHEN dd.code = 'AGE06' THEN 1.3   -- Mayores de 65
        WHEN dd.code = 'AGE01' THEN 0.6   -- Jóvenes 18-25
        WHEN dd.code = 'OCC06' THEN 1.2   -- Jubilados
        ELSE 1.0
    END AS weight,
    1 AS enabled,
    3 AS sessionid,
    c.criteriaid
FROM [dbo].[vote_criterias] c
JOIN [dbo].[vpv_demographic_data] dd ON c.demographicid = dd.demographicid;

-- Sesión 4: Votación especial rápida (énfasis en género y ocupación)
INSERT INTO [dbo].[vote_voting_criteria] ([value], [weight], [enabled], [sessionid], [criteriaid])
SELECT 
    dd.description,
    CASE 
        WHEN dd.code = 'GEN02' THEN 1.4  -- Mujeres
        WHEN dd.code = 'GEN03' THEN 1.2  -- No binario
        WHEN dd.code IN ('OCC02', 'OCC03', 'OCC04') THEN 1.3
        WHEN dd.code = 'OCC06' THEN 0.8   -- Jubilados
        WHEN dd.code = 'AGE01' THEN 0.9   -- Jóvenes
        ELSE 1.0
    END AS weight,
    1 AS enabled,
    4 AS sessionid,
    c.criteriaid
FROM [dbo].[vote_criterias] c
JOIN [dbo].[vpv_demographic_data] dd ON c.demographicid = dd.demographicid;

-- Sesión 5: Votación unánime técnica (énfasis en educación)
INSERT INTO [dbo].[vote_voting_criteria] ([value], [weight], [enabled], [sessionid], [criteriaid])
SELECT 
    dd.description,
    CASE 
        WHEN dd.code = 'EDU05' THEN 2.0  -- Posgrado
        WHEN dd.code = 'EDU04' THEN 1.6  -- Universitario
        WHEN dd.code IN ('OCC02', 'OCC04') THEN 1.5  -- Funcionarios públicos y empresarios
        WHEN dd.code IN ('EDU01', 'EDU02') THEN 0.5  -- Educación básica
        WHEN dd.code = 'AGE01' THEN 0.7  -- Jóvenes
        ELSE 1.0
    END AS weight,
    1 AS enabled,
    5 AS sessionid,
    c.criteriaid
FROM [dbo].[vote_criterias] c
JOIN [dbo].[vpv_demographic_data] dd ON c.demographicid = dd.demographicid;

-- Sesión 6: Votación pública de emergencia (énfasis en región)
INSERT INTO [dbo].[vote_voting_criteria] ([value], [weight], [enabled], [sessionid], [criteriaid])
SELECT 
    dd.description,
    CASE 
        WHEN dd.code = 'REG01' THEN 1.6  -- San José Central
        WHEN dd.code IN ('AGE02', 'AGE03', 'AGE04') THEN 1.3  -- Adultos
        WHEN dd.code = 'AGE06' THEN 0.7  -- Mayores de 65
        WHEN dd.code = 'OCC02' THEN 1.2  -- Funcionarios públicos
        ELSE 1.0
    END AS weight,
    1 AS enabled,
    6 AS sessionid,
    c.criteriaid
FROM [dbo].[vote_criterias] c
JOIN [dbo].[vpv_demographic_data] dd ON c.demographicid = dd.demographicid;

-- Sesión 7: Votación calificada extendida (énfasis en educación)
INSERT INTO [dbo].[vote_voting_criteria] ([value], [weight], [enabled], [sessionid], [criteriaid])
SELECT 
    dd.description,
    CASE 
        WHEN dd.code = 'EDU05' THEN 2.0  -- Posgrado
        WHEN dd.code = 'EDU04' THEN 1.5  -- Universitario
        WHEN dd.code = 'OCC02' THEN 1.6  -- Funcionarios públicos
        WHEN dd.code = 'OCC01' THEN 0.5  -- Estudiantes
        WHEN dd.code = 'AGE01' THEN 0.6  -- Jóvenes
        ELSE 1.0
    END AS weight,
    1 AS enabled,
    7 AS sessionid,
    c.criteriaid
FROM [dbo].[vote_criterias] c
JOIN [dbo].[vpv_demographic_data] dd ON c.demographicid = dd.demographicid;


-- Inserción de compromisos (conteo de votos por opción)
INSERT INTO [dbo].[vote_commitments] ([value], [sum], [optionid])
VALUES 
-- Pregunta 1 (Aprobación Boulevard Cartago - Sesión 1: todos valen 1.0)
(125, 125, 1),   -- Sí 
(42, 42, 2),     -- No
(18, 18, 3),     -- Abstención 

-- Pregunta 2 (Mejoras prioritarias Boulevard - Sesión 1)
(98, 98, 4),     -- Ampliación de carriles
(75, 75, 5),     -- Nuevas aceras
(103, 103, 6),   -- Ciclovía integrada
(62, 62, 7),     -- Mejor iluminación
(87, 87, 8),     -- Áreas verdes
(45, 45, 9),     -- Señalización inteligente

-- Pregunta 3 (Aprobación Planta Solar - Sesión 3)

(180, 156, 10),  -- Sí

(106, 72, 11),    -- Sí
(22.8, 38, 12),                      -- No 
(24, 24, 13),                      -- No tengo info 

-- Pregunta 4 (Impacto ambiental Planta Solar - Sesión 3)
(27, 15, 14),   -- 1 - Mínimo 
(42, 28, 15),   -- 2 
(98.8, 76, 16),   -- 3 - Moderado 
(94, 94, 17),   -- 4 
(40.2, 67, 18),   -- 5 - Máximo 

-- Pregunta 5 (Utilidad Plataforma AgriTech - Sesión 2)
(147, 112, 19),  -- Muy útil 
(77, 65, 20),    -- Útil con ajustes 
(16.1, 23, 21),             -- No la usaría 
(30, 30, 22),             -- No estoy seguro 

-- Pregunta 6 (Funcionalidades AgriTech - Sesión 2)
(124, 89, 23),    -- Monitoreo 
(96, 76, 24),    -- Riego 
(118, 94, 25),    -- Alertas plagas 
(68, 68, 26),             -- Mercado 
(36.4, 52, 27),             -- Asesoría 
(63, 63, 28),             -- Clima 

-- Pregunta 7 (Aprobación Bicicletas Públicas - Sesión 4)
(175, 143, 29),   -- Totalmente necesario 
(66, 58, 30),    -- Con condiciones 
(41.6, 32, 31),             -- No prioritario 
(21.6, 27, 32),             -- Me opongo 

-- Pregunta 8 (Zonas para bicicletas - Sesión 4)
(136, 112, 33),   -- Centro histórico 
(113, 98, 34),    -- Zona universitaria 
(87, 87, 35),             -- Parques 
(68.4, 76, 36),             -- Estaciones de tren 
(65, 65, 37),             -- Zonas residenciales 
(43.2, 54, 38),             -- Centros comerciales 

-- Pregunta 9 (Aprobación EcoBarrios - Sesión 6)
(180, 132, 39),   -- Implementar ya 
(83, 71, 40),    -- Con ajustes 
(24.5, 35, 41),             -- Necesita rediseño 
(22, 22, 42),             -- Me opongo 

-- Pregunta 10 (Importancia componentes EcoBarrios - Sesión 6)
(28.8, 18, 43),             -- 1 - Sin importancia 
(41.6, 32, 44),             -- 2 
(75, 75, 45),             -- 3 - Media 
(65.8, 94, 46),             -- 4 
(113, 101, 47),   -- 5 - Crítica 

-- Pregunta 11 (Aprobación Remodelación Mercado - Sesión 7)
(198, 128, 48),   -- Urgente 
(77, 59, 49),    -- Por fases 
(64.5, 43, 50),             -- Solo mantenimiento 
(15, 30, 51),             -- Dejar como está 

-- Pregunta 12 (Mejoras urgentes Mercado - Sesión 7)
(142, 92, 52),    -- Sanitaria 
(108, 84, 53),    -- Eléctrica 
(101, 76, 54),    -- Accesibilidad 
(63, 63, 55),             -- Nuevos vendedores 
(28.5, 57, 56),             -- Carga/descarga 

-- Pregunta 13 (Necesidad Plataforma "Mi Voz" - Sesión 5)
(191, 121, 57),   -- Muy necesaria 
(86, 68, 58),    -- Con ajustes 
(63, 42, 59),             -- Neutral 
(15.5, 31, 60),             -- No prioridad 
(18, 18, 61),             -- Me opongo 

-- Pregunta 14 (Prioridad funcionalidades "Mi Voz" - Sesión 5)
(152, 102, 62),   -- Propuestas 
(122, 98, 63),    -- Consultas 
(112, 87, 64),    -- Seguimiento 
(76, 76, 65),             -- Reporte problemas 
(32, 65, 66),             -- Presupuesto 
(54, 54, 67);             -- Foros 


INSERT INTO [dbo].[vote_demographic_stats] ([sum], [value], [demographicid], [optionid])
VALUES 
-- Género (IDs 1-4) para todas las opciones principales
-- Opción 1: Sí (Boulevard Cartago)
(68, 'Masculino', 1, 1),
(52, 'Femenino', 2, 1),
(5, 'No binario', 3, 1),

-- Opción 2: No
(22, 'Masculino', 1, 2),
(18, 'Femenino', 2, 2),
(2, 'No binario', 3, 2),

-- Opción 3: Abstención
(8, 'Masculino', 1, 3),
(7, 'Femenino', 2, 3),
(3, 'No binario', 3, 3),

-- Edades (IDs 5-10) para opciones clave
-- Opción 1
(25, '18-25 años', 5, 1),
(38, '26-35 años', 6, 1),
(32, '36-45 años', 7, 1),
(20, '46-55 años', 8, 1),
(10, '56-65 años', 9, 1),

-- Opción 6: Ciclovía integrada
(35, '18-25 años', 5, 6),
(42, '26-35 años', 6, 6),
(18, '36-45 años', 7, 6),
(8, '46-55 años', 8, 6),

-- Regiones (IDs 11-18)
-- Opción 1
(45, 'Cartago', 14, 1),
(32, 'San José Central', 11, 1),
(18, 'Heredia', 12, 1),
(15, 'Alajuela', 13, 1),
(10, 'Limón', 15, 1),

-- Opción 48: Remodelación mercado
(65, 'Heredia', 12, 48),
(28, 'San José Central', 11, 48),
(15, 'Alajuela', 13, 48),
(12, 'Cartago', 14, 48),
(8, 'Puntarenas', 16, 48),

-- Educación (IDs 16-20)
-- Opción 1
(15, 'Primaria', 16, 1),
(28, 'Secundaria', 17, 1),
(42, 'Universitario', 19, 1),
(40, 'Posgrado', 20, 1),

-- Opción 20: AgriTech
(40, 'Universitario', 19, 20),
(25, 'Posgrado', 20, 20),

-- Ocupación (IDs 17-24)
-- Opción 29: Bicicletas
(42, 'Estudiante', 17, 29),
(38, 'Empleado sector público', 18, 29),
(35, 'Empleado sector privado', 19, 29),
(18, 'Independiente', 23, 29),
(10, 'Jubilado', 24, 29),

-- Ingresos (IDs 21-25)
-- Opción 10: Planta Solar
(12, 'Menos de ¢300,000', 21, 10),
(28, '¢300,000 - ¢600,000', 22, 10),
(35, '¢600,001 - ¢900,000', 23, 10),
(42, '¢900,001 - ¢1,200,000', 24, 10),
(39, 'Más de ¢1,200,000', 25, 10),

-- Discapacidad (IDs 26-30)
-- Opción 19: AgriTech
(5, 'Discapacidad física', 27, 19),
(3, 'Discapacidad visual', 28, 19),
(2, 'Discapacidad auditiva', 29, 19),
(102, 'Sin discapacidad', 26, 19),

-- Completando todas las opciones restantes con datos coherentes
-- Opción 4: Ampliación carriles
(35, 'Masculino', 1, 4),
(32, 'Femenino', 2, 4),
(31, '18-25 años', 5, 4),
(28, '26-35 años', 6, 4),
(15, 'Universitario', 19, 4),

-- Opción 5: Nuevas aceras
(28, 'Masculino', 1, 5),
(30, 'Femenino', 2, 5),
(17, '26-35 años', 6, 5),
(22, 'Empleado sector público', 18, 5),

-- Opción 7: Mejor iluminación
(22, 'Masculino', 1, 7),
(20, 'Femenino', 2, 7),
(20, '36-45 años', 7, 7),
(15, '¢600,001 - ¢900,000', 23, 7),

-- Opción 8: Áreas verdes
(30, 'Masculino', 1, 8),
(35, 'Femenino', 2, 8),
(22, '26-35 años', 6, 8),
(18, 'Independiente', 23, 8),

-- Opción 9: Señalización inteligente
(18, 'Masculino', 1, 9),
(15, 'Femenino', 2, 9),
(12, '18-25 años', 5, 9),
(10, 'Estudiante', 17, 9),

-- Opción 11: Sí con condiciones (Planta Solar)
(15, '¢300,000 - ¢600,000', 22, 11),
(20, '¢600,001 - ¢900,000', 23, 11),
(25, '¢900,001 - ¢1,200,000', 24, 11),
(12, 'Más de ¢1,200,000', 25, 11),
(18, 'Guanacaste', 17, 11),

-- Opción 12: No (Planta Solar)
(15, 'Menos de ¢300,000', 21, 12),
(12, '¢300,000 - ¢600,000', 22, 12),
(11, '¢600,001 - ¢900,000', 23, 12),
(8, 'Posgrado', 20, 12),

-- Opción 13: No tengo info
(8, 'Menos de ¢300,000', 21, 13),
(10, '¢300,000 - ¢600,000', 22, 13),
(6, '¢600,001 - ¢900,000', 23, 13),
(5, 'Secundaria', 17, 13),

-- Opción 14-18: Escala impacto ambiental
(15, '1 - Impacto mínimo', 5, 14), -- Usando edad como proxy
(28, '2', 6, 15),
(76, '3 - Impacto moderado', 7, 16),
(94, '4', 8, 17),
(67, '5 - Impacto muy alto', 9, 18),

-- Opción 21: No la usaría (AgriTech)
(23, 'Estudiante', 17, 21),
(15, 'Primaria', 16, 21),
(10, 'Desempleado', 24, 21),

-- Opción 22: No estoy seguro
(30, 'No binario', 3, 22),
(25, 'Prefiero no decir', 4, 22),
(15, '66+ años', 10, 22),

-- Opción 23-28: Funcionalidades AgriTech
(50, 'Monitoreo de cultivos', 5, 23), -- Usando edad como proxy
(40, 'Recomendaciones de riego', 6, 24),
(60, 'Alertas tempranas de plagas', 7, 25),
(68, 'Mercado en línea', 8, 26),
(52, 'Asesoría agronómica', 9, 27),
(63, 'Historial de clima', 10, 28),

-- Opción 30: Con condiciones (Bicicletas)
(30, 'Con condiciones', 5, 30), -- Usando edad como proxy
(25, 'Con condiciones', 6, 30),
(18, 'Con condiciones', 7, 30),

-- Opción 31: No prioritario
(15, 'No prioritario', 8, 31),
(12, 'No prioritario', 9, 31),
(10, 'No prioritario', 10, 31),

-- Opción 32: Me opongo
(12, 'Me opongo', 11, 32),
(10, 'Me opongo', 12, 32),
(8, 'Me opongo', 13, 32),

-- Opción 33-38: Zonas bicicletas
(60, 'Centro histórico', 14, 33),
(50, 'Zona universitaria', 15, 34),
(40, 'Parques metropolitanos', 16, 35),
(35, 'Estaciones de tren', 17, 36),
(30, 'Zonas residenciales', 18, 37),
(25, 'Centros comerciales', 19, 38),

-- Opción 39-42: EcoBarrios
(80, 'Implementar inmediatamente', 20, 39),
(40, 'Con ajustes al plan', 21, 40),
(20, 'Necesita rediseño', 22, 41),
(15, 'Me opongo', 23, 42),

-- Opción 43-47: Importancia componentes
(18, '1 - Sin importancia', 24, 43),
(32, '2', 25, 44),
(75, '3 - Importancia media', 26, 45),
(94, '4', 27, 46),
(60, '5 - Críticamente importante', 28, 47),

-- Opción 49: Por fases (Remodelación)
(30, 'Por fases', 29, 49),
(25, 'Por fases', 30, 49),
(20, 'Por fases', 1, 49),

-- Opción 50: Solo mantenimiento
(20, 'Solo mantenimiento', 2, 50),
(18, 'Solo mantenimiento', 3, 50),
(15, 'Solo mantenimiento', 4, 50),

-- Opción 51: Dejar como está
(15, 'Dejar como está', 5, 51),
(12, 'Dejar como está', 6, 51),
(10, 'Dejar como está', 7, 51),

-- Opción 52-56: Mejoras mercado
(50, 'Infraestructura sanitaria', 8, 52),
(40, 'Sistema eléctrico', 9, 53),
(35, 'Accesibilidad', 10, 54),
(30, 'Espacios nuevos vendedores', 11, 55),
(25, 'Áreas de carga/descarga', 12, 56),

-- Opción 57-61: Plataforma "Mi Voz"
(70, 'Muy necesaria', 13, 57),
(40, 'Con ajustes', 14, 58),
(20, 'Neutral', 15, 59),
(15, 'No prioridad', 16, 60),
(10, 'Me opongo', 17, 61),

-- Opción 62-67: Funcionalidades "Mi Voz"
(50, 'Sistema de propuestas', 18, 62),
(40, 'Consultas públicas', 19, 63),
(35, 'Seguimiento de proyectos', 20, 64),
(30, 'Reporte de problemas', 21, 65),
(25, 'Presupuesto participativo', 22, 66),
(20, 'Foros de discusión', 23, 67);
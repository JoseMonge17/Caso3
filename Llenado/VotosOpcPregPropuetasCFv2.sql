use VotoPuraVida;

INSERT INTO [dbo].[vpv_proposal_type] ([name], [description], [enabled]) 
VALUES 
('Infraestructura Pública', 'Proyectos de desarrollo de infraestructura urbana', 1),
('Energía Renovable', 'Proyectos relacionados con energías limpias', 1),
('Innovación Tecnológica', 'Soluciones tecnológicas innovadoras', 1),
('Desarrollo Social', 'Iniciativas para mejorar condiciones sociales', 1),
('Educación', 'Proyectos educativos y formativos', 1),
('Salud Comunitaria', 'Iniciativas para mejorar servicios de salud', 1),
('Cultura y Arte', 'Proyectos culturales y artísticos', 1),
('Medio Ambiente', 'Iniciativas de conservación ambiental', 1),
('Desarrollo Económico', 'Proyectos para impulsar la economía local', 1),
('Turismo Sostenible', 'Iniciativas turísticas con enfoque sostenible', 1);

INSERT INTO [dbo].[vpv_proposal_status] ([name], [description], [enabled]) 
VALUES 
('En Revisión', 'Propuesta enviada para evaluación', 1),
('Aprobada', 'Propuesta aprobada para financiamiento', 1),
('Rechazada', 'Propuesta no aprobada', 1),
('En Modificación', 'Propuesta requiere ajustes', 1),
('En Financiamiento', 'Propuesta en búsqueda de fondos', 1),
('Financiada', 'Propuesta con financiamiento completo', 1),
('Cancelada', 'Propuesta cancelada por el proponente', 1);

INSERT INTO [dbo].[vpv_origin_type] ([name], [description], [enabled])
VALUES
('Ciudadano', 'Propuesta originada por un ciudadano individual o grupo de ciudadanos', 1),
('Entidad', 'Propuesta presentada por una organización, asociación o entidad privada', 1),
('Gobierno', 'Propuesta generada por una institución gubernamental o entidad pública', 1);

INSERT INTO [dbo].[vpv_proposal] (
    [name], [enabled], [current_version], [description], 
    [submission_date], [version], [origin_typeid], [userid], 
    [statusid], [proposal_typeid], [entityid], [allows_comments]
)
VALUES
-- 1. Initial proposal from Project 1: Boulevard Cartago
('Expansión Boulevard Cartago - Fase 1', 1, 1, 
 'Propuesta inicial para ampliación de 5.2km del boulevard principal de Cartago',
 '2023-09-15', 1, 3, 101, 1, 1, 3, 1),

-- 2. Initial proposal from Project 2: Planta Solar Guanacaste
('Planta Solar Guanacaste - 4.5MW', 1, 1,
 'Proyecto de generación solar para abastecer 6,500 hogares',
 '2024-01-10', 1, 2, 201, 1, 2, 5, 1),

-- 3. Initial proposal from Project 3: Plataforma Agricultura Digital
('AgriTech CR - Plataforma Digital', 1, 1,
 'Solución tecnológica para optimización de cultivos para pequeños agricultores',
 '2024-04-05', 1, 2, 301, 2, 3, 21, 1),

 -- 4. Propuesta para sistema de bicicletas públicas
('Sistema de Bicicletas Públicas en San José', 1, 1,
 'Implementación de 50 estaciones con 500 bicicletas en el centro de la capital',
 '2024-02-20', 1, 3, 102, 4, 3, 1, 1),

-- 5. Programa de reciclaje comunitario
('EcoBarrios: Programa Integral de Reciclaje', 1, 2,
 'Separación en origen con recolección diferenciada en 15 distritos',
 '2023-11-08', 2, 1, 45, 5, 2, 11, 1),

-- 6. Modernización de mercado municipal
('Remodelación Mercado Central de Heredia', 1, 1,
 'Actualización de infraestructura y servicios del principal mercado de la provincia',
 '2024-03-12', 1, 3, 103, 6, 3, 4, 1),

-- 7. Plataforma de participación ciudadana
('Plataforma Digital "Mi Voz"', 1, 1,
 'Sistema en línea para propuestas y consultas ciudadanas al gobierno local',
 '2023-12-05', 1, 3, 104, 6, 1, 30, 1),

-- 8. Programa de preservación cultural
('Rescate de Tradiciones Guanacastecas', 1, 1,
 'Talleres y eventos para preservar música, danza y artesanías tradicionales',
 '2024-01-25', 1, 2, 202, 3, 4, 23, 1),

-- 9. Mejora de infraestructura educativa
('Techado para Canchas Deportivas Escolares', 1, 1,
 'Construcción de 10 techos para canchas en escuelas de zonas lluviosas',
 '2024-04-15', 1, 1, 46, 3, 5, 19, 1),

-- 10. Programa de seguridad vial
('Rutas Seguras: Iluminación y Cámaras', 1, 1,
 'Instalación de 200 luminarias y 50 cámaras en rutas escolares prioritarias',
 '2023-10-30', 1, 3, 105, 1, 2, 10, 1);


 -- Reglas de decision
INSERT INTO vote_rules (name, dataType) VALUES
('Aceptación por mayoría', 'BIT'),
('Aceptación por porcentaje', 'DECIMAL'),
('Rechazo por mayoria', 'BIT');










 -- Insertar tipos de votación
/*INSERT INTO [dbo].[vote_types] ([name], [description], [singleWeight])
VALUES 
('Mayoría Simple', 'Decisión por mayoría simple de votos', 1),
('Mayoría Calificada', 'Requiere al menos 2/3 de votos afirmativos', 1),
('Unánime', 'Requiere aprobación por todos los votantes', 0),
('Ponderada', 'Votos con pesos diferentes según criterios', 0),
('Público', 'Votación abierta a toda la comunidad', 1);
*/

-- Tipos de votos
INSERT INTO vote_types (name, description, singleWeight)
VALUES
  ('Publico', 'Se puede ver quien voto en una sesión particular', 0),
  ('Privado', 'No se puede ver quien voto en una sesión particular', 0);







-- Insertar estados de sesión
INSERT INTO [dbo].[vote_sessions_status] ([name])
VALUES 
('Programada'),
('En Progreso'),
('Concluida'),
('Cancelada'),
('Suspendida');








-- Insertar tipos de visibilidad de resultados
/*INSERT INTO [dbo].[vote_result_visibilities] ([description])
VALUES 
('Público'),
('Privado'),
('Solo participantes'),
('Resultados parciales'),
('Oculto hasta finalización');
*/

-- Visibilidades de los votos
INSERT INTO vote_result_visibilities (description)
VALUES
  ('After_Close'),         -- Se cierra el plazo de votación (AC)
  ('After_All_Votes');     -- Todos los elegibles ya votaron (AV)







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
('2023-03-12 08:30:00', '2023-03-17 17:30:00', 0x3C4D5E6F, 3, 4, 3),

-- Sesión 4: Votación especial rápida
('2023-04-03 14:00:00', '2023-04-05 20:00:00', 0x4D5E6F7A, 3, 1, 5),

-- Sesión 5: Votación unánime técnica
('2023-05-08 09:00:00', '2023-05-13 18:00:00', 0x5E6F7A8B, 3, 3, 4),

-- Sesión 6: Votación pública de emergencia
('2023-06-20 08:00:00', '2023-06-22 22:00:00', 0x6F7A8B9C, 3, 5, 1),

-- Sesión 7: Votación calificada extendida
('2023-07-10 09:00:00', '2023-07-15 18:00:00', 0x7A8B9CAD, 3, 2, 5),

-- Sesión 8: Votación suspendida (ejemplo)
('2023-08-07 10:00:00', '2023-08-09 16:00:00', 0x8B9CADBE, 4, 1, 5),

-- Sesión 9: Votación programada futura
('2023-09-11 09:00:00', '2023-09-16 18:00:00', 0x9CADBECF, 1, 1, 5),

-- Sesión 10: Votación en progreso (ejemplo)
('2023-10-05 08:00:00', '2023-10-07 20:00:00', 0xADBECFD0, 2, 1, 4),

-- Sesión 11: Votación cancelada (ejemplo)
('2023-11-13 09:00:00', '2023-11-18 18:00:00', 0xBECFD0E1, 4, 1, 5),

-- Sesión 12: Votación concluida reciente
('2023-12-04 10:00:00', '2023-12-06 16:00:00', 0xCFD0E1F2, 3, 1, 1);


SELECT * FROM cf_proposal_votes
-- Inserción de votos para las 10 propuestas en diferentes sesiones
INSERT INTO [dbo].[cf_proposal_votes] ([date], [result], [sessionid], [proposalid])
VALUES 
-- Propuesta 1: Expansión Boulevard Cartago (proposalid=1)
('2023-09-20 10:15:00', 1, 9, 1),  -- Sesión 9


-- Propuesta 2: Planta Solar Guanacaste (proposalid=2)
('2024-01-15 09:45:00', 1, 11, 2),  -- Sesión 11


-- Propuesta 3: AgriTech CR (proposalid=3)
('2024-04-10 14:20:00', 1, 12, 3),  -- Sesión 12


-- Propuesta 4: Bicicletas Públicas (proposalid=4)
('2024-02-25 09:30:00', 1, 10, 4),  -- Sesión 10


-- Propuesta 5: EcoBarrios (proposalid=5)
('2023-11-15 13:25:00', 1, 8, 5),   -- Sesión 8


-- Propuesta 6: Mercado Heredia (proposalid=6)
('2024-03-18 11:10:00', 1, 7, 6),   -- Sesión 7


-- Propuesta 7: Plataforma Mi Voz (proposalid=7)
('2023-12-10 10:20:00', 1, 6, 7),    -- Sesión 6


-- Propuesta 8: Tradiciones Guanacastecas (proposalid=8)
('2024-01-30 09:15:00', 1, 5, 8),    -- Sesión 5


-- Propuesta 9: Techados Escolares (proposalid=9)
('2024-04-20 13:50:00', 1, 4, 9),    -- Sesión 4


-- Propuesta 10: Rutas Seguras (proposalid=10)
('2023-11-05 09:40:00', 1, 3, 10),   -- Sesión 3


INSERT INTO [dbo].[vote_question_types] ( [description])
VALUES 
('Selección simple'),
('Selección múltiple'),
('Escala Likert'),
('Texto abierto'),
('Ordenación');

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
('¿Apoya la construcción de la Planta Solar Guanacaste?', 1, 1, '2024-01-05', NULL, 1, 2),
('Valore el impacto ambiental del proyecto (1-5)', 1, 1, '2024-01-05', NULL, 3, 2),

-- Sesión 3
('¿Considera útil la plataforma AgriTech para pequeños agricultores?', 1, 1, '2024-04-01', NULL, 1, 3),
('Seleccione las funcionalidades más importantes', 0, 2, '2024-04-01', NULL, 2, 3),

-- Sesión 4
('¿Aprueba el sistema de bicicletas públicas en San José?', 1, 1, '2024-02-15', NULL, 1, 4),
('Indique las zonas prioritarias para estaciones', 0, 5, '2024-02-15', NULL, 2, 4),

-- Sesión 5
('¿Apoya el programa EcoBarrios de reciclaje comunitario?', 1, 1, '2023-11-03', NULL, 1, 5),
('Valore la importancia de los componentes del programa (1-5)', 0, 1, '2023-11-03', NULL, 3, 5),

-- Sesión 6
('¿Aprueba la remodelación del Mercado Central de Heredia?', 1, 1, '2024-03-08', NULL, 1, 6),
('Seleccione las mejoras más urgentes', 0, 2, '2024-03-08', NULL, 2, 6),

-- Sesión 7
('¿Considera necesaria la plataforma "Mi Voz" para participación ciudadana?', 1, 1, '2023-12-01', NULL, 1, 7),
('Ordene por prioridad las funcionalidades deseadas', 0, 5, '2023-12-01', NULL, 5, 7),

-- Sesión 8
('¿Apoya el programa de rescate de tradiciones Guanacastecas?', 1, 1, '2024-01-20', NULL, 1, 8),
('Seleccione las tradiciones a preservar', 0, 3, '2024-01-20', NULL, 2, 8),

-- Sesión 9
('¿Aprueba los techados para canchas deportivas escolares?', 1, 1, '2024-04-10', NULL, 1, 9),
('Indique las escuelas con mayor necesidad', 0, 10, '2024-04-10', NULL, 2, 9),

-- Sesión 10
('¿Apoya el programa "Rutas Seguras" con iluminación y cámaras?', 1, 1, '2023-10-25', NULL, 1, 10),
('Seleccione las rutas más peligrosas que requieren intervención', 0, 5, '2023-10-25', NULL, 2, 10);

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

-- Pregunta 3 (Sesión 2 - Aprobación Planta Solar)
('Sí, totalmente de acuerdo', 'fully_approve', NULL, 1, 0xADBECFD0, '2024-01-05', NULL, 3),
('Sí, con condiciones', 'approve_with_conditions', NULL, 2, 0xBECFD0E1, '2024-01-05', NULL, 3),
('No, me opongo al proyecto', 'reject', NULL, 3, 0xCFD0E1F2, '2024-01-05', NULL, 3),
('No tengo suficiente información', 'not_enough_info', NULL, 4, 0xD0E1F203, '2024-01-05', NULL, 3),

-- Pregunta 4 (Sesión 2 - Impacto ambiental Planta Solar)
('1 - Impacto mínimo', '1_minimal', NULL, 1, 0xE1F20314, '2024-01-05', NULL, 4),
('2', '2_low', NULL, 2, 0xF2031425, '2024-01-05', NULL, 4),
('3 - Impacto moderado', '3_moderate', NULL, 3, 0x03142536, '2024-01-05', NULL, 4),
('4', '4_high', NULL, 4, 0x14253647, '2024-01-05', NULL, 4),
('5 - Impacto muy alto', '5_very_high', NULL, 5, 0x25364758, '2024-01-05', NULL, 4),

-- Pregunta 5 (Sesión 3 - Utilidad Plataforma AgriTech)
('Sí, sería muy útil', 'very_useful', NULL, 1, 0x36475869, '2024-04-01', NULL, 5),
('Sí, pero con ajustes', 'useful_with_changes', NULL, 2, 0x4758697A, '2024-04-01', NULL, 5),
('No, no la usaría', 'not_useful', NULL, 3, 0x58697A8B, '2024-04-01', NULL, 5),
('No estoy seguro', 'unsure', NULL, 4, 0x697A8B9C, '2024-04-01', NULL, 5),

-- Pregunta 6 (Sesión 3 - Funcionalidades AgriTech)
('Monitoreo de cultivos en tiempo real', 'real_time_monitoring', 'http://docs.example.com/agritech/monitoring.pdf', 1, 0x7A8B9CAD, '2024-04-01', NULL, 6),
('Recomendaciones de riego automatizado', 'irrigation_recommendations', 'http://docs.example.com/agritech/irrigation.pdf', 2, 0x8B9CADBE, '2024-04-01', NULL, 6),
('Alertas tempranas de plagas', 'pest_alerts', 'http://docs.example.com/agritech/pests.pdf', 3, 0x9CADBECF, '2024-04-01', NULL, 6),
('Mercado en línea para productos', 'online_marketplace', 'http://docs.example.com/agritech/marketplace.pdf', 4, 0xADBECFD0, '2024-04-01', NULL, 6),
('Asesoría agronómica virtual', 'virtual_consultation', 'http://docs.example.com/agritech/consultation.pdf', 5, 0xBECFD0E1, '2024-04-01', NULL, 6),
('Historial de clima y predicciones', 'weather_history', 'http://docs.example.com/agritech/weather.pdf', 6, 0xCFD0E1F2, '2024-04-01', NULL, 6),

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

-- Pregunta 9 (Sesión 5 - Aprobación EcoBarrios)
('Sí, implementar inmediatamente', 'approve_immediately', NULL, 1, 0x7A8B9CAD, '2023-11-03', NULL, 9),
('Sí, pero con ajustes al plan', 'approve_with_changes', NULL, 2, 0x8B9CADBE, '2023-11-03', NULL, 9),
('No, el plan necesita rediseño', 'needs_redesign', NULL, 3, 0x9CADBECF, '2023-11-03', NULL, 9),
('No, me opongo al programa', 'reject', NULL, 4, 0xADBECFD0, '2023-11-03', NULL, 9),

-- Pregunta 10 (Sesión 5 - Importancia componentes EcoBarrios)
('1 - Sin importancia', '1_unimportant', NULL, 1, 0xBECFD0E1, '2023-11-03', NULL, 10),
('2', '2_low', NULL, 2, 0xCFD0E1F2, '2023-11-03', NULL, 10),
('3 - Importancia media', '3_medium', NULL, 3, 0xD0E1F203, '2023-11-03', NULL, 10),
('4', '4_high', NULL, 4, 0xE1F20314, '2023-11-03', NULL, 10),
('5 - Críticamente importante', '5_critical', NULL, 5, 0xF2031425, '2023-11-03', NULL, 10),

-- Pregunta 11 (Sesión 6 - Aprobación Remodelación Mercado)
('Sí, urgente remodelación', 'approve_urgent', NULL, 1, 0x03142536, '2024-03-08', NULL, 11),
('Sí, pero por fases', 'approve_phased', NULL, 2, 0x14253647, '2024-03-08', NULL, 11),
('No, solo mantenimiento', 'maintenance_only', NULL, 3, 0x25364758, '2024-03-08', NULL, 11),
('No, dejar como está', 'reject', NULL, 4, 0x36475869, '2024-03-08', NULL, 11),

-- Pregunta 12 (Sesión 6 - Mejoras urgentes Mercado)
('Infraestructura sanitaria', 'sanitary', 'http://docs.example.com/market/sanitary.pdf', 1, 0x4758697A, '2024-03-08', NULL, 12),
('Sistema eléctrico y seguridad', 'electrical', 'http://docs.example.com/market/electrical.pdf', 2, 0x58697A8B, '2024-03-08', NULL, 12),
('Accesibilidad para discapacitados', 'accessibility', 'http://docs.example.com/market/accessibility.pdf', 3, 0x697A8B9C, '2024-03-08', NULL, 12),
('Espacios para nuevos vendedores', 'new_vendors', 'http://docs.example.com/market/vendors.pdf', 4, 0x7A8B9CAD, '2024-03-08', NULL, 12),
('Áreas de carga y descarga', 'loading_zones', 'http://docs.example.com/market/loading.pdf', 5, 0x8B9CADBE, '2024-03-08', NULL, 12),

-- Pregunta 13 (Sesión 7 - Necesidad Plataforma "Mi Voz")
('Sí, muy necesaria', 'strongly_agree', NULL, 1, 0x9CADBECF, '2023-12-01', NULL, 13),
('Sí, pero con ajustes', 'agree_with_changes', NULL, 2, 0xADBECFD0, '2023-12-01', NULL, 13),
('Neutral', 'neutral', NULL, 3, 0xBECFD0E1, '2023-12-01', NULL, 13),
('No, no es prioridad', 'not_priority', NULL, 4, 0xCFD0E1F2, '2023-12-01', NULL, 13),
('No, me opongo', 'reject', NULL, 5, 0xD0E1F203, '2023-12-01', NULL, 13),

-- Pregunta 14 (Sesión 7 - Prioridad funcionalidades "Mi Voz")
('Sistema de propuestas ciudadanas', 'proposals', 'http://docs.example.com/mivoz/proposals.pdf', 1, 0xE1F20314, '2023-12-01', NULL, 14),
('Consultas públicas', 'polls', 'http://docs.example.com/mivoz/polls.pdf', 2, 0xF2031425, '2023-12-01', NULL, 14),
('Seguimiento de proyectos', 'project_tracking', 'http://docs.example.com/mivoz/tracking.pdf', 3, 0x03142536, '2023-12-01', NULL, 14),
('Reporte de problemas', 'issue_reporting', 'http://docs.example.com/mivoz/issues.pdf', 4, 0x14253647, '2023-12-01', NULL, 14),
('Presupuesto participativo', 'participatory_budget', 'http://docs.example.com/mivoz/budget.pdf', 5, 0x25364758, '2023-12-01', NULL, 14),
('Foros de discusión', 'forums', 'http://docs.example.com/mivoz/forums.pdf', 6, 0x36475869, '2023-12-01', NULL, 14),

-- Pregunta 15 (Sesión 8 - Aprobación Rescate Tradiciones)
('Sí, totalmente necesario', 'strongly_approve', NULL, 1, 0x4758697A, '2024-01-20', NULL, 15),
('Sí, pero con enfoque moderno', 'approve_modern', NULL, 2, 0x58697A8B, '2024-01-20', NULL, 15),
('No, no es prioritario', 'not_priority', NULL, 3, 0x697A8B9C, '2024-01-20', NULL, 15),
('No, me opongo', 'reject', NULL, 4, 0x7A8B9CAD, '2024-01-20', NULL, 15),

-- Pregunta 16 (Sesión 8 - Tradiciones a preservar)
('Música tradicional (marimba, etc.)', 'music', 'http://docs.example.com/traditions/music.pdf', 1, 0x8B9CADBE, '2024-01-20', NULL, 16),
('Danzas folclóricas', 'dances', 'http://docs.example.com/traditions/dances.pdf', 2, 0x9CADBECF, '2024-01-20', NULL, 16),
('Artesanías típicas', 'handicrafts', 'http://docs.example.com/traditions/handicrafts.pdf', 3, 0xADBECFD0, '2024-01-20', NULL, 16),
('Gastronomía tradicional', 'food', 'http://docs.example.com/traditions/food.pdf', 4, 0xBECFD0E1, '2024-01-20', NULL, 16),
('Leyendas e historias locales', 'stories', 'http://docs.example.com/traditions/stories.pdf', 5, 0xCFD0E1F2, '2024-01-20', NULL, 16),
('Juegos tradicionales', 'games', 'http://docs.example.com/traditions/games.pdf', 6, 0xD0E1F203, '2024-01-20', NULL, 16),

-- Pregunta 17 (Sesión 9 - Aprobación Techados Escolares)
('Sí, todas las escuelas', 'approve_all', NULL, 1, 0xE1F20314, '2024-04-10', NULL, 17),
('Sí, solo las más necesitadas', 'approve_selective', NULL, 2, 0xF2031425, '2024-04-10', NULL, 17),
('No, otros proyectos son más urgentes', 'other_priorities', NULL, 3, 0x03142536, '2024-04-10', NULL, 17),
('No, me opongo', 'reject', NULL, 4, 0x14253647, '2024-04-10', NULL, 17),

-- Pregunta 18 (Sesión 9 - Escuelas prioritarias)
('Escuela Central de San José', 'central_sj', 'http://docs.example.com/schools/central_sj.pdf', 1, 0x25364758, '2024-04-10', NULL, 18),
('Escuela de Alajuelita', 'alajuelita', 'http://docs.example.com/schools/alajuelita.pdf', 2, 0x36475869, '2024-04-10', NULL, 18),
('Escuela de Puriscal', 'puriscal', 'http://docs.example.com/schools/puriscal.pdf', 3, 0x4758697A, '2024-04-10', NULL, 18),
('Escuela de Turrialba', 'turrialba', 'http://docs.example.com/schools/turrialba.pdf', 4, 0x58697A8B, '2024-04-10', NULL, 18),
('Escuela de Limón Centro', 'limon', 'http://docs.example.com/schools/limon.pdf', 5, 0x697A8B9C, '2024-04-10', NULL, 18),
('Escuela de Puntarenas', 'puntarenas', 'http://docs.example.com/schools/puntarenas.pdf', 6, 0x7A8B9CAD, '2024-04-10', NULL, 18),

-- Pregunta 19 (Sesión 10 - Aprobación Rutas Seguras)
('Sí, implementar inmediatamente', 'approve_immediate', NULL, 1, 0x8B9CADBE, '2023-10-25', NULL, 19),
('Sí, pero por fases', 'approve_phased', NULL, 2, 0x9CADBECF, '2023-10-25', NULL, 19),
('No, solo iluminación', 'lighting_only', NULL, 3, 0xADBECFD0, '2023-10-25', NULL, 19),
('No, me opongo al proyecto', 'reject', NULL, 4, 0xBECFD0E1, '2023-10-25', NULL, 19),

-- Pregunta 20 (Sesión 10 - Rutas peligrosas prioritarias)
('Ruta escolar San José Centro', 'sj_center', 'http://maps.example.com/routes/sj_center.pdf', 1, 0xCFD0E1F2, '2023-10-25', NULL, 20),
('Ruta escolar Desamparados', 'desamparados', 'http://maps.example.com/routes/desamparados.pdf', 2, 0xD0E1F203, '2023-10-25', NULL, 20),
('Ruta escolar Goicoechea', 'goicoechea', 'http://maps.example.com/routes/goicoechea.pdf', 3, 0xE1F20314, '2023-10-25', NULL, 20),
('Ruta escolar Hatillo', 'hatillo', 'http://maps.example.com/routes/hatillo.pdf', 4, 0xF2031425, '2023-10-25', NULL, 20),
('Ruta escolar Tibás', 'tibas', 'http://maps.example.com/routes/tibas.pdf', 5, 0x03142536, '2023-10-25', NULL, 20),
('Ruta escolar Moravia', 'moravia', 'http://maps.example.com/routes/moravia.pdf', 6, 0x14253647, '2023-10-25', NULL, 20);
SELECT * FROM vote_commitments


-- Inserción de compromisos (conteo de votos por opción)
INSERT INTO [dbo].[vote_commitments] ([value], [sum], [optionid])
VALUES 
-- Pregunta 1 (Aprobación Boulevard Cartago)
(1, 125, 1),  -- Sí
(1, 42, 2),    -- No
(1, 18, 3),    -- Abstención

-- Pregunta 2 (Mejoras prioritarias Boulevard)
(1, 98, 4),   -- Ampliación de carriles
(1, 75, 5),    -- Nuevas aceras
(1, 103, 6),  -- Ciclovía integrada
(1, 62, 7),    -- Mejor iluminación
(1, 87, 8),    -- Áreas verdes
(1, 45, 9),    -- Señalización inteligente

-- Pregunta 3 (Aprobación Planta Solar)
(1, 156, 10),  -- Sí, totalmente
(1, 72, 11),    -- Sí, con condiciones
(1, 38, 12),    -- No
(1, 24, 13),    -- No tengo info

-- Pregunta 4 (Impacto ambiental Planta Solar)
(1, 15, 14),   -- 1 - Mínimo
(1, 28, 15),   -- 2
(1, 76, 16),   -- 3 - Moderado
(1, 94, 17),   -- 4
(1, 67, 18),   -- 5 - Máximo

-- Pregunta 5 (Utilidad Plataforma AgriTech)
(1, 112, 19),  -- Muy útil
(1, 65, 20),   -- Útil con ajustes
(1, 23, 21),   -- No la usaría
(1, 30, 22),   -- No estoy seguro

-- Pregunta 6 (Funcionalidades AgriTech)
(1, 89, 23),   -- Monitoreo
(1, 76, 24),   -- Riego
(1, 94, 25),   -- Alertas plagas
(1, 68, 26),   -- Mercado
(1, 52, 27),   -- Asesoría
(1, 63, 28),   -- Clima

-- Pregunta 7 (Aprobación Bicicletas Públicas)
(1, 143, 29),  -- Totalmente necesario
(1, 58, 30),   -- Con condiciones
(1, 32, 31),   -- No prioritario
(1, 27, 32),   -- Me opongo

-- Pregunta 8 (Zonas para bicicletas)
(1, 112, 33),  -- Centro histórico
(1, 98, 34),   -- Zona universitaria
(1, 87, 35),   -- Parques
(1, 76, 36),   -- Estaciones de tren
(1, 65, 37),   -- Zonas residenciales
(1, 54, 38),   -- Centros comerciales

-- Pregunta 9 (Aprobación EcoBarrios)
(1, 132, 39),  -- Implementar ya
(1, 71, 40),   -- Con ajustes
(1, 35, 41),   -- Necesita rediseño
(1, 22, 42),   -- Me opongo

-- Pregunta 10 (Importancia componentes EcoBarrios)
(1, 18, 43),   -- 1 - Sin importancia
(1, 32, 44),   -- 2
(1, 75, 45),   -- 3 - Media
(1, 94, 46),   -- 4
(1, 101, 47),  -- 5 - Crítica

-- Pregunta 11 (Aprobación Remodelación Mercado)
(1, 128, 48),  -- Urgente
(1, 59, 49),   -- Por fases
(1, 43, 50),   -- Solo mantenimiento
(1, 30, 51),   -- Dejar como está

-- Pregunta 12 (Mejuras urgentes Mercado)
(1, 92, 52),  -- Sanitaria
(1, 84, 53),  -- Eléctrica
(1, 76, 54),  -- Accesibilidad
(1, 63, 55),  -- Nuevos vendedores
(1, 57, 56),  -- Carga/descarga

-- Pregunta 13 (Necesidad Plataforma "Mi Voz")
(1, 121, 57),  -- Muy necesaria
(1, 68, 58),   -- Con ajustes
(1, 42, 59),   -- Neutral
(1, 31, 60),   -- No prioridad
(1, 18, 61),   -- Me opongo

-- Pregunta 14 (Prioridad funcionalidades "Mi Voz")
(1, 102, 62),  -- Propuestas
(1, 98, 63),   -- Consultas
(1, 87, 64),   -- Seguimiento
(1, 76, 65),   -- Reporte problemas
(1, 65, 66),   -- Presupuesto
(1, 54, 67),   -- Foros

-- Pregunta 15 (Aprobación Rescate Tradiciones)
(1, 118, 68),  -- Totalmente
(1, 72, 69),   -- Enfoque moderno
(1, 45, 70),   -- No prioritario
(1, 25, 71),   -- Me opongo

-- Pregunta 16 (Tradiciones a preservar)
(1, 105, 72),  -- Música
(1, 98, 73),   -- Danzas
(1, 87, 74),   -- Artesanías
(1, 92, 75),   -- Gastronomía
(1, 76, 76),   -- Leyendas
(1, 65, 77),   -- Juegos

-- Pregunta 17 (Aprobación Techados Escolares)
(1, 142, 78),  -- Todas escuelas
(1, 68, 79),   -- Solo necesitadas
(1, 35, 80),   -- Otros proyectos
(1, 15, 81),   -- Me opongo

-- Pregunta 18 (Escuelas prioritarias)
(1, 98, 82),   -- San José
(1, 87, 83),   -- Alajuelita
(1, 76, 84),   -- Puriscal
(1, 65, 85),   -- Turrialba
(1, 72, 86),   -- Limón
(1, 58, 87),   -- Puntarenas

-- Pregunta 19 (Aprobación Rutas Seguras)
(1, 138, 88),  -- Implementar ya
(1, 62, 89),   -- Por fases
(1, 45, 90),   -- Solo iluminación
(1, 25, 91),   -- Me opongo

-- Pregunta 20 (Rutas peligrosas prioritarias)
(1, 105, 92),  -- San José Centro
(1, 98, 93),   -- Desamparados
(1, 87, 94),   -- Goicoechea
(1, 76, 95),   -- Hatillo
(1, 65, 96),   -- Tibás
(1, 72, 97);   -- Moravia

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
('INC01', 'Menos de ₡300,000', 6),
('INC02', '₡300,000 - ₡600,000', 6),
('INC03', '₡600,001 - ₡900,000', 6),
('INC04', '₡900,001 - ₡1,200,000', 6),
('INC05', 'Más de ₡1,200,000', 6),

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
(1, '₡900,001 - ₡1,200,000', 24, 101),
(1, 'Sin discapacidad', 26, 101),

-- Usuario 201 (representante organización)
(1, 'Femenino', 2, 201),
(1, '26-35 años', 2, 201),
(1, 'Guanacaste', 17, 201),
(1, 'Posgrado', 20, 201),
(1, 'Empresario', 22, 201),
(1, 'Más de ₡1,200,000', 25, 201),
(1, 'Sin discapacidad', 26, 201),

-- Usuario 301 (agricultor)
(1, 'Masculino', 1, 301),
(1, '46-55 años', 4, 301),
(1, 'Limón', 15, 301),
(1, 'Secundaria', 14, 301),
(1, 'Independiente', 23, 301),
(1, '₡300,000 - ₡600,000', 22, 301),
(1, 'Discapacidad física', 27, 301),

-- Continuar con otros usuarios...
-- Usuario 102 (planificador urbano)
(1, 'Femenino', 2, 102),
(1, '26-35 años', 2, 102),
(1, 'Heredia', 12, 102),
(1, 'Universitario', 16, 102),
(1, 'Empleado sector público', 18, 102),
(1, '₡600,001 - ₡900,000', 23, 102),
(1, 'Sin discapacidad', 26, 102),

-- Usuario 45 (ciudadano activo)
(1, 'No binario', 3, 45),
(1, '18-25 años', 1, 45),
(1, 'Alajuela', 13, 45),
(1, 'Técnico', 15, 45),
(1, 'Estudiante', 17, 45),
(1, 'Menos de ₡300,000', 21, 45),
(1, 'Discapacidad visual', 28, 45),

-- Usuario 104 (funcionario público)
(1, 'Masculino', 1, 104),
(1, '56-65 años', 5, 104),
(1, 'Cartago', 14, 104),
(1, 'Posgrado', 20, 104),
(1, 'Empleado sector público', 18, 104),
(1, 'Más de ₡1,200,000', 25, 104),
(1, 'Sin discapacidad', 26, 104),

-- Usuario 103 (arquitecto)
(1, 'Femenino', 2, 103),
(1, '36-45 años', 3, 103),
(1, 'Puntarenas', 16, 103),
(1, 'Universitario', 16, 103),
(1, 'Independiente', 23, 103),
(1, '₡900,001 - ₡1,200,000', 24, 103),
(1, 'Sin discapacidad', 26, 103),

-- Usuario 202 (gestor cultural)
(1, 'Femenino', 2, 202),
(1, '26-35 años', 2, 202),
(1, 'Guanacaste', 17, 202),
(1, 'Universitario', 16, 202),
(1, 'Empleado sector privado', 19, 202),
(1, '₡600,001 - ₡900,000', 23, 202),
(1, 'Sin discapacidad', 26, 202),

-- Usuario 46 (docente)
(1, 'Femenino', 2, 46),
(1, '46-55 años', 4, 46),
(1, 'Zona Sur', 18, 46),
(1, 'Posgrado', 20, 46),
(1, 'Empleado sector público', 18, 46),
(1, '₡600,001 - ₡900,000', 23, 46),
(1, 'Discapacidad auditiva', 29, 46),

-- Usuario 105 (ingeniero)
(1, 'Masculino', 1, 105),
(1, '36-45 años', 3, 105),
(1, 'San José Central', 11, 105),
(1, 'Universitario', 16, 105),
(1, 'Empleado sector privado', 19, 105),
(1, 'Más de ₡1,200,000', 25, 105),
(1, 'Sin discapacidad', 26, 105);


INSERT INTO [dbo].[vote_demographic_stats] ([sum], [value], [demographicid], [optionid])
VALUES 
-- Género para opción 1 (Sí a Boulevard Cartago)
(68, 'Masculino', 1, 1),
(52, 'Femenino', 2, 1),
(5, 'No binario', 3, 1),

-- Edades para opción 1
(25, '18-25 años', 5, 1),
(38, '26-35 años', 6, 1),
(32, '36-45 años', 7, 1),
(20, '46-55 años', 8, 1),
(10, '56-65 años', 9, 1),

-- Regiones para opción 1
(45, 'Cartago', 14, 1),  -- Mayor apoyo en Cartago (proyecto local)
(32, 'San José Central', 11, 1),
(18, 'Heredia', 12, 1),
(15, 'Alajuela', 13, 1),
(10, 'Otras regiones', 15, 1),

-- Educación para opción 1
(15, 'Primaria', 16, 1),
(28, 'Secundaria', 17, 1),
(42, 'Universitario', 19, 1),
(40, 'Posgrado', 20, 1),

-- Género para opción 2 (No a Boulevard Cartago)
(22, 'Masculino', 1, 2),
(18, 'Femenino', 2, 2),
(2, 'No binario', 3, 2),

-- Edades para opción 6 (Ciclovía integrada)
(35, '18-25 años', 5, 6),
(42, '26-35 años', 6, 6),  -- Mayor apoyo en jóvenes
(18, '36-45 años', 7, 6),
(8, '46-55 años', 8, 6),

-- Ingresos para opción 10 (Sí total a Planta Solar)
(12, 'Menos de ₡300,000', 21, 10),
(28, '₡300,000 - ₡600,000', 22, 10),
(35, '₡600,001 - ₡900,000', 23, 10),
(42, '₡900,001 - ₡1,200,000', 24, 10),
(39, 'Más de ₡1,200,000', 25, 10),

-- Discapacidad para opción 19 (Sí a AgriTech)
(5, 'Discapacidad física', 27, 19),
(3, 'Discapacidad visual', 28, 19),
(2, 'Discapacidad auditiva', 29, 19),
(102, 'Sin discapacidad', 26, 19),

-- Ocupación para opción 29 (Sí a Bicicletas Públicas)
(42, 'Estudiante', 17, 29),
(38, 'Empleado sector público', 18, 29),
(35, 'Empleado sector privado', 19, 29),
(18, 'Independiente', 23, 29),
(10, 'Jubilado', 24, 29),

-- Región para opción 48 (Urgente remodelación mercado)
(65, 'Heredia', 12, 48),  -- Mayor apoyo en región afectada
(28, 'San José Central', 11, 48),
(15, 'Alajuela', 13, 48),
(12, 'Cartago', 14, 48),
(8, 'Otras regiones', 15, 48),

-- Educación para opción 78 (Techados todas escuelas)
(25, 'Primaria', 16, 78),
(38, 'Secundaria', 17, 78),
(42, 'Universitario', 19, 78),
(37, 'Posgrado', 20, 78),

-- Género para opción 88 (Sí a Rutas Seguras)
(72, 'Femenino', 2, 88),  -- Mayor apoyo femenino
(66, 'Masculino', 1, 88),
(0, 'No binario', 3, 88);

-- Sectores económicos
INSERT INTO [dbo].[cf_sectors] ([name])
VALUES 
('Construcción e Infraestructura'),
('Energía y Sostenibilidad'),
('Tecnología e Innovación'),
('Educación y Cultura'),
('Salud y Bienestar'),
('Transporte y Movilidad'),
('Medio Ambiente'),
('Desarrollo Comunitario'),
('Agricultura y Alimentos'),
('Turismo');

-- Tipos de estado
INSERT INTO [dbo].[cf_status_types] ([name], [module])
VALUES 
('Borrador', 'projects'),
('En Revisión', 'projects'),
('Aprobado', 'projects'),
('Rechazado', 'projects'),
('En Recaudación', 'projects'),
('Financiado', 'projects'),
('En Ejecución', 'projects'),
('Completado', 'projects'),
('Suspendido', 'projects'),
('Cancelado', 'projects');

-- Tipos de proyecto
INSERT INTO [dbo].[cf_project_types] ([name])
VALUES 
('Infraestructura Pública'),
('Energías Renovables'),
('Innovación Tecnológica'),
('Programa Social'),
('Equipamiento Comunitario'),
('Investigación y Desarrollo'),
('Cultura y Arte'),
('Movilidad Urbana'),
('Conservación Ambiental'),
('Desarrollo Turístico');

INSERT INTO cf_projects (
  budget, equity_offered, sectorid, startdate, statusid, 
  total_invested, proposalid, projecttypeid, min_funding_target, max_funding_target, name
) VALUES (
  18500000.00, -- 18.5 millones de dólares
  10.00, -- 10% de equity
  (SELECT sectorid FROM cf_sectors WHERE name = 'Construcción e Infraestructura'),
  '2024-06-01', 
  (SELECT statusid FROM cf_status_types WHERE name = 'Aprobado'),
  0.00,
  1, -- Asumiendo propuesta ID 1
  (SELECT pjtypeid FROM cf_project_types WHERE name = 'Infraestructura Pública'),
  5000000.00, -- Mínimo 5 millones
  15000000.00, -- Meta 15 millones
  'Expanción Boulevard Cartago'
);

INSERT INTO cf_projects (
  budget, equity_offered, sectorid, startdate, statusid, 
  total_invested, proposalid, projecttypeid, min_funding_target, max_funding_target, name
) VALUES (
  3200000.00, -- 3.2 millones
  25.00, -- 25% equity
  (SELECT sectorid FROM cf_sectors WHERE name = 'Energía y Sostenibilidad'),
  '2024-07-15',
  (SELECT statusid FROM cf_status_types WHERE name = 'En Recaudación'),
  1250000.00, -- Ya recaudó 1.25 millones
  2,
  (SELECT pjtypeid FROM cf_project_types WHERE name = 'Energías Renovables'),
  2000000.00, -- Mínimo 2 millones
  3000000.00, -- Meta 3 millones
  'Planta Solar en Guanacaste'
);

INSERT INTO cf_projects (
  budget, equity_offered, sectorid, startdate, statusid, 
  total_invested, proposalid, projecttypeid, min_funding_target, max_funding_target, name
) VALUES (
  500000.00, -- 500 mil dólares
  30.00, -- 30% equity
  (SELECT sectorid FROM cf_sectors WHERE name = 'Tecnología e Innovación'),
  '2024-05-20',
  (SELECT statusid FROM cf_status_types WHERE name = 'En Ejecución'),
  500000.00, -- Completamente financiado
  3,
  (SELECT pjtypeid FROM cf_project_types WHERE name = 'Innovación Tecnológica'),
  300000.00, -- Mínimo 300 mil
  500000.00, -- Meta 500 mil
  'Plataforma de Agricultura Digital'
);


-- Proyecto 4: Sistema de Bicicletas Públicas (propuesta 4)
INSERT INTO [dbo].[cf_projects] (
    [budget], [equity_offered], [sectorid], [startdate], [statusid],
    [total_invested], [proposalid], [projecttypeid], [min_funding_target], [max_funding_target], [name]
)
VALUES (
    4200000.00, -- 4.2 millones
    15.00, -- 15% equity
    (SELECT sectorid FROM [dbo].[cf_sectors] WHERE name = 'Transporte y Movilidad'),
    '2024-08-10',
    (SELECT statusid FROM [dbo].[cf_status_types] WHERE name = 'En Recaudación'),
    1850000.00, -- 1.85 millones recaudados
    4,
    (SELECT pjtypeid FROM [dbo].[cf_project_types] WHERE name = 'Movilidad Urbana'),
    2500000.00, -- Mínimo 2.5 millones
    4000000.00, -- Meta 4 millones
    'Sistema de Bicicletas Públicas SJ'
);

-- Proyecto 5: Programa EcoBarrios (propuesta 5)
INSERT INTO [dbo].[cf_projects] (
    [budget], [equity_offered], [sectorid], [startdate], [statusid],
    [total_invested], [proposalid], [projecttypeid], [min_funding_target], [max_funding_target], [name]
)
VALUES (
    1200000.00, -- 1.2 millones
    0.00, -- 0% equity (proyecto social)
    (SELECT sectorid FROM [dbo].[cf_sectors] WHERE name = 'Medio Ambiente'),
    '2024-09-01',
    (SELECT statusid FROM [dbo].[cf_status_types] WHERE name = 'Aprobado'),
    0.00,
    5,
    (SELECT pjtypeid FROM [dbo].[cf_project_types] WHERE name = 'Programa Social'),
    800000.00, -- Mínimo 800k
    1200000.00, -- Meta 1.2 millones
    'EcoBarrios: Reciclaje Comunitario'
);

-- Proyecto 6: Remodelación Mercado Central (propuesta 6)
INSERT INTO [dbo].[cf_projects] (
    [budget], [equity_offered], [sectorid], [startdate], [statusid],
    [total_invested], [proposalid], [projecttypeid], [min_funding_target], [max_funding_target], [name]
)
VALUES (
    5800000.00, -- 5.8 millones
    20.00, -- 20% equity
    (SELECT sectorid FROM [dbo].[cf_sectors] WHERE name = 'Construcción e Infraestructura'),
    '2024-10-15',
    (SELECT statusid FROM [dbo].[cf_status_types] WHERE name = 'En Revisión'),
    0.00,
    6,
    (SELECT pjtypeid FROM [dbo].[cf_project_types] WHERE name = 'Infraestructura Pública'),
    3000000.00, -- Mínimo 3 millones
    5500000.00, -- Meta 5.5 millones
    'Remodelación Mercado Heredia'
);

-- Proyecto 7: Plataforma "Mi Voz" (propuesta 7)
INSERT INTO [dbo].[cf_projects] (
    [budget], [equity_offered], [sectorid], [startdate], [statusid],
    [total_invested], [proposalid], [projecttypeid], [min_funding_target], [max_funding_target], [name]
)
VALUES (
    750000.00, -- 750k
    25.00, -- 25% equity
    (SELECT sectorid FROM [dbo].[cf_sectors] WHERE name = 'Tecnología e Innovación'),
    '2024-07-20',
    (SELECT statusid FROM [dbo].[cf_status_types] WHERE name = 'En Recaudación'),
    320000.00, -- 320k recaudados
    7,
    (SELECT pjtypeid FROM [dbo].[cf_project_types] WHERE name = 'Innovación Tecnológica'),
    500000.00, -- Mínimo 500k
    750000.00, -- Meta 750k
    'Plataforma Digital "Mi Voz"'
);

-- Proyecto 8: Rescate Tradiciones (propuesta 8)
INSERT INTO [dbo].[cf_projects] (
    [budget], [equity_offered], [sectorid], [startdate], [statusid],
    [total_invested], [proposalid], [projecttypeid], [min_funding_target], [max_funding_target], [name]
)
VALUES (
    950000.00, -- 950k
    10.00, -- 10% equity
    (SELECT sectorid FROM [dbo].[cf_sectors] WHERE name = 'Educación y Cultura'),
    '2024-08-05',
    (SELECT statusid FROM [dbo].[cf_status_types] WHERE name = 'Financiado'),
    950000.00, -- Totalmente financiado
    8,
    (SELECT pjtypeid FROM [dbo].[cf_project_types] WHERE name = 'Cultura y Arte'),
    600000.00, -- Mínimo 600k
    900000.00, -- Meta 900k
    'Rescate Tradiciones Guanacastecas'
);

-- Proyecto 9: Techados Escolares (propuesta 9)
INSERT INTO [dbo].[cf_projects] (
    [budget], [equity_offered], [sectorid], [startdate], [statusid],
    [total_invested], [proposalid], [projecttypeid], [min_funding_target], [max_funding_target], [name]
)
VALUES (
    2800000.00, -- 2.8 millones
    0.00, -- 0% equity (proyecto social)
    (SELECT sectorid FROM [dbo].[cf_sectors] WHERE name = 'Educación y Cultura'),
    '2024-09-10',
    (SELECT statusid FROM [dbo].[cf_status_types] WHERE name = 'En Ejecución'),
    2800000.00, -- Totalmente financiado
    9,
    (SELECT pjtypeid FROM [dbo].[cf_project_types] WHERE name = 'Equipamiento Comunitario'),
    2000000.00, -- Mínimo 2 millones
    2800000.00, -- Meta 2.8 millones
    'Techados para Escuelas Públicas'
);

-- Proyecto 10: Rutas Seguras (propuesta 10)
INSERT INTO [dbo].[cf_projects] (
    [budget], [equity_offered], [sectorid], [startdate], [statusid],
    [total_invested], [proposalid], [projecttypeid], [min_funding_target], [max_funding_target], [name]
)
VALUES (
    3200000.00, -- 3.2 millones
    15.00, -- 15% equity
    (SELECT sectorid FROM [dbo].[cf_sectors] WHERE name = 'Transporte y Movilidad'),
    '2024-07-01',
    (SELECT statusid FROM [dbo].[cf_status_types] WHERE name = 'Completado'),
    3200000.00, -- Totalmente financiado
    10,
    (SELECT pjtypeid FROM [dbo].[cf_project_types] WHERE name = 'Movilidad Urbana'),
    2500000.00, -- Mínimo 2.5 millones
    3200000.00, -- Meta 3.2 millones
    'Rutas Seguras: Iluminación y Cámaras'
);

-- Tabla de estados de pago
INSERT INTO [dbo].[vpv_paymentstatus] ([name])
VALUES 
('Pending'),
('Completed'),
('Failed'),
('Refunded'),
('Cancelled');

-- Tabla de proveedores de API
INSERT INTO [dbo].[api_providers] ([brand_name], [legal_name], [legal_identification], [enabled])
VALUES 
('PayTech', 'PayTech Solutions Inc.', '123456789', 1),
('SecurePay', 'Secure Payment Systems LLC', '987654321', 1),
('GlobalPay', 'Global Payment Technologies', '456789123', 1);

-- Tabla de integraciones API
INSERT INTO [dbo].[api_integrations] ([name], [public_key], [private_key], [url], [creation_date], [last_update], [enabled], [idProvider])
VALUES 
('PayTech Standard', 0x010203, 0x040506, 'https://api.paytech.com/v1', GETDATE(), GETDATE(), 1, 1),
('SecurePay Pro', 0x070809, 0x0A0B0C, 'https://api.securepay.com/v2', GETDATE(), GETDATE(), 1, 2),
('GlobalPay Enterprise', 0x0D0E0F, 0x101112, 'https://api.globalpay.com/enterprise', GETDATE(), GETDATE(), 1, 3);

-- Tabla de métodos de pago
INSERT INTO [dbo].[vpv_pay_methods] ([name], [secret_key], [logo_icon_url], [enabled], [idApiIntegration])
VALUES 
('Credit Card', 0x131415, 'https://example.com/cc.png', 1, 1),
('Bank Transfer', 0x161718, 'https://example.com/bank.png', 1, 2),
('PayPal', 0x192021, 'https://example.com/paypal.png', 1, 3),
('Crypto', 0x222324, 'https://example.com/crypto.png', 1, 1);

-- Tabla de métodos de pago disponibles
INSERT INTO [dbo].[vpv_available_pay_methods] ([name], [token], [exp_token], [mask_account], [idMethod])
VALUES 
('Visa ending 4242', 'tok_visa_123', '2025-12-31', '************4242', 1),
('Mastercard ending 5555', 'tok_mc_456', '2024-10-31', '************5555', 1),
('Bank Transfer Ref', 'tok_bank_789', '2099-12-31', 'CRXXXXX123456', 2),
('PayPal Account', 'tok_pp_101', '2099-12-31', 'user@example.com', 3);

-- Insertar 10 registros de pagos manuales
INSERT INTO [dbo].[vpv_payments] (
    [amount], [taxamount], [discountporcent], [realamount], [result], 
    [authcode], [referencenumber], [chargetoken], [date], [checksum], 
    [statusid], [paymentmethodid], [availablemethodid]
)
VALUES
-- Pago 1
(5000.00, 650.00, 0.00, 5000.00, 'Success', 'AUTH12345', 'REF10001', 0x010203, '2024-01-15 10:30:00', 0x010203, 2, 1, 1),
-- Pago 2
(12000.00, 1560.00, 5.00, 11400.00, 'Success', 'AUTH12346', 'REF10002', 0x040506, '2024-02-20 14:45:00', 0x040506, 2, 1, 2),
-- Pago 3
(7500.00, 975.00, 2.50, 7312.50, 'Success', 'AUTH12347', 'REF10003', 0x070809, '2024-03-05 09:15:00', 0x070809, 2, 2, 3),
-- Pago 4
(3000.00, 390.00, 0.00, 3000.00, 'Failed', 'AUTH12348', 'REF10004', 0x101112, '2024-03-18 16:20:00', 0x101112, 3, 1, 1),
-- Pago 5
(8500.00, 1105.00, 10.00, 7650.00, 'Success', 'AUTH12349', 'REF10005', 0x131415, '2024-04-10 11:10:00', 0x131415, 2, 3, 4),
-- Pago 6
(20000.00, 2600.00, 0.00, 20000.00, 'Success', 'AUTH12350', 'REF10006', 0x161718, '2024-05-22 13:25:00', 0x161718, 2, 1, 2),
-- Pago 7
(4500.00, 585.00, 7.50, 4162.50, 'Success', 'AUTH12351', 'REF10007', 0x192021, '2024-06-03 15:40:00', 0x192021, 2, 4, 1),
-- Pago 8
(6000.00, 780.00, 0.00, 6000.00, 'Pending', 'AUTH12352', 'REF10008', 0x222324, '2024-06-12 10:00:00', 0x222324, 1, 2, 3),
-- Pago 9
(9800.00, 1274.00, 3.00, 9506.00, 'Success', 'AUTH12353', 'REF10009', 0x252627, '2024-06-20 14:15:00', 0x252627, 2, 1, 1),
-- Pago 10
(15000.00, 1950.00, 0.00, 15000.00, 'Refunded', 'AUTH12354', 'REF10010', 0x282930, '2024-06-25 17:30:00', 0x282930, 4, 1, 2);

-- Insertar 20 registros de inversiones manuales
INSERT INTO [dbo].[cf_investments] (
    [amount], [investmentdate], [equity_obtained], [statusid], 
    [investment_hash], [projectid], [paymentid], [userid]
)
VALUES
-- Inversión 1 (Proyecto 1 - Expansión Boulevard Cartago)
(25000.00, '2024-01-10 09:00:00', 1.25, 1, 0x010101, 1, 1, 45),
-- Inversión 2 (Proyecto 2 - Planta Solar Guanacaste)
(15000.00, '2024-01-15 14:30:00', 0.75, 1, 0x020202, 2, 2, 128),
-- Inversión 3 (Proyecto 3 - Plataforma Agricultura Digital)
(5000.00, '2024-02-05 11:20:00', 1.50, 1, 0x030303, 3, 3, 342),
-- Inversión 4 (Proyecto 4 - Bicicletas Públicas SJ)
(18000.00, '2024-02-18 16:45:00', 0.90, 1, 0x040404, 4, 4, 756),
-- Inversión 5 (Proyecto 5 - EcoBarrios)
(8000.00, '2024-03-02 10:15:00', 0.00, 1, 0x050505, 5, 5, 23),
-- Inversión 6 (Proyecto 6 - Remodelación Mercado Heredia)
(30000.00, '2024-03-12 13:50:00', 1.50, 2, 0x060606, 6, NULL, 912),
-- Inversión 7 (Proyecto 7 - Plataforma "Mi Voz")
(7500.00, '2024-04-01 15:30:00', 2.25, 1, 0x070707, 7, 6, 567),
-- Inversión 8 (Proyecto 8 - Rescate Tradiciones)
(12000.00, '2024-04-15 09:45:00', 1.20, 1, 0x080808, 8, 7, 234),
-- Inversión 9 (Proyecto 9 - Techados Escolares)
(20000.00, '2024-05-03 14:20:00', 0.00, 1, 0x090909, 9, 8, 789),
-- Inversión 10 (Proyecto 10 - Rutas Seguras)
(25000.00, '2024-05-18 11:10:00', 1.25, 1, 0x101010, 10, 9, 123),
-- Inversión 11 (Proyecto 1 - Expansión Boulevard Cartago)
(35000.00, '2024-06-02 16:30:00', 1.75, 1, 0x111111, 1, 10, 456),
-- Inversión 12 (Proyecto 2 - Planta Solar Guanacaste)
(10000.00, '2024-06-10 10:40:00', 0.50, 1, 0x121212, 2, NULL, 678),
-- Inversión 13 (Proyecto 3 - Plataforma Agricultura Digital)
(8000.00, '2024-06-15 13:25:00', 2.40, 1, 0x131313, 3, NULL, 345),
-- Inversión 14 (Proyecto 4 - Bicicletas Públicas SJ)
(22000.00, '2024-06-18 15:50:00', 1.10, 3, 0x141414, 4, NULL, 901),
-- Inversión 15 (Proyecto 5 - EcoBarrios)
(5000.00, '2024-06-20 09:30:00', 0.00, 1, 0x151515, 5, NULL, 102),
-- Inversión 16 (Proyecto 6 - Remodelación Mercado Heredia)
(28000.00, '2024-06-22 14:15:00', 1.40, 2, 0x161616, 6, NULL, 543),
-- Inversión 17 (Proyecto 7 - Plataforma "Mi Voz")
(6500.00, '2024-06-24 11:45:00', 1.95, 1, 0x171717, 7, NULL, 876),
-- Inversión 18 (Proyecto 8 - Rescate Tradiciones)
(9500.00, '2024-06-26 16:20:00', 0.95, 1, 0x181818, 8, NULL, 210),
-- Inversión 19 (Proyecto 9 - Techados Escolares)
(15000.00, '2024-06-28 10:10:00', 0.00, 1, 0x191919, 9, NULL, 654),
-- Inversión 20 (Proyecto 10 - Rutas Seguras)
(18000.00, '2024-06-30 13:35:00', 0.90, 1, 0x202020, 10, NULL, 987);

SELECT * FROM cf_projects_milestones
-- Hitos para Proyecto 1: Expansión Boulevard Cartago
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Aprobación municipal', 'Obtención de permisos de construcción', '2024-01-15', '2024-01-10', 10.00, 3, 1, 1, 1),
('Preparación terreno', 'Movimiento de tierras y nivelación', '2024-03-01', '2024-02-25', 15.00, 3, 1, 1, 2),
('Cimentación', 'Construcción de bases y cimientos', '2024-05-15', NULL, 20.00, 2, 1, 1, NULL),
('Estructuras', 'Erección de estructuras principales', '2024-08-01', NULL, 25.00, 1, 1, 1, NULL),
('Pavimentación', 'Colocación de capa asfáltica', '2024-10-15', NULL, 20.00, 1, 1, 1, NULL),
('Finalización', 'Entrega completa del proyecto', '2024-12-10', NULL, 10.00, 1, 1, 1, NULL);

-- Hitos para Proyecto 2: Planta Solar Guanacaste
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Estudios técnicos', 'Análisis de suelo y radiación', '2024-02-01', '2024-01-28', 10.00, 3, 1, 2, 3),
('Adquisición terreno', 'Compra y preparación del terreno', '2024-03-15', '2024-03-10', 15.00, 3, 1, 2, 4),
('Instalación paneles', 'Colocación de paneles solares', '2024-06-01', NULL, 30.00, 2, 1, 2, NULL),
('Infraestructura eléctrica', 'Instalación de inversores y conexiones', '2024-08-15', NULL, 25.00, 1, 1, 2, NULL),
('Pruebas operativas', 'Pruebas de generación eléctrica', '2024-09-30', NULL, 15.00, 1, 1, 2, NULL),
('Conexión a red', 'Interconexión con sistema nacional', '2024-10-15', NULL, 5.00, 1, 1, 2, NULL);

-- Hitos para Proyecto 3: Plataforma Agricultura Digital
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Diseño plataforma', 'Diseño UI/UX de la aplicación', '2024-02-01', '2024-01-28', 15.00, 3, 0, 3, NULL),
('Desarrollo backend', 'Implementación de lógica principal', '2024-04-01', '2024-03-28', 30.00, 3, 0, 3, NULL),
('Desarrollo frontend', 'Interfaz de usuario', '2024-05-15', NULL, 25.00, 2, 0, 3, NULL),
('Pruebas beta', 'Pruebas con usuarios piloto', '2024-06-30', NULL, 20.00, 1, 0, 3, NULL),
('Lanzamiento oficial', 'Disponible para público general', '2024-07-15', NULL, 10.00, 1, 0, 3, NULL);

-- Hitos para Proyecto 4: Sistema de Bicicletas Públicas SJ
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Adquisición bicicletas', 'Compra de unidades y sistemas', '2024-05-01', NULL, 25.00, 2, 1, 4, 5),
('Instalación estaciones', 'Colocación de módulos de préstamo', '2024-07-15', NULL, 30.00, 1, 1, 4, NULL),
('Desarrollo software', 'Sistema de gestión y app móvil', '2024-08-01', NULL, 20.00, 1, 1, 4, NULL),
('Pruebas sistema', 'Fase de pruebas con usuarios', '2024-09-15', NULL, 15.00, 1, 1, 4, NULL),
('Lanzamiento piloto', 'Implementación en zona 1', '2024-10-01', NULL, 10.00, 1, 1, 4, NULL);

-- Hitos para Proyecto 5: EcoBarrios
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Capacitación inicial', 'Talleres de reciclaje', '2024-06-01', NULL, 20.00, 2, 0, 5, NULL),
('Entrega contenedores', 'Distribución de recipientes', '2024-07-15', NULL, 30.00, 1, 0, 5, NULL),
('Primer reporte', 'Medición resultados iniciales', '2024-09-01', NULL, 20.00, 1, 0, 5, NULL),
('Ampliación cobertura', 'Inclusión nuevas comunidades', '2024-10-15', NULL, 20.00, 1, 0, 5, NULL),
('Evaluación final', 'Reporte de resultados finales', '2024-12-01', NULL, 10.00, 1, 0, 5, NULL);

-- Hitos para Proyecto 6: Remodelación Mercado Heredia
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Estudios arquitectónicos', 'Diseño y planos finales', '2024-04-01', NULL, 15.00, 2, 1, 6, 6),
('Demolición parcial', 'Remoción de estructuras antiguas', '2024-06-15', NULL, 20.00, 1, 1, 6, NULL),
('Construcción nueva', 'Erección de nuevas estructuras', '2024-09-01', NULL, 30.00, 1, 1, 6, NULL),
('Acabados', 'Instalación de pisos y techos', '2024-11-15', NULL, 25.00, 1, 1, 6, NULL),
('Inauguración', 'Apertura al público', '2025-01-10', NULL, 10.00, 1, 1, 6, NULL);

-- Hitos para Proyecto 7: Plataforma "Mi Voz"
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Investigación', 'Estudio de necesidades', '2024-03-01', '2024-02-25', 10.00, 3, 0, 7, NULL),
('Diseño plataforma', 'Arquitectura y UI/UX', '2024-04-15', '2024-04-10', 20.00, 3, 0, 7, NULL),
('Desarrollo', 'Implementación funcional', '2024-06-01', NULL, 40.00, 2, 0, 7, NULL),
('Pruebas', 'Control de calidad', '2024-07-15', NULL, 20.00, 1, 0, 7, NULL),
('Lanzamiento', 'Implementación producción', '2024-08-01', NULL, 10.00, 1, 0, 7, NULL);

-- Hitos para Proyecto 8: Rescate Tradiciones
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Investigación', 'Recopilación de tradiciones', '2024-05-01', '2024-04-28', 15.00, 3, 0, 8, 7),
('Documentación', 'Registro audiovisual', '2024-06-15', NULL, 25.00, 2, 0, 8, NULL),
('Talleres', 'Capacitación comunidades', '2024-08-01', NULL, 30.00, 1, 0, 8, NULL),
('Publicación', 'Material educativo', '2024-09-15', NULL, 20.00, 1, 0, 8, NULL),
('Evento cierre', 'Presentación resultados', '2024-10-30', NULL, 10.00, 1, 0, 8, NULL);

-- Hitos para Proyecto 9: Techados Escolares
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Selección escuelas', 'Priorización de centros educativos', '2024-06-01', '2024-05-28', 10.00, 3, 0, 9, 8),
('Diseños técnicos', 'Planos y especificaciones', '2024-07-15', NULL, 15.00, 2, 0, 9, NULL),
('Construcción 50%', 'Primera fase de construcción', '2024-09-01', NULL, 30.00, 1, 0, 9, NULL),
('Construcción 100%', 'Finalización de obras', '2024-11-15', NULL, 35.00, 1, 0, 9, NULL),
('Entrega oficial', 'Inauguración de techados', '2024-12-10', NULL, 10.00, 1, 0, 9, NULL);

-- Hitos para Proyecto 10: Rutas Seguras
INSERT INTO [dbo].[cf_projects_milestones] ([name], [description], [target_date], [completion_date], [disbursement_porcentage], [statusid], [validation_required], [projectid], [vote_sessionid])
VALUES
('Estudio rutas', 'Identificación puntos críticos', '2024-04-01', '2024-03-28', 10.00, 3, 1, 10, 9),
('Instalación luminarias', 'Colocación de alumbrado', '2024-05-15', '2024-05-10', 30.00, 3, 1, 10, 10),
('Cámaras seguridad', 'Instalación sistema vigilancia', '2024-07-01', NULL, 30.00, 2, 1, 10, NULL),
('Señalización', 'Colocación de señales viales', '2024-08-15', NULL, 20.00, 1, 1, 10, NULL),
('Inauguración', 'Puesta en marcha oficial', '2024-09-01', NULL, 10.00, 1, 1, 10, NULL);

-- Desembolsos para Proyecto 1
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(1850000.00, '2024-01-05', '2024-01-10', 3, 1, 1, 100, 1), -- 10% de 18.5M
(2775000.00, '2024-02-20', '2024-02-25', 3, 1, 2, 100, 2), -- 15% de 18.5M
(3700000.00, '2024-05-01', NULL, 2, 1, 3, NULL, NULL); -- 20% de 18.5M

-- Desembolsos para Proyecto 2
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(320000.00, '2024-01-25', '2024-01-30', 3, 2, 6, 101, 3), -- 10% de 3.2M
(480000.00, '2024-03-10', '2024-03-15', 3, 2, 7, 101, 4), -- 15% de 3.2M
(960000.00, '2024-05-20', NULL, 1, 2, 8, NULL, NULL); -- 30% de 3.2M

-- Desembolsos para Proyecto 3
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(75000.00, '2024-01-20', '2024-01-25', 3, 3, 10, 102, 5), -- 15% de 500k
(150000.00, '2024-03-25', '2024-03-30', 3, 3, 11, 102, 6), -- 30% de 500k
(125000.00, '2024-05-20', NULL, 2, 3, 12, NULL, NULL); -- 25% de 500k

-- Desembolsos para Proyecto 4
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(1050000.00, '2024-04-20', '2024-04-25', 3, 4, 16, 103, 7), -- 25% de 4.2M
(1260000.00, '2024-07-01', NULL, 1, 4, 17, NULL, NULL); -- 30% de 4.2M

-- Desembolsos para Proyecto 5
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(240000.00, '2024-05-25', '2024-05-30', 3, 5, 21, 104, 8), -- 20% de 1.2M
(360000.00, '2024-07-10', NULL, 2, 5, 22, NULL, NULL); -- 30% de 1.2M

-- Desembolsos para Proyecto 6
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(870000.00, '2024-03-25', '2024-03-30', 3, 6, 26, 105, 9), -- 15% de 5.8M
(1160000.00, '2024-06-10', NULL, 1, 6, 27, NULL, NULL); -- 20% de 5.8M

-- Desembolsos para Proyecto 7
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(75000.00, '2024-02-25', '2024-03-01', 3, 7, 31, 106, 10), -- 10% de 750k
(150000.00, '2024-04-10', '2024-04-15', 3, 7, 32, 106, 1), -- 20% de 750k
(300000.00, '2024-05-25', NULL, 2, 7, 33, NULL, NULL); -- 40% de 750k

-- Desembolsos para Proyecto 8
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(142500.00, '2024-04-25', '2024-04-30', 3, 8, 36, 107, 2), -- 15% de 950k
(237500.00, '2024-06-10', NULL, 1, 8, 37, NULL, NULL); -- 25% de 950k

-- Desembolsos para Proyecto 9
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(280000.00, '2024-05-25', '2024-05-30', 3, 9, 41, 108, 3), -- 10% de 2.8M
(420000.00, '2024-07-01', NULL, 2, 9, 42, NULL, NULL); -- 15% de 2.8M

-- Desembolsos para Proyecto 10
INSERT INTO [dbo].[cf_project_disbursements] ([amount], [request_date], [approval_date], [statusid], [projectid], [milestoneid], [approved_by], [paymentid])
VALUES
(320000.00, '2024-03-25', '2024-03-30', 3, 10, 46, 109, 4), -- 10% de 3.2M
(960000.00, '2024-05-10', '2024-05-15', 3, 10, 47, 109, 5), -- 30% de 3.2M
(640000.00, '2024-07-01', NULL, 1, 10, 48, NULL, NULL); -- 20% de 3.2M


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
('Borrador', 'Propuesta en fase de elaboración', 1),
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

INSERT INTO [vpv_validation_types] ([name], [description], [enabled])
VALUES
('Validación Automática', 'Validación realizada por sistema automatizado', 1),
('Revisión Técnica', 'Revisión por equipo técnico especializado', 1),
('Aprobación Legal', 'Revisión y aprobación por departamento legal', 1),
('Verificación Financiera', 'Análisis de viabilidad financiera', 1),
('Validación de propuesta', 'Validación de los documentos digitales asociados a una propuesta', 1),
('Validación de comentario', 'Validación de los documentos digitales adjuntados en un comentario', 1);

INSERT INTO [vpv_validation_request] ([creation_date], [finish_date], [global_result], [userid], [validation_typeid])
VALUES
('2024-01-15', '2024-02-10', 'Aprobado con observaciones menores', 101, 2),
('2024-01-20', '2024-02-05', 'Aprobado', 102, 4),
('2024-03-01', '2024-03-25', 'Aprobado', 103, 2),
('2024-03-05', '2024-03-30', 'Rechazado - Requiere revisión', 104, 4),
('2024-04-10', '2024-04-28', 'Aprobado', 105, 2),
('2024-04-12', NULL, 'En proceso', 106, 4);

INSERT INTO [vpv_section_type] ([name], [description], [enabled])
VALUES
('Encabezado', 'Sección inicial del documento', 1),
('Cuerpo Principal', 'Contenido principal del documento', 1),
('Anexos', 'Documentos adjuntos o complementarios', 1),
('Firmas', 'Sección para firmas y aprobaciones', 1),
('Metadatos', 'Información técnica sobre el documento', 1);

INSERT INTO [vpv_document_type] ([name], [description], [enabled])
VALUES
('Estudio de Factibilidad', 'Documento técnico que analiza la viabilidad del proyecto', 1),
('Plan Financiero', 'Presupuesto y proyecciones económicas del proyecto', 1),
('Permisos Legales', 'Documentación de permisos y autorizaciones requeridas', 1),
('Plan de Ejecución', 'Cronograma y metodología de implementación', 1),
('Impacto Ambiental', 'Evaluación de impacto ambiental del proyecto', 1),
('Contrato de Inversión', 'Acuerdos con los inversionistas', 1);

-- Secciones de documentos
INSERT INTO [vpv_document_sections] ([required], [order_index], [rules], [section_typeid], [document_typeid], [parent_sectionid])
VALUES
(1, 1, '{"min_length": 500, "max_length": 5000}', 1, 1, NULL),
(1, 2, '{"required_fields": ["objetivos", "metodologia"]}', 2, 1, 1),
(0, 3, '{"max_attachments": 5}', 3, 1, NULL),
(1, 1, '{"requires_charts": true}', 1, 2, NULL),
(1, 2, '{"required_fields": ["presupuesto", "flujo_caja"]}', 2, 2, 4),
(1, 1, '{"requires_official_seal": true}', 1, 3, NULL),
(1, 2, '{"required_signatures": 2}', 4, 3, NULL);

-- Documentos digitales
INSERT INTO [vpv_digital_documents] ([name], [url], [hash], [metadata], [validation_date], [requestid], [document_typeid])
VALUES
('Estudio_Factibilidad_Boulevard.pdf', 'https://docs.example.com/p1/estudio.pdf', 'a1b2c3d4e5', '{"pages": 45, "author": "Ing. Carlos Rojas"}', '2024-02-05', 1, 1),
('Presupuesto_Boulevard.xlsx', 'https://docs.example.com/p1/presupuesto.xlsx', 'f6g7h8i9j0', '{"sheets": 3, "formulas_verified": true}', '2024-02-08', 2, 2),

('Permisos_Ambientales_Planta.pdf', 'https://docs.example.com/p2/permisos.pdf', 'k1l2m3n4o5', '{"expiration": "2026-12-31", "entity": "MINAE"}', '2024-03-20', 3, 3),
('Modelo_Financiero_Planta.xlsx', 'https://docs.example.com/p2/modelo.xlsx', 'p6q7r8s9t0', '{"scenarios": 5, "version": 2.1}', NULL, 4, 2),

('Plan_Ejecucion_Agricultura.pdf', 'https://docs.example.com/p3/plan.pdf', 'u1v2w3x4y5', '{"timeline": "12 meses", "team": 8}', '2024-04-25', 5, 4),
('Contrato_Inversion_Agricultura.docx', 'https://docs.example.com/p3/contrato.docx', 'z6a7b8c9d0', '{"parties": 3, "clauses": 15}', NULL, 6, 6);

-- Insert validation workflows
INSERT INTO [vpv_validation_workflow] ([workflowid], [workflow_name], [description], [parameter], [schedule_interval], [url], [enabled])
VALUES
(1, 'Flujo Básico', 'Validación estándar para documentos simples', '{"max_pages": 50, "allowed_formats": ["pdf", "docx"]}', '7d', '/api/validation/basic', 1),
(2, 'Flujo Financiero', 'Validación especializada para documentos financieros', '{"requires_signatures": true, "audit_trail": true}', '14d', '/api/validation/financial', 1),
(3, 'Flujo Legal', 'Validación rigurosa para documentos legales', '{"legal_review": true, "notarization": false}', '30d', '/api/validation/legal', 1);

-- Workflows de validación
INSERT INTO [vpv_document_workflows] ([workflow_order], [creation_date], [documentid], [workflowid], [enabled])
VALUES
(1, GETDATE(), 1, 1, 1),
(1, GETDATE(), 2, 2, 1),
(1, GETDATE(), 3, 3, 1),
(2, GETDATE(), 3, 1, 1),
(1, GETDATE(), 4, 1, 1),
(1, GETDATE(), 5, 1, 1),
(1, GETDATE(), 6, 3, 1);

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

use VotoPuraVida;

-- Tipos de Propuestas
INSERT INTO [dbo].[vpv_proposal_type] ([name], [description], [enabled]) 
VALUES 
('Infraestructura P�blica', 'Proyectos de desarrollo de infraestructura urbana', 1),
('Energ�a Renovable', 'Proyectos relacionados con energ�as limpias', 1),
('Innovaci�n Tecnol�gica', 'Soluciones tecnol�gicas innovadoras', 1),
('Desarrollo Social', 'Iniciativas para mejorar condiciones sociales', 1),
('Educaci�n', 'Proyectos educativos y formativos', 1),
('Salud Comunitaria', 'Iniciativas para mejorar servicios de salud', 1),
('Cultura y Arte', 'Proyectos culturales y art�sticos', 1),
('Medio Ambiente', 'Iniciativas de conservaci�n ambiental', 1),
('Desarrollo Econ�mico', 'Proyectos para impulsar la econom�a local', 1),
('Turismo Sostenible', 'Iniciativas tur�sticas con enfoque sostenible', 1);

-- Estatus de Propuesta
INSERT INTO [dbo].[vpv_proposal_status] ([name], [description], [enabled]) 
VALUES 
('En Revisi�n', 'Propuesta enviada para evaluaci�n', 1),
('Aprobada', 'Propuesta aprobada para financiamiento', 1),
('Rechazada', 'Propuesta no aprobada', 1),
('En Modificaci�n', 'Propuesta requiere ajustes', 1),
('En Financiamiento', 'Propuesta en b�squeda de fondos', 1),
('Financiada', 'Propuesta con financiamiento completo', 1),
('Cancelada', 'Propuesta cancelada por el proponente', 1);

-- Insertar los tipos de origen para propuestas
INSERT INTO [dbo].[vpv_origin_type] ([name], [description], [enabled])
VALUES
('Ciudadano', 'Propuesta originada por un ciudadano individual o grupo de ciudadanos', 1),
('Entidad', 'Propuesta presentada por una organizaci�n, asociaci�n o entidad privada', 1),
('Gobierno', 'Propuesta generada por una instituci�n gubernamental o entidad p�blica', 1);

-- Tipos de validaci�n  
INSERT INTO [vpv_validation_types] ([name], [description], [enabled])
VALUES
('Validaci�n Autom�tica', 'Validaci�n realizada por sistema automatizado', 1),
('Revisi�n T�cnica', 'Revisi�n por equipo t�cnico especializado', 1),
('Aprobaci�n Legal', 'Revisi�n y aprobaci�n por departamento legal', 1),
('Verificaci�n Financiera', 'An�lisis de viabilidad financiera', 1);

-- Requests de validacion
INSERT INTO [vpv_validation_request] ([creation_date], [finish_date], [global_result], [userid], [validation_typeid])
VALUES
('2024-01-15', '2024-02-10', 'Aprobado con observaciones menores', 101, 2),
('2024-01-20', '2024-02-05', 'Aprobado', 102, 4),
('2024-03-01', '2024-03-25', 'Aprobado', 103, 2),
('2024-03-05', '2024-03-30', 'Rechazado - Requiere revisi�n', 104, 4),
('2024-04-10', '2024-04-28', 'Aprobado', 105, 2),
('2024-04-12', NULL, 'En proceso', 106, 4);

-- Tipos de secciones
INSERT INTO [vpv_section_type] ([name], [description], [enabled])
VALUES
('Encabezado', 'Secci�n inicial del documento', 1),
('Cuerpo Principal', 'Contenido principal del documento', 1),
('Anexos', 'Documentos adjuntos o complementarios', 1),
('Firmas', 'Secci�n para firmas y aprobaciones', 1),
('Metadatos', 'Informaci�n t�cnica sobre el documento', 1);

-- Tipos de Documento
INSERT INTO [vpv_document_type] ([name], [description], [enabled])
VALUES
('Estudio de Factibilidad', 'Documento t�cnico que analiza la viabilidad del proyecto', 1),
('Plan Financiero', 'Presupuesto y proyecciones econ�micas del proyecto', 1),
('Permisos Legales', 'Documentaci�n de permisos y autorizaciones requeridas', 1),
('Plan de Ejecuci�n', 'Cronograma y metodolog�a de implementaci�n', 1),
('Impacto Ambiental', 'Evaluaci�n de impacto ambiental del proyecto', 1),
('Contrato de Inversi�n', 'Acuerdos con los inversionistas', 1);

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
(1, 'Flujo B�sico', 'Validaci�n est�ndar para documentos simples', '{"max_pages": 50, "allowed_formats": ["pdf", "docx"]}', '7d', '/api/validation/basic', 1),
(2, 'Flujo Financiero', 'Validaci�n especializada para documentos financieros', '{"requires_signatures": true, "audit_trail": true}', '14d', '/api/validation/financial', 1),
(3, 'Flujo Legal', 'Validaci�n rigurosa para documentos legales', '{"legal_review": true, "notarization": false}', '30d', '/api/validation/legal', 1);

-- Workflows de validaci�n
INSERT INTO [vpv_document_workflows] ([workflow_order], [creation_date], [documentid], [workflowid], [enabled])
VALUES
(1, GETDATE(), 1, 1, 1),
(1, GETDATE(), 2, 2, 1),
(1, GETDATE(), 3, 3, 1),
(2, GETDATE(), 3, 1, 1),
(1, GETDATE(), 4, 1, 1),
(1, GETDATE(), 5, 1, 1),
(1, GETDATE(), 6, 3, 1);

-- Request de validaci�n 


        
---------------------------------------------------- PROPOSALS ---------------------------------------------------------------

INSERT INTO [dbo].[vpv_proposal] (
    [name], [enabled], [current_version], [description], 
    [submission_date], [version], [origin_typeid], [userid], 
    [statusid], [proposal_typeid], [entityid]
)
VALUES
-- 1. Initial proposal from Project 1: Boulevard Cartago
('Expansi�n Boulevard Cartago - Fase 1', 1, 1, 
 'Propuesta inicial para ampliaci�n de 5.2km del boulevard principal de Cartago',
 '2023-09-15', 1, 3, 101, 3, 1, 1),

-- 2. Initial proposal from Project 2: Planta Solar Guanacaste
('Planta Solar Guanacaste - 4.5MW', 1, 1,
 'Proyecto de generaci�n solar para abastecer 6,500 hogares',
 '2024-01-10', 1, 2, 201, 3, 2, 2),

-- 3. Initial proposal from Project 3: Plataforma Agricultura Digital
('AgriTech CR - Plataforma Digital', 1, 1,
 'Soluci�n tecnol�gica para optimizaci�n de cultivos para peque�os agricultores',
 '2024-04-05', 1, 2, 301, 3, 3, 3);

 -------------------------------------------------------------------------------------------------------------------------------

 -- Session para cada propuesta
INSERT INTO cf_proposal_votes ([date], [result], [sessionid], [proposalid])
VALUES
  ('2024-05-15 17:00:00', 1, 1, 1), -- Boulevard Cartago                Session 1
  ('2024-11-10 10:00:00', 1, 2, 2), -- Planta Solar Guanacaste          Session 2
  ('2025-01-20 14:00:00', 1, 3, 3) -- Plataforma Agricultura Digital    Session 3


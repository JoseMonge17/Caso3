-- TIPOS DE SECCIÓN
INSERT INTO [vpv_section_type] ([section_typeid], [name], [description], [enabled]) VALUES
(1, 'Encabezado', 'Sección superior que contiene metadatos como el título o número de documento', 1),
(2, 'Cuerpo', 'Sección principal que contiene el contenido del documento', 1),
(3, 'Pie de página', 'Sección inferior con fecha, firmas o cláusulas legales', 1),
(4, 'Anexos', 'Información adicional que acompaña al documento', 1),
(5, 'Referencias', 'Incluye citas o fuentes utilizadas en el documento', 1);

-- TIPOS DE DOCUMENTO
INSERT INTO [vpv_document_type] ([document_typeid], [name], [description], [enabled]) VALUES
(1, 'Cédula de identidad', 'Documento oficial emitido por el gobierno con datos personales', 1),
(2, 'Pasaporte', 'Documento oficial de viaje emitido por el gobierno', 1),
(3, 'Recibo de servicios', 'Documento utilizado para validar el domicilio del usuario', 1),
(4, 'Estado de cuenta bancario', 'Resumen mensual de movimientos de una cuenta bancaria', 1),
(5, 'Licencia de conducir', 'Documento oficial para conducir vehículos', 1);

-- TIPOS DE VALIDACIÓN
INSERT INTO [vpv_validation_types] ([validation_typeid], [name], [description], [enabled]) VALUES
(1, 'OCR', 'Reconocimiento Óptico de Caracteres para extraer texto del documento', 1),
(2, 'Comparación facial', 'Compara la foto del documento con una selfie o imagen del usuario', 1),
(3, 'Validación de dirección', 'Verifica la dirección contra registros oficiales', 1),
(4, 'Autenticidad del documento', 'Verifica sellos, formatos o marcas oficiales', 1),
(5, 'Validación de firma', 'Verifica la autenticidad de una firma manuscrita o digital', 1);

-- SOLICITUDES DE VALIDACIÓN
INSERT INTO [vpv_validation_request] ([requestid], [creation_date], [finish_date], [global_result], [userid], [validation_typeid]) VALUES
(1001, '2025-06-01 10:30:00', '2025-06-01 10:31:00', 'Éxito', 1, 1),
(1002, '2025-06-01 11:00:00', '2025-06-01 11:01:30', 'Coincidencia parcial', 2, 2),
(1003, '2025-06-01 12:00:00', '2025-06-01 12:01:10', 'Fallo - Dirección inválida', 3, 3),
(1004, '2025-06-01 13:00:00', '2025-06-01 13:02:20', 'Éxito', 4, 4),
(1005, '2025-06-01 14:00:00', '2025-06-01 14:01:00', 'Éxito', 1, 5);

-- DOCUMENTOS DIGITALES
INSERT INTO [vpv_digital_documents] ([documentid], [name], [url], [hash], [metadata], [validation_date], [requestid], [document_typeid]) VALUES
(2001, 'Cédula de identidad - Juan Pérez', 'https://example.com/docs/juan_perez_cedula.pdf', 'hashabc123id', '{"emitido_por":"TSE","número":"1-1234-5678","fecha_nacimiento":"1990-01-01"}', '2025-06-01 10:31:00', 1001, 1),
(2002, 'Pasaporte - Juan Pérez', 'https://example.com/docs/juan_pasaporte.pdf', 'hashabc456pass', '{"país":"Costa Rica","vencimiento":"2030-05-10"}', '2025-06-01 11:01:30', 1002, 2),
(2003, 'Recibo eléctrico Mayo 2025', 'https://example.com/docs/recibo_ice.pdf', 'hash789serv', '{"dirección":"Av. Central 123, San José","proveedor":"ICE"}', '2025-06-01 12:01:10', 1003, 3),
(2004, 'Estado de cuenta Abril 2025', 'https://example.com/docs/banco_bncr.pdf', 'hashbncr987', '{"banco":"BNCR","saldo":"2000.50"}', '2025-06-01 13:02:20', 1004, 4),
(2005, 'Licencia de conducir - Juan Pérez', 'https://example.com/docs/licencia.pdf', 'hashlic999', '{"número_licencia":"B1234567","vencimiento":"2028-11-20"}', '2025-06-01 14:01:00', 1005, 5);

-- FLUJOS DE VALIDACIÓN
INSERT INTO [vpv_validation_workflow] ([workflowid], [workflow_name], [description], [parameters], [schedule_interval], [url], [enabled]) VALUES
(3001, 'Validación de cédula', 'Flujo para OCR, validación de datos y comparación facial', '{"pasos":["OCR","Autenticidad","Comparación facial"]}', '5min', 'https://workflow.api/validar_cedula', 1),
(3002, 'Validación de recibo', 'Extrae dirección y la valida contra registros oficiales', '{"pasos":["OCR","Validación de dirección"]}', '10min', 'https://workflow.api/validar_recibo', 1);

-- ASIGNACIÓN DE FLUJOS A DOCUMENTOS
INSERT INTO [vpv_document_workflows] ([workflow_order], [creation_date], [documentid], [workflowid], [enabled]) VALUES
(1, '2025-06-01 10:00:00', 2001, 3001, 1),
(2, '2025-06-01 10:01:00', 2003, 3002, 1);

-- SECCIONES DE DOCUMENTOS
INSERT INTO [vpv_document_sections] ([sectionid], [required], [order_index], [rules], [section_typeid], [document_typeid], [parent_sectionid]) VALUES
(4001, 1, 1, '{"campo":"nombre_completo","regex":"^[A-Za-zÁÉÍÓÚáéíóúñÑ ]+$"}', 1, 1, NULL),
(4002, 1, 2, '{"campo":"fecha_nacimiento","tipo":"fecha"}', 2, 1, NULL),
(4003, 0, 3, '{"campo":"fecha_emisión","tipo":"fecha"}', 3, 1, NULL),
(4004, 1, 1, '{"campo":"proveedor_servicio","tipo":"cadena"}', 1, 3, NULL),
(4005, 1, 2, '{"campo":"dirección","tipo":"dirección"}', 2, 3, NULL),
(4006, 0, 3, '{"campo":"monto_facturado","tipo":"moneda"}', 2, 3, NULL),
(4007, 0, 4, '{"campo":"detalle_impuestos","tipo":"json"}', 4, 3, NULL),
(4008, 1, 1, '{"campo":"nombre","tipo":"cadena"}', 1, 5, NULL),
(4009, 1, 2, '{"campo":"fecha_vencimiento","tipo":"fecha"}', 2, 5, NULL),
(4010, 0, 3, '{"campo":"categoría","valores":["A","B","C"]}', 2, 5, NULL),
(4011, 1, 2, '{"campo":"firma","tipo":"imagen"}', 3, 5, 4009); -- Subsección de expiración

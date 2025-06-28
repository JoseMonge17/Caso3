// Importa la función del service que se encarga de procesar la lógica del SP
const { procesarCrearActualizarPropuestaSP } = require('../services/createUpdatePropService');

// Exporta el handler principal de Lambda (API Gateway lo invoca)
module.exports.handler = async (event) => {
  console.log("Llegó al handler de creación/actualización de propuesta");

  // Extrae la información del usuario autenticado desde el contexto del evento (middleware de autorización)
  const data = JSON.parse(event.requestContext.authorizer.data);
  const user = data.user;
  console.log("Usuario autenticado:", user.username);

  try {
    // Intenta parsear el cuerpo del request recibido (formulario enviado desde el frontend)
    const body = JSON.parse(event.body || '{}');
    
    // Si se enviaron documentos, normaliza cada uno para asegurar formato y valores por defecto
    if (body.documents && Array.isArray(body.documents)) {
      body.documents = body.documents.map(doc => ({
        name: doc.name || `Documento-${Date.now()}`,            // Nombre default si no se especifica
        url: doc.url || '',                                     // URL vacía si no viene
        hash: doc.hash || '',                                   // Hash vacío si no viene
        metadata: doc.metadata ? JSON.stringify(doc.metadata) : '{}', // Se asegura de que metadata venga en formato string JSON
        validation_date: null,                                  // Campo reservado para validación posterior
        requestid: null,                                        // ID de solicitud aún no asignado
        document_typeid: doc.document_typeid || 0,              // Tipo de documento por defecto (0)
        is_required: doc.is_required ? 1 : 0                    // Normaliza el booleano como entero
      }));
    }

    // Llama al servicio que ejecuta el SP, pasando el body como string JSON y el usuario
    const result = await procesarCrearActualizarPropuestaSP(JSON.stringify(body), user);
    console.log("✅ SP ejecutado correctamente");

    // Respuesta HTTP 200 si todo salió bien
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        mensaje: 'Propuesta creada o actualizada exitosamente.',
        resultado: result
      })
    };
  } catch (err) {
    // Manejo de errores: registra el error y responde con estado 500 o el código indicado
    console.error("❌ Error en el SP:", err);

    return {
      statusCode: err.statusCode || 500,
      body: JSON.stringify({ 
        error: 'Error en la creación o actualización de la propuesta', 
        detalles: err.message 
      })
    };
  }
};

/*
{
  "name": "Sistema de Transporte Público Autónomo",
  "description": "Propuesta para implementar buses eléctricos autónomos en zonas urbanas.",
  "origin_typeid": 2,
  "proposal_typeid": 1,
  "allows_comments": true,
  "documents": [
    {
      "name": "Informe Técnico",
      "url": "https://example.com/docs/informe_tecnico.pdf",
      "hash": "abc123def456",
      "metadata": "{ \"categoria\": \"movilidad\", \"autor\": \"Dept. Transporte\" }",
      "document_typeid": 1,
      "is_required": true
    },
    {
      "name": "Estudio Financiero",
      "url": "https://example.com/docs/estudio_financiero.pdf",
      "hash": "789xyz456lmn",
      "metadata": "{ \"categoria\": \"finanzas\", \"año\": 2025 }",
      "document_typeid": 2,
      "is_required": false
    }
  ],
  "target_population": [
    { "demographicid": 1 },
    { "demographicid": 3 }
  ],
  "version_comment": "Propuesta inicial con análisis técnico y financiero"
}
*/
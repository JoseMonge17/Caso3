const { procesarCrearActualizarPropuestaSP } = require('../services/createUpdatePropService');

module.exports.handler = async (event) => {
  console.log("🛬 Llegó al handler de creación/actualización de propuesta");

  const data = JSON.parse(event.requestContext.authorizer.data);
  const user = data.user;
  console.log("🧑 Usuario autenticado:", user.username);

  try {
    const body = JSON.parse(event.body || '{}');
    
    if (body.documents && Array.isArray(body.documents)) {
      body.documents = body.documents.map(doc => ({
        name: doc.name || `Documento-${Date.now()}`,
        url: doc.url || '',
        hash: doc.hash || '',
        metadata: doc.metadata ? JSON.stringify(doc.metadata) : '{}',
        validation_date: null,
        requestid: null,
        document_typeid: doc.document_typeid || 0,
        is_required: doc.is_required ? 1 : 0
      }));
    }

    const result = await procesarCrearActualizarPropuestaSP(JSON.stringify(body), user);
    console.log("✅ SP ejecutado correctamente");

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        mensaje: 'Propuesta creada o actualizada exitosamente.',
        resultado: result
      })
    };
  } catch (err) {
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
  "name": "Rediseño de Espacios Verdes",
  "description": "Plan maestro para parques comunitarios",
  "origin_typeid": 1,
  "proposal_typeid": 2,
  "entityid": null,
  "allows_comments": true,
  "documents": [
    {
      "name": "Informe Técnico",
      "url": "https://miarchivo.com/doc1.pdf",
      "hash": "abc123",
      "metadata": "{\"autor\": \"Luis\"}",
      "validation_date": null,
      "requestid": null,
      "document_typeid": 1,
      "is_required": true
    }
  ],
  "target_population": [
    { "demographicid": 2 },
    { "demographicid": 4 }
  ],
  "version_comment": "Versión inicial para evaluación"
}
*/
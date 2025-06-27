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
🧪 JSON de prueba para Postman:

{
  "name": "Propuesta de Energía Solar",
  "description": "Proyecto para instalar paneles solares en escuelas rurales.",
  "origin_typeid": 1,
  "proposal_typeid": 2,
  "entityid": null,
  "documents": [
    {
      "name": "Estudio Ambiental Preliminar",
      "url": "https://example.com/docs/ambiental.pdf",
      "hash": "doc002hash",
      "metadata": {"evaluador":"Carlos Rivera","riesgo":"bajo"},
      "document_typeid": 3,
      "is_required": false
    },
    {
      "name": "Presupuesto Detallado",
      "url": "https://example.com/docs/presupuesto.pdf",
      "hash": "doc003hash",
      "metadata": {"moneda":"USD","vigencia":"2023-12-31"},
      "document_typeid": 5,
      "is_required": true
    }
  ],
  "version_comment": "Primera versión de la propuesta."
}
*/
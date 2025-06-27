const { procesarCrearActualizarPropuestaSP } = require('../services/createUpdatePropService');

module.exports.handler = async (event) => {
  console.log("🛬 Llegó al handler de creación/actualización de propuesta");

  const data = JSON.parse(event.requestContext.authorizer.data);
  const user = data.user;
  console.log("🧑 Usuario autenticado:", user.username);

  try {
    const result = await procesarCrearActualizarPropuestaSP(event.body, user);
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
  "entityid": null,  // O el ID de la entidad si aplica
  "documents": [
    { "documentid": 1, "is_required": true },
    { "documentid": 3, "is_required": false }
  ],
  "version_comment": "Primera versión de la propuesta."
}
*/
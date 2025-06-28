// Importa la función de servicio que procesa la revisión de una propuesta
const { procesarRevisionPropuesta } = require('../services/proposalReviewService');

// Handler principal para el endpoint Lambda (API Gateway)
module.exports.handler = async (event) => {
  console.log('Entrando a revisarPropuesta (handler)');

  // Extrae los datos del usuario autenticado desde el token de autorización
  const data = JSON.parse(event.requestContext.authorizer.data);
  const user = data.user;

  try {
    // Ejecuta el servicio pasando el body de la petición y los datos del usuario autenticado
    const result = await procesarRevisionPropuesta(event.body, user);
    console.log('Revisión completada');

    // Devuelve respuesta exitosa con el resultado del stored procedure
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(result)
    };
  } catch (err) {
    // En caso de error, se devuelve un mensaje adecuado para el cliente
    console.error('Error al revisar propuesta:', err);
    return {
      statusCode: err.statusCode || 500,
      body: JSON.stringify({
        error: 'Error al revisar la propuesta',
        detalles: err.message || 'Error desconocido'
      })
    };
  }
};

/*
POSTMAN JSON (body esperado):
{
  "proposalid": 123
}
*/

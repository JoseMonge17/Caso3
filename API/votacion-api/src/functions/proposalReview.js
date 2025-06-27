const { procesarRevisionPropuesta } = require('../services/proposalReviewService');

module.exports.handler = async (event) => {
  console.log('Entrando a revisarPropuesta (handler)');
  
  // Obtener datos del token
  const data = JSON.parse(event.requestContext.authorizer.data);
  const user = data.user;

  try {
    // Ejecutar el servicio
    const result = await procesarRevisionPropuesta(event.body, user);
    console.log('Revisión completada');

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(result)
    };
  } catch (err) {
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
POSTMAN JSON (body):
{
  "proposalid": 123
}
*/
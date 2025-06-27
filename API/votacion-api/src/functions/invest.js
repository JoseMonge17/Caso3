const { procesarInversionSP } = require('../services/investService');

module.exports.handler = async (event) => {
  console.log("Iniciando handler de inversión");
  // Obtener los datos del context  
  const data = JSON.parse(event.requestContext.authorizer.data);

  //obtener solamente los datos del usuario
  const user = data.user;
  try {
    // llamar a la capa de service pasando el body y el usuario
    const result = await procesarInversionSP(event.body, user);
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" }, 
      body: JSON.stringify({ // formato que se le retorna al cliente en caso de éxito
        status: 'success',
        data: result,
        timestamp: new Date().toISOString()
      })
    };
  } catch (err) {
    // Determinar el código de estado adecuado
    const statusCode = err.statusCode || 500;
    const errorDetails = process.env.NODE_ENV === 'development' ? 
      { 
        message: err.message,
        stack: err.stack,
        ...(err.details && { details: err.details })
      } : 
      { message: err.message };
    
    return {
      statusCode,
      headers: { 
        "Content-Type": "application/json",
        "X-Request-ID": event.requestContext?.requestId || 'unknown'
      },
      body: JSON.stringify({ // formato que se le retorna al cliente en caso de error
        status: 'error',
        error: statusCode === 400 ? 'Validación fallida' : 
              statusCode === 401 ? 'No autorizado' : 
              statusCode === 403 ? 'Acceso denegado' : 
              'Error en el servidor',
        ...errorDetails,
        timestamp: new Date().toISOString()
      })
    };
  }
};
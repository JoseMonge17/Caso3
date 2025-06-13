//const { procesarInversionSP } = require('../services/investService');

module.exports.handler = async (event) => {
  console.log("ya llegue al invest");
  //console.log(event);

  const user = JSON.parse(event.requestContext.authorizer.user);
  console.log(user);
  try {
    //const result = await procesarInversionSP(event);
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify("todo bien")
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        error: 'Error en inversión', 
        detalles: err.message 
      })
    };
  }
};
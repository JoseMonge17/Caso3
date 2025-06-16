const { procesarCreaUpPropuestaSP } = require('../services/createUpdatePropService');

module.exports.handler = async (event) => {
  console.log("he llegado al handler de create-update propuesta");

  const data = JSON.parse(event.requestContext.authorizer.data);
  const user = data.user;
  console.log(data);
  try {
    const result = await procesarCreaUpPropuestaSP(event.body, user);
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(result)
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        error: 'Error en la creación o actualización de la propuesta', 
        detalles: err.message 
      })
    };
  }
};
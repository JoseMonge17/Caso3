const { procesarDividendosSP } = require('../services/distributeDividendsService');

module.exports.handler = async (event) => {
  console.log("ya llegue al invest");

  const data = JSON.parse(event.requestContext.authorizer.data);
  const user = data.user;
  console.log(data);
  try {
    const result = await procesarDividendosSP(event.body, user);
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(result)
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        error: 'Error en distribución', 
        detalles: err.message
      })
    };
  }
};
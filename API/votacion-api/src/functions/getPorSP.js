const { procesarSP } = require('../services/providerService');

module.exports.handler = async (event) => {
  
  const data = JSON.parse(event.requestContext.authorizer.data);
  user = data.user;
  try {
    const result = await procesarSP(event.body, user);
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(result)
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Error interno', detalles: err.message })
    };
  }
};

/*
{
  "name": "Costa Rica",
  "codeISO": "CR",
  "enable": 1,
}
*/
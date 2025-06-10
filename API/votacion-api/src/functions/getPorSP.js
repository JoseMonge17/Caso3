const { getProvidersBySP } = require('../services/providerService');

module.exports.handler = async () => {
  try {
    const result = await getProvidersBySP();
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
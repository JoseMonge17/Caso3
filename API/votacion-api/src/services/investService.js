const { ejecutarInversionSP } = require('../data/investData');

async function procesarInversionSP(body, user) {
  // 1. Obtener userid del token
  const userid = user.userid; 

  // 2. Parsear y validar input 
  const input = JSON.parse(body || '{}');
  if (!input.proposalid || !input.monto) {
    throw { statusCode: 400, message: 'Faltan proposalid o monto' };
  }

  // 3. Inyectar userid en los parámetros
  const params = {
    ...input,
    userid // Añadimos el userid obtenido del token
  };

  return await ejecutarInversionSP(params);
}

module.exports = { procesarInversionSP };
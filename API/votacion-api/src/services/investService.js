const { ejecutarInversionSP } = require('../data/inversionData');
const { getUserFromToken } = require('../auth');

async function procesarInversionSP(event) {
  // 1. Obtener userid del token
  const tokenPayload = getUserFromToken(event);
  const userid = tokenPayload.id; 

  // 2. Parsear y validar input 
  const input = JSON.parse(event.body || '{}');
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
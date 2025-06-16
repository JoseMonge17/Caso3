const { ejecutarPropuestaSP } = require('../data/createUpdatePropData');

async function procesarCreaUpPropuestaSP(body, user) {
  // 1. Obtener userid del token
  const userid = user.userid; 

  // 2. Parsear y validar input 
  const input = JSON.parse(body || '{}');
  if (!input.proposalid) {
    throw { statusCode: 400, message: 'Faltan proposalid' };
  }

  // 3. Inyectar userid en los parámetros
  const params = {
    ...input,
    userid // Añadimos el userid obtenido del token
  };

  return await ejecutarPropuestaSP(params);
}

module.exports = { procesarCreaUpPropuestaSP };
const { fetchProvidersFromSP } = require('../data/providerData');

async function procesarSP(body, user) {
  // 1. Obtener userid del token
  const userid = user.userid; 

  // 2. Parsear y validar input 
  const input = JSON.parse(body || '{}');
  if (!input.name || !input.codeISO || !input.enable) {
    throw { statusCode: 400, message: 'Faltan nombre, codigo o registro' };
  }

  // 3. Inyectar userid en los parámetros
  const params = {
    ...input,
    userid // Añadimos el userid obtenido del token
  };

  return await fetchProvidersFromSP(params);
}

module.exports = { procesarSP };
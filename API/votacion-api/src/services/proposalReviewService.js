const { reviewProposal } = require('../data/proposalReviewData');

async function procesarRevisionPropuesta(body, user) {
  // 1. Obtener el userid desde el token del usuario autenticado
  const userid = user.userid;

  // 2. Parsear y validar el body
  const input = JSON.parse(body || '{}');

  if (!input.proposalid) {
    throw {
      statusCode: 400,
      message: 'Se requiere el identificador de la propuesta para revisarla.'
    };
  }

  // 3. Preparar parámetros y ejecutar el SP
  const params = {
    proposalid: input.proposalid,
    userid
  };

  console.log('[Service] Ejecutando revisión de propuesta con:', params);

  return await reviewProposal(params);
}

module.exports = { procesarRevisionPropuesta };

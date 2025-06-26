const { distributeDividends } = require('../data/distributeDividendsData');

async function procesarDividendosSP(body, user) {
  // 1. Obtener userid del token
  const userid = user.userid; 

  // 2. Parsear y validar input TODO: Todas las entradas correctas
  const input = JSON.parse(body || '{}');
   // Validación básica de parámetros requeridos
  if (!input.project_id || !input.finance_report_id || !input.payment_methodid) {
    throw new Error('Faltan parámetros requeridos: project_id, finance_report_id o payment_methodid');
  }

  // 3. Inyectar userid en los parámetros
  const params = {
    ...input,
    userid // Añadimos el userid obtenido del token
  };

  return await distributeDividends(params);
}

module.exports = { procesarDividendosSP };
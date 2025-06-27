const { distributeDividends } = require('../data/distributeDividendsData');

async function procesarDividendosSP(body, user) {
  // 1. Obtener userid del token
  const userid = user.userid; 

  // 2. Parsear y validar input TODO: Todas las entradas correctas
  const input = JSON.parse(body || '{}');
   // Validación básica de parámetros requeridos

   // Validación robusta de parámetros requeridos
  const requiredParams = ['project_id', 'finance_report_id', 'payment_methodid'];
  const missingParams = requiredParams.filter(param => input[param] === undefined || input[param] === null);

  if (missingParams.length > 0) { 
    throw {
      statusCode: 400,
      message: {
        errorMessage: `Parámetros requeridos faltantes: ${missingParams.join(', ')}`,
        details: {
          requiredParams,
          receivedParams: Object.keys(input).filter(k => input[k] !== undefined)
        }
      }
    };
  }

  // Validación detallada de cada parámetro
  const validationErrors = [];

  // Validar id del proyecto dado
  const project_id = parseInt(input.project_id);
  if (isNaN(project_id) || !Number.isInteger(project_id) || project_id <= 0) {
    validationErrors.push({
      param: 'project_id',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.project_id,
      expectedType: 'positive integer'
    });
  }

  // Validar id del reporte financiero 
  const finance_report_id = parseInt(input.finance_report_id);
  if (isNaN(finance_report_id) || !Number.isInteger(finance_report_id) || finance_report_id <= 0) {
    validationErrors.push({
      param: 'finance_report_id',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.finance_report_id,
      expectedType: 'positive integer'
    });
  }

  // Validar el método de pago
  const payment_methodid = parseInt(input.payment_methodid);
  if (isNaN(payment_methodid)) {
    validationErrors.push({
      param: 'payment_methodid',
      problem: 'No es un número válido',
      received: input.payment_methodid,
      expectedType: 'integer'
    });
  } else if (!Number.isInteger(payment_methodid) || payment_methodid <= 0) {
    validationErrors.push({
      param: 'payment_methodid',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.payment_methodid,
      expectedType: 'positive integer'
    });
  }

  // Si hay errores de validación, lanzar excepción con mensaje con detalles 
  if (validationErrors.length > 0) {
    throw {
      statusCode: 400,
      message: { 
        errorMessage : 'Validación fallida para uno o más parámetros', 
        details: {
          validationErrors,
          receivedInput: input
        }
      }
    };
  }

  // 3. Inyectar userid en los parámetros
  const params = {
    ...input,
    userid // Añadimos el userid obtenido del token
  };

  return await distributeDividends(params);
}

module.exports = { procesarDividendosSP };
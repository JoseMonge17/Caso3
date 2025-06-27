const { ejecutarInversionSP } = require('../data/investData');

async function procesarInversionSP(body, user) {
  // 1. Obtener userid del token
  const userid = user.userid; 

  // 2. Parsear y validar input
  const input = typeof body === 'string' ? JSON.parse(body || '{}') : body;

  // Validación robusta de parámetros requeridos
  const requiredParams = ['proposalid', 'monto', 'codigoPago', 'token', 'metodoPagoId'];
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

  // Validar proposalid
  const proposalId = parseInt(input.proposalid);
  if (isNaN(proposalId) || !Number.isInteger(proposalId) || proposalId <= 0) {
    validationErrors.push({
      param: 'proposalid',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.proposalid,
      expectedType: 'positive integer'
    });
  }

  // Validar monto
  const monto = parseFloat(input.monto);
  if (isNaN(monto) || monto <= 0) {
    validationErrors.push({
      param: 'monto',
      problem: 'Debe ser un número positivo mayor que cero',
      received: input.monto,
      expectedType: 'positive number'
    });
  }

  // Validar metodoPagoId
  const metodoPagoId = parseInt(input.metodoPagoId);
  if (isNaN(metodoPagoId)) {
    validationErrors.push({
      param: 'metodoPagoId',
      problem: 'No es un número válido',
      received: input.metodoPagoId,
      expectedType: 'integer'
    });
  } else if (!Number.isInteger(metodoPagoId) || metodoPagoId <= 0) {
    validationErrors.push({
      param: 'metodoPagoId',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.metodoPagoId,
      expectedType: 'positive integer'
    });
  }

  // Validar codigoPago
  if (typeof input.codigoPago !== 'string' || input.codigoPago.trim().length === 0) {
    validationErrors.push({
      param: 'codigoPago',
      problem: 'Debe ser una cadena de texto no vacía',
      received: input.codigoPago,
      expectedType: 'non-empty string'
    });
  }

  // Validar token
  if (typeof input.token !== 'string' || input.token.trim().length === 0) {
    validationErrors.push({
      param: 'token',
      problem: 'Debe ser una cadena de texto no vacía',
      received: input.token,
      expectedType: 'non-empty string'
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

  // 3. Preparar parámetros para el SP
  const params = {
    proposalid: proposalId,
    monto: monto,
    codigoPago: input.codigoPago.trim(),
    token: input.token.trim(),
    metodoPagoId: metodoPagoId,
    userid // Añadimos el userid obtenido del token
  };

  return await ejecutarInversionSP(params);
}

module.exports = { procesarInversionSP };
// Importa la función de acceso a datos que llama al stored procedure de revisión
const { reviewProposal } = require('../data/proposalReviewData');

/**
 * Servicio para procesar la revisión de una propuesta.
 * Se encarga de validar la entrada, construir los parámetros esperados
 * y delegar la ejecución al stored procedure correspondiente.
 * 
 * @param {string} body - Cuerpo de la solicitud HTTP (JSON en string)
 * @param {Object} user - Objeto del usuario autenticado, extraído del token
 * @returns {Promise<Object>} - Resultado devuelto por el SP
 */
async function procesarRevisionPropuesta(body, user) {
  // 1. Obtener el ID del usuario desde el token (asegura trazabilidad)
  const userid = user.userid;

  // 2. Parsear el body del request (en caso de que venga como string vacío se convierte en objeto vacío)
  const input = JSON.parse(body || '{}');

  // 3. Validar que se haya recibido el ID de la propuesta a revisar
  if (!input.proposalid) {
    throw {
      statusCode: 400,
      message: 'Se requiere el identificador de la propuesta para revisarla.'
    };
  }

  // 4. Construir los parámetros a enviar al SP
  const params = {
    proposalid: input.proposalid,
    userid
  };

  console.log('[Service] Ejecutando revisión de propuesta con:', params);

  // 5. Ejecutar la llamada a la capa de datos (stored procedure)
  return await reviewProposal(params);
}

// Exporta la función de servicio para ser usada desde el handler
module.exports = { procesarRevisionPropuesta };
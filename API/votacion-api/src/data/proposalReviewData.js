// Importa la utilidad para ejecutar stored procedures y los tipos de SQL (de la configuración de la base de datos)
const { executeSP, sql } = require('../db/config');

/**
 * Función que llama al procedimiento almacenado `sp_revisar_propuesta`
 * para validar y aprobar una propuesta específica.
 * 
 * Esta es la capa más cercana al acceso a la base de datos. Se encarga
 * únicamente de enviar los parámetros correctos con sus respectivos tipos SQL.
 * 
 * @param {Object} params - Parámetros requeridos por el SP
 * @param {number} params.proposalid - ID de la propuesta a revisar
 * @param {number} params.userid - ID del usuario que ejecuta la revisión
 * @returns {Promise<Object>} - Resultado devuelto por el SP
 */
async function reviewProposal({ proposalid, userid }) {
  console.log('[SP] Ejecutando sp_revisar_propuesta...');

  // Llama al stored procedure usando el helper executeSP con los parámetros y sus tipos
  return executeSP(
    'sp_revisar_propuesta',
    {
      proposalid,
      userid
    },
    {
      proposalid: sql.Int,
      userid: sql.Int
    }
  );
}

// Exporta la función para que pueda ser utilizada por la capa de servicios
module.exports = { reviewProposal };

// Importa la función genérica para ejecutar stored procedures y los tipos SQL disponibles
const { executeSP, sql } = require('../db/config');

/**
 * Ejecuta el stored procedure 'sp_crear_actualizar_propuesta' con los datos recibidos.
 * Esta función forma parte de la capa de acceso a datos (data).
 * 
 * @param {Object} params - Parámetros validados y normalizados desde la capa service
 * @returns {Promise<Object>} - Resultado devuelto por el SP (propuestaid, versión, mensaje)
 */
async function createOrUpdateProposal(params) {
  return executeSP(
    'sp_crear_actualizar_propuesta', // Nombre del procedimiento almacenado

    // Objeto con los valores que se enviarán al SP (convertidos según se espera)
    {
      name: params.name,
      description: params.description,
      origin_typeid: params.origin_typeid,
      userid: params.userid,
      proposal_typeid: params.proposal_typeid,
      entityid: params.entityid,
      allows_comments: params.allows_comments,
      documents: JSON.stringify(params.documents),               // Serializa los documentos como JSON string
      target_population: JSON.stringify(params.target_population), // Serializa la población meta como JSON string
      version_comment: params.version_comment
    },

    // Tipos SQL esperados por el SP, definidos explícitamente para compatibilidad
    {
      name: sql.VarChar(100),
      description: sql.VarChar(255),
      origin_typeid: sql.Int,
      userid: sql.Int,
      proposal_typeid: sql.Int,
      entityid: sql.Int,
      allows_comments: sql.Bit,
      documents: sql.NVarChar(sql.MAX),
      target_population: sql.NVarChar(sql.MAX),
      version_comment: sql.Text
    }
  );
}

// Exporta la función para que pueda ser utilizada por la capa service
module.exports = { createOrUpdateProposal };
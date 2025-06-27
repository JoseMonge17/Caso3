const { executeSP, sql } = require('../db/config');

async function crearOActualizarPropuesta(params) {
  return executeSP(
    'sp_crear_actualizar_propuesta',
    {
      name: params.name,
      description: params.description,
      origin_typeid: params.origin_typeid,
      userid: params.userid,
      proposal_typeid: params.proposal_typeid,
      entityid: params.entityid, // Puede ser null
      documents: JSON.stringify(params.documents), // Asegurar conversión a JSON
      version_comment: params.version_comment || null // Manejo de valor nulo
    },
    {
      name: sql.VarChar(100),
      description: sql.VarChar(255),
      origin_typeid: sql.Int,
      userid: sql.Int,
      proposal_typeid: sql.Int,
      entityid: sql.Int,
      documents: sql.NVarChar(sql.MAX),
      version_comment: sql.Text
    }
  );
}

module.exports = { crearOActualizarPropuesta };
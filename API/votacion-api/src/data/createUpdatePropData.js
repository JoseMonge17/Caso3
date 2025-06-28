const { executeSP, sql } = require('../db/config');

async function createOrUpdateProposal(params) {
  return executeSP('sp_crear_actualizar_propuesta', 
    {
      name: params.name,
      description: params.description,
      origin_typeid: params.origin_typeid,
      userid: params.userid,
      proposal_typeid: params.proposal_typeid,
      entityid: params.entityid,
      allows_comments: params.allows_comments,
      documents: JSON.stringify(params.documents),
      target_population: JSON.stringify(params.target_population),
      version_comment: params.version_comment
    },
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

module.exports = { createOrUpdateProposal };
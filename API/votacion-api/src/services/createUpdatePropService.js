const { createOrUpdateProposal } = require('../data/createUpdatePropData');

async function procesarCrearActualizarPropuestaSP(body, user) {
  const userid = user.userid;
  const input = JSON.parse(body || '{}');

  // Validaciones básicas
  const camposFaltantes = [];
  if (!input.name) camposFaltantes.push('name');
  if (!input.description) camposFaltantes.push('description');
  if (input.origin_typeid == null) camposFaltantes.push('origin_typeid');
  if (input.proposal_typeid == null) camposFaltantes.push('proposal_typeid');
  if (!Array.isArray(input.documents)) camposFaltantes.push('documents (debe ser array)');

  if (camposFaltantes.length > 0) {
    throw {
      statusCode: 400,
      message: `Faltan campos obligatorios: ${camposFaltantes.join(', ')}`
    };
  }

  const params = {
    name: input.name,
    description: input.description,
    origin_typeid: input.origin_typeid,
    userid,
    proposal_typeid: input.proposal_typeid,
    entityid: input.entityid ?? null,
    allows_comments: input.allows_comments ?? false,
    documents: input.documents,
    target_population: input.target_population ?? [],
    version_comment: input.version_comment ?? null
  };

  return await createOrUpdateProposal(params);
}

module.exports = { procesarCrearActualizarPropuestaSP };
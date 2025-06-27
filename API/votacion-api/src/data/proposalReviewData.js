const { executeSP, sql } = require('../db/config');

async function reviewProposal({ proposalid, userid }) {
  console.log('[SP] Ejecutando sp_revisar_propuesta...');
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

module.exports = { reviewProposal };
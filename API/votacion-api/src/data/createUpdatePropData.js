const { executeSP } = require('../db/config');

async function ejecutarPropuestaSP(params) {
  return executeSP('SP_CF_ProcesarInversion', {
    proposalid: params.proposalid,
    userid: params.userid,          
  });
}

module.exports = { ejecutarPropuestaSP };
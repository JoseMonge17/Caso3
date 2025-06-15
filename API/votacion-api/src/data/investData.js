const { executeSP } = require('../db/config');

async function ejecutarInversionSP(params) {
  return executeSP('SP_CF_ProcesarInversion', {
    proposalid: params.proposalid,
    userid: params.userid,
    monto: params.monto,
    codigoPago: params.codigoPago || null,
    metodoPagoId: params.metodoPagoId || 1,
    numeroreferencia: params.numeroreferencia,  
    token: params.token           
  });
}

module.exports = { ejecutarInversionSP };
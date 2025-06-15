const { executeSP } = require('../db/config');

async function ejecutarInversionSP(params) {
  return executeSP('SP_CF_ProcesarInversion', {
    proposalid: params.proposalid,
    userid: params.userid,
    monto: params.monto,
    codigoPago: params.codigoPago,
    numeroreferencia: params.numeroreferencia,  
    token: params.token,
    metodoPagoId: params.metodoPagoId || 1,           
  });
}

module.exports = { ejecutarInversionSP };
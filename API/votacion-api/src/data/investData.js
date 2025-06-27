const { executeSP, sql } = require('../db/config');

async function ejecutarInversionSP(params) {
  return executeSP('SP_CF_ProcesarInversion', 
  {
    proposalid: params.proposalid,
    userid: params.userid,
    monto: params.monto,
    codigoPago: params.codigoPago,
    token: params.token,
    metodoPagoId: params.metodoPagoId || 1,           
  },
  {
    proposalid: sql.Int,
    userid: sql.Int,
    monto: sql.Float,
    codigoPago: sql.NVarChar(100),
    token: sql.NVarChar(200),
    metodoPagoId: sql.Int
  });
}

module.exports = { ejecutarInversionSP };
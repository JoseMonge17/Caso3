const { executeSP, sql } = require('../db/config');

async function ejecutarInversionSP(params) {
  // Mapeo de parámetros al SP
  const spParams = {
    proposalid: params.proposalid,
    userid: params.userid,
    monto: params.monto, 
    codigoPago: params.codigoPago,
    token: params.token,
    metodoPagoId: params.metodoPagoId
  };

  // Configuración de tipos SQL
  const typesConfig = {
    proposalid: sql.Int,
    userid: sql.Int,
    monto: sql.Float, 
    codigoPago: sql.NVarChar(100),
    token: sql.NVarChar(200),
    metodoPagoId: sql.Int
  };

  try {
    const result = await executeSP('SP_CF_ProcesarInversion', spParams, typesConfig);
    
    // Formatear respuesta para el cliente
    return {
      success: true,
      investmentData: {
        investmentId: result[0]?.investmentid, // id de la inversión
        equityPercentage: result[0]?.equityPercentage, // porcentaje accionario sobre el proyecto asignado
        amountInvested: parseFloat(params.monto), // monto que invirtió 
        newTotalInvested: result[0]?.newTotalInvested // el total invertido en el proyecto luego de la inversión
      },
      metadata: {
        projectId: params.proposalid,
        investorId: params.userid,
        executedAt: new Date().toISOString()
      }
    };
    
  } catch (error) {
    console.error('Error en investData:', error.message);
    throw new Error(`Error en Inversión: ${error.message}`);
  }
}

module.exports = { ejecutarInversionSP };
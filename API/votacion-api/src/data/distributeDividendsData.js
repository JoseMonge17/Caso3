const { executeSP, sql } = require('../db/config');

async function distributeDividends(params) {
    // Mapeo de parámetros del JSON a los del SP
    const spParams = {
        projectId: params.project_id,
        ReporteGananciasID: params.finance_report_id,
        UsuarioEjecutor: params.userid,
        numeroreferencia: params.master_reference || `DIV-${Date.now()}`,
        PayMethodId: params.payment_methodid
    };

    // Configuración de tipos para executeSP
    const typesConfig = {
        projectId: sql.Int,
        ReporteGananciasID: sql.Int,
        UsuarioEjecutor: sql.Int,
        numeroreferencia: sql.NVarChar(100),
        PayMethodId: sql.Int
    };

    try {
        const result = await executeSP('SP_RepartirDividendos', spParams, typesConfig);
    
    // Formatear respuesta para el cliente
    return {
      success: true,
      transactionId: result[0]?.TransactionID,
      amounts: {
        total: result[0]?.TotalGanancias,
        fees: result[0]?.ComisionesAplicadas,
        distributed: result[0]?.DistribuidoInversionistas
      },
      metadata: {
        projectId: params.project_id,
        executedBy: params.userid
      }
    };
  } catch (error) {
    console.error('Error en distributeDividends:', error.message);
    throw new Error(`Error financiero: ${error.message}`);
  }
}

module.exports = { distributeDividends };

/*
{
  "project_id": 1,
  "finance_report_id": 2,
  "payment_methodid": 3, 
  "master_reference": "DIV-MASTER-20240601-002",
  "investor_references": ["DIV-INV-20240515-41258"],  // Array.
  "commission_references": ["DIV-COM-20240515-A1-001"]
}
*/ 
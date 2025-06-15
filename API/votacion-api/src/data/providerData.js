const { sql, config } = require('../db/config');

async function fetchProvidersFromSP() {
  try {
    await sql.connect(config);
    const result = await sql.query('EXEC sp_get_api_providers');
    return result.recordset;
  } catch (err) {
    throw new Error('Error al ejecutar el SP: ' + err.message);
  }
}

module.exports = { fetchProvidersFromSP };
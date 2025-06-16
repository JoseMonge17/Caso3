const sql = require('mssql');

const config = {
  user: 'votouser',
  password: 'YourStrong@Password',
  server: 'localhost', 
  database: 'VotoPuraVida',
  options: {
    encrypt: true,
    trustServerCertificate: true
  }
};

async function executeSP(spName, params = {}, typesConfig = {}) {
  try {
    const pool = await sql.connect(config);
    const request = pool.request();

    Object.entries(params).forEach(([key, value]) => {
      // Usa configuración explícita o determina el tipo
      const type = typesConfig[key] || determineType(key, value);
      request.input(key, type, value);
    });

    const result = await request.execute(spName);
    return result.recordset;
  } catch (err) {
    console.error(`Error en SP ${spName}:`, err);
    throw err;
  }
}


module.exports = { sql, config, executeSP};


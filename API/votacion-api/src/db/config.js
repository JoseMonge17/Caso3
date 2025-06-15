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

// función que permite ejecutar SP con parámetros
async function executeSP(spName, params = {}) {
  try {
    const pool = await sql.connect(config);
    const request = pool.request();
    
    // Asigna parámetros directamente desde un JSON
    Object.entries(params).forEach(([key, value]) => {
      request.input(key, sql.VarChar, value); // Tipo por defecto: VarChar
    });

    const result = await request.execute(spName);
    return result.recordset; // Devuelve los datos insertados/consultados
  } catch (err) {
    console.error(`Error en SP ${spName}:`, err);
    throw err;
  }
}


module.exports = { sql, config, executeSP};


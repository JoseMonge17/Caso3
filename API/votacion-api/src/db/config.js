const sql = require('mssql');

const config = {
  user: 'votouser',
  password: '1234',
  server: 'localhost',
  database: 'VotoPuraVida',
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

module.exports = { sql, config };


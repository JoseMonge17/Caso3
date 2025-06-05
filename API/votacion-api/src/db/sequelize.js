const { Sequelize, DataTypes } = require('sequelize');

const sequelize = new Sequelize('VotoPuraVida', 'votouser', '1234', {
  host: 'localhost',
  dialect: 'mssql',
  dialectOptions: {
    options: {
      encrypt: false,
      trustServerCertificate: true
    }
  },
  logging: false
});

const ApiProvider = sequelize.define('api_providers', {
  providerid: {
    type: DataTypes.INTEGER,
    primaryKey: true
  },
  brand_name: DataTypes.STRING,
  legal_name: DataTypes.STRING,
  legal_identification: DataTypes.STRING,
  enabled: DataTypes.BOOLEAN
}, {
  timestamps: false,
  tableName: 'api_providers'
});

module.exports = { sequelize, ApiProvider };

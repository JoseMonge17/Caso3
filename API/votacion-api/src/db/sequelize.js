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

async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log('Conexión exitosa a la base de datos.');
  } catch (error) {
    console.error('Error al conectar con la base de datos:', error.message);
  }
}
testConnection();

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



const UserStatus = sequelize.define('vpv_user_status', {
  statusid: { type: DataTypes.SMALLINT, primaryKey: true, autoIncrement: true },
  name:     { type: DataTypes.STRING(20), allowNull: false },
}, {
  tableName: 'vpv_user_status',
  timestamps: false,
});

const User = sequelize.define('vpv_users', {
  userid: {type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false,},
  username: {type: DataTypes.STRING(100), allowNull: false,},
  firstname: {type: DataTypes.STRING(100), allowNull: false,},
  lastname: {type: DataTypes.STRING(100), allowNull: false,},
  identification: {type: DataTypes.STRING(15), allowNull: false, },
  registered: {type: DataTypes.DATE, allowNull: false, },
  birthdate: {type: DataTypes.DATEONLY, allowNull: true, },
  email: {type: DataTypes.STRING(150), allowNull: false, validate: { isEmail: true }, unique: true, },
  password: {type: DataTypes.BLOB, allowNull: false, },
  statusid: { type: DataTypes.SMALLINT, allowNull: false,
    references: {
      model: UserStatus,
      key: 'statusid',
    }
  },
}, {
  tableName: 'vpv_users',
  timestamps: false,
});

User.belongsTo(UserStatus, { foreignKey: 'statusid', as: 'status' });


module.exports = { sequelize, ApiProvider, User, UserStatus };

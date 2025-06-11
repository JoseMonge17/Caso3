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

const UserDemographic = sequelize.define('vpv_user_demographics', {
  user_demographicid: { type: DataTypes.SMALLINT, primaryKey: true, autoIncrement: true },
  enabled: { type: DataTypes.BOOLEAN, allowNull: false },
  value: { type: DataTypes.STRING(50), allowNull: false },
  demographicid: { type: DataTypes.INTEGER, allowNull: false },
  userid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vpv_user_demographics',
  timestamps: false
});

// Criterio de votación
const VoteCriteria = sequelize.define('vote_criterias', {
  criteriaid: { type: DataTypes.TINYINT, primaryKey: true, autoIncrement: true },
  type: { type: DataTypes.STRING(50), allowNull: false },
  datatype: { type: DataTypes.STRING(200), allowNull: false },
  demographicid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vote_criterias',
  timestamps: false
});

const VoteSession = sequelize.define('vote_sessions', {
  sessionid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  startDate: { type: DataTypes.DATE, allowNull: false },
  endDate: { type: DataTypes.DATE, allowNull: false },
  public_key: { type: DataTypes.BLOB, allowNull: false },
  threshold: { type: DataTypes.TINYINT, allowNull: false },
  key_shares: { type: DataTypes.TINYINT, allowNull: false },
  sessionStatusid: { type: DataTypes.SMALLINT, allowNull: false },
  voteTypeid: { type: DataTypes.TINYINT, allowNull: false },
  visibilityid: { type: DataTypes.TINYINT, allowNull: false }
}, {
  tableName: 'vote_sessions',
  timestamps: false
});

const VotingRule = sequelize.define('vote_voting_criteria', {
  ruleid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  value: { type: DataTypes.STRING(75), allowNull: false },
  weight: { type: DataTypes.DECIMAL(5, 2), allowNull: false },
  enabled: { type: DataTypes.BOOLEAN, allowNull: false },
  sessionid: { type: DataTypes.INTEGER, allowNull: false },
  criteriaid: { type: DataTypes.TINYINT, allowNull: false }
}, {
  tableName: 'vote_voting_criteria',
  timestamps: false
});

const VoteElegibility = sequelize.define('vote_elegibility', {
  elegibilityid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  anonid: { type: DataTypes.UUID, allowNull: false },
  voted: { type: DataTypes.BOOLEAN, allowNull: false },
  registeredDate: { type: DataTypes.DATE},
  sessionid: { type: DataTypes.INTEGER, allowNull: false },
  userid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vote_elegibility',
  timestamps: false
});

const VoteBallot = sequelize.define('vote_ballots', {
  vote_registryid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  voteDate: { type: DataTypes.DATE },
  signature: { type: DataTypes.BLOB, allowNull: false },
  encryptedVote: { type: DataTypes.BLOB, allowNull: false },
  proof: { type: DataTypes.BLOB, allowNull: false },
  checksum: { type: DataTypes.BLOB, allowNull: false },
  anonid: { type: DataTypes.INTEGER, allowNull: false },
  sessionid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vote_ballots',
  timestamps: false
});

User.hasMany(VoteElegibility, {
  foreignKey: 'userid',
  as: 'eligibility'
});

VoteSession.hasMany(VoteElegibility, {
  foreignKey: 'sessionid',
  as: 'eligibility'
});

VotingRule.belongsTo(VoteCriteria, {
  foreignKey: 'criteriaid',
  as: 'criteria'
});

VotingRule.belongsTo(VoteSession, {
  foreignKey: 'sessionid',
  as: 'session'
});

module.exports = {
  sequelize,
  User,
  UserStatus,
  UserDemographic,
  VoteCriteria,
  VotingRule,
  VoteSession,
  VoteElegibility,
  VoteBallot
};


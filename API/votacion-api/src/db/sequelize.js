const { Sequelize, DataTypes } = require('sequelize');

const sequelize = new Sequelize('VotoPuraVida', 'votouser', 'YourStrong@Password', {
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

const VoteDemographicStat = sequelize.define('vote_demographic_stats', {
  statid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
  sum: { type: DataTypes.INTEGER, allowNull: false },
  value: { type: DataTypes.STRING(100), allowNull: false },
  demographicid: { type: DataTypes.INTEGER, allowNull: false },
  optionid: { type: DataTypes.TINYINT, allowNull: false }
}, {
  tableName: 'vote_demographic_stats',
  timestamps: false
});

const VoteCommitment = sequelize.define('vote_commitments', {
  commitmentid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
  value: { type: DataTypes.INTEGER, allowNull: false },
  sum: { type: DataTypes.INTEGER, allowNull: false },
  optionid: { type: DataTypes.TINYINT, allowNull: false }
}, {
  tableName: 'vote_commitments',
  timestamps: false
});

const AuthSession = sequelize.define('AuthSession', {
    sessionid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    device_id: { type: DataTypes.INTEGER, allowNull: true },
    start_date: { type: DataTypes.DATE, allowNull: false },
    last_activity_date: { type: DataTypes.DATE, allowNull: false },
    expiration_date: { type: DataTypes.DATE, allowNull: true },
    session_token_hash: { type: DataTypes.BLOB, allowNull: false },
    key_id: { type: DataTypes.INTEGER, allowNull: false },
  }, {
    tableName: 'vpv_auth_sessions',
    timestamps: false
  });

// vpv_roles
const Role = sequelize.define('Role', {
  roleid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  rolename: { type: DataTypes.STRING(30), allowNull: false },
  description: { type: DataTypes.STRING(70), allowNull: false },
  systemrole: { type: DataTypes.BOOLEAN, allowNull: false },
  asignationdate: { type: DataTypes.DATE, allowNull: false }
}, {
  tableName: 'vpv_roles',
  timestamps: false
});

// vpv_user_roles
const UserRole = sequelize.define('UserRole', {
  user_rolid: { type: DataTypes.SMALLINT, primaryKey: true, autoIncrement: true },
  enabled: { type: DataTypes.BOOLEAN, allowNull: false },
  roleid: { type: DataTypes.INTEGER, allowNull: false },
  userid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vpv_user_roles',
  timestamps: false
});

// vpv_permissions
const Permission = sequelize.define('Permission', {
  permissionid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  permissioncode: { type: DataTypes.STRING(10), allowNull: false },
  description: { type: DataTypes.STRING(70), allowNull: false },
  htmlObject: { type: DataTypes.STRING(100), allowNull: false },
  moduleid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vpv_permissions',
  timestamps: false
});

// vpv_rolepermissions
const RolePermission = sequelize.define('RolePermission', {
  userrolesid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  asignationdate: { type: DataTypes.DATE, allowNull: false },
  checksum: { type: DataTypes.BLOB, allowNull: false },
  enable: { type: DataTypes.BOOLEAN, allowNull: false },
  deleted: { type: DataTypes.BOOLEAN, allowNull: false },
  lastupdate: { type: DataTypes.DATE, allowNull: false },
  roleid: { type: DataTypes.INTEGER, allowNull: false },
  permissionid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vpv_rolepermissions',
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

User.hasMany(UserRole, { foreignKey: 'userid' });
UserRole.belongsTo(User, { foreignKey: 'userid' });

UserRole.belongsTo(Role, { foreignKey: 'roleid' });
Role.hasMany(UserRole, { foreignKey: 'roleid' });

Role.hasMany(RolePermission, { foreignKey: 'roleid' });
RolePermission.belongsTo(Role, { foreignKey: 'roleid' });

Permission.hasMany(RolePermission, { foreignKey: 'permissionid' });
RolePermission.belongsTo(Permission, { foreignKey: 'permissionid' });


module.exports = {
  sequelize,
  User,
  VoteCommitment,
  UserStatus,
  UserDemographic,
  VoteCriteria,
  VotingRule,
  VoteSession,
  VoteElegibility,
  VoteBallot,
  VoteDemographicStat,
  AuthSession,
  UserRole, 
  Role, 
  RolePermission, 
  Permission,
};

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

const { DATE } = require('sequelize');
DATE.prototype._stringify = function _stringify(date, options) {
  date = this._applyTimezone(date, options);
  return date.format('YYYY-MM-DD HH:mm:ss.SSS'); // ✅ sin +00:00
};

async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log('Conexión exitosa a la base de datos.');
  } catch (error) {
    console.error('Error al conectar con la base de datos:', error.message);
  }
}
testConnection();

//Tablas relacionadas con logs
const VpvLog = sequelize.define('vpv_logs', {
    logid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    description: { type: DataTypes.STRING(200), allowNull: false },
    posttime: { type: DataTypes.DATE, allowNull: false },
    computer: { type: DataTypes.STRING(100), allowNull: false },
    trace: { type: DataTypes.TEXT, allowNull: false },
    reference_id1: { type: DataTypes.BIGINT, allowNull: true },
    reference_id2: { type: DataTypes.BIGINT, allowNull: true },
    value1: { type: DataTypes.STRING(180), allowNull: true },
    value2: { type: DataTypes.STRING(180), allowNull: true },
    checksum: { type: DataTypes.STRING(45), allowNull: false },
    log_typeid: { type: DataTypes.INTEGER, allowNull: false },
    log_sourceid: { type: DataTypes.INTEGER, allowNull: false },
    log_severityid: { type: DataTypes.INTEGER, allowNull: false }
}, {
    tableName: 'vpv_logs',
    timestamps: false
});

//Tablas relacionadas con el usuario
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

const UserRole = sequelize.define('UserRole', {
  user_rolid: { type: DataTypes.SMALLINT, primaryKey: true, autoIncrement: true },
  enabled: { type: DataTypes.BOOLEAN, allowNull: false },
  roleid: { type: DataTypes.INTEGER, allowNull: false },
  userid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vpv_user_roles',
  timestamps: false
});

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

const UserKey = sequelize.define('UserKey', {
  key_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  userid: { type: DataTypes.INTEGER, allowNull: false },
  algorithm: { type: DataTypes.STRING(50), allowNull: false },
  creation_date: { type: DataTypes.DATE, allowNull: false },
  key_status: { type: DataTypes.STRING(20), allowNull: false },
  key_usage: { type: DataTypes.STRING(20), allowNull: false },
  public_key: { type: DataTypes.BLOB, allowNull: false }
}, {
  tableName: 'vpv_user_keys',
  timestamps: false
});

// MFA
const AuthMethod = sequelize.define('vpv_auth_methods', {
  method_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  userid: { type: DataTypes.INTEGER, allowNull: false },
  device_id: { type: DataTypes.INTEGER, allowNull: true },
  method_type: { type: DataTypes.STRING(50), allowNull: false },
  identifier_hash: { type: DataTypes.STRING(255), allowNull: false },
  registration_date: { type: DataTypes.DATE, allowNull: false },
  last_used_date: { type: DataTypes.DATE, allowNull: true },
  method_status: { type: DataTypes.STRING(20), allowNull: false },
  priority: { type: DataTypes.INTEGER, allowNull: false },
  is_primary: { type: DataTypes.BOOLEAN, allowNull: false }
}, {
  tableName: 'vpv_auth_methods',
  timestamps: false
});

const MFADevice = sequelize.define('vpv_mfa_devices', {
  deviceid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  userid: { type: DataTypes.INTEGER, allowNull: false },
  device_name: { type: DataTypes.STRING(50), allowNull: false },
  registration_date: { type: DataTypes.DATE, allowNull: false },
  last_used_date: { type: DataTypes.DATE, allowNull: true },
  device_status: { type: DataTypes.STRING(20), allowNull: false },
  serial_hash: { type: DataTypes.BLOB, allowNull: false },
  authentication_factor: { type: DataTypes.STRING(50), allowNull: false }
}, {
  tableName: 'vpv_mfa_devices',
  timestamps: false
});

const MFACode = sequelize.define('vpv_mfa_codes', {
  code_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  method_id: { type: DataTypes.INTEGER, allowNull: false },
  device_id: { type: DataTypes.INTEGER, allowNull: true },
  code_hash: { type: DataTypes.BLOB, allowNull: false },
  generation_date: { type: DataTypes.DATE, allowNull: false },
  expiration_date: { type: DataTypes.DATE, allowNull: false },
  remaining_attempts: { type: DataTypes.INTEGER, allowNull: false },
  code_status: { type: DataTypes.STRING(20), allowNull: false },
  request_context: { type: DataTypes.STRING(255), allowNull: true },
  request_ip_hash: { type: DataTypes.BLOB, allowNull: true },
  request_device_hash: { type: DataTypes.BLOB, allowNull: true }
}, {
  tableName: 'vpv_mfa_codes',
  timestamps: false
});

// Pruebas de vida
const VpvBiometricMedia = sequelize.define('vpv_biometric_media', {
  biomediaid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  filename: { type: DataTypes.STRING(100), allowNull: false },
  storage_url: { type: DataTypes.STRING(255), allowNull: false },
  file_size: { type: DataTypes.INTEGER, allowNull: false },
  uploaddate: { type: DataTypes.DATE, allowNull: false },
  hashvalue: { type: DataTypes.BLOB, allowNull: false },
  encryption_key_id: { type: DataTypes.STRING(255), allowNull: false },
  is_original: { type: DataTypes.BOOLEAN, allowNull: false },
  userid: { type: DataTypes.INTEGER, allowNull: false },
  biotypeid: { type: DataTypes.INTEGER, allowNull: false },
  mediatypeid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vpv_biometric_media',
  timestamps: false
});

const VpvLivenessCheck = sequelize.define('vpv_livenesschecks', {
  livenessid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  check_type: { type: DataTypes.STRING(50), allowNull: false },
  check_date: { type: DataTypes.DATE, allowNull: false },
  result: { type: DataTypes.BOOLEAN, allowNull: false },
  confidence_score: { type: DataTypes.DECIMAL(5, 2), allowNull: false },
  algorithm_used: { type: DataTypes.STRING(100), allowNull: false },
  device_info: { type: DataTypes.STRING(200), allowNull: false },
  userid: { type: DataTypes.INTEGER, allowNull: false },
  requestid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vpv_livenesschecks',
  timestamps: false
});

const VpvLivenessCheckMedia = sequelize.define('vpv_livenesschecks_media', {
  livemediaid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  livenessid: { type: DataTypes.INTEGER, allowNull: false },
  biomediaid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vpv_livenesschecks_media',
  timestamps: false
});

//Tablas relacionadas con propuestas
const CfProposalVote = sequelize.define('cf_proposal_votes', {
    proposal_voteid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    date: { type: DataTypes.DATE, allowNull: false },
    result: { type: DataTypes.BOOLEAN, allowNull: false },
    sessionid: { type: DataTypes.INTEGER, allowNull: false },
    proposalid: { type: DataTypes.INTEGER, allowNull: false }
}, {
    tableName: 'cf_proposal_votes',
    timestamps: false
});

const VpvProposal = sequelize.define('vpv_proposal', {
    proposalid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false },
    enabled: { type: DataTypes.BOOLEAN, allowNull: false },
    current_version: { type: DataTypes.INTEGER, allowNull: false },
    description: { type: DataTypes.STRING(255), allowNull: false },
    submission_date: { type: DataTypes.DATE, allowNull: false },
    version: { type: DataTypes.INTEGER, allowNull: false },
    origin_typeid: { type: DataTypes.INTEGER, allowNull: false },
    userid: { type: DataTypes.INTEGER, allowNull: false },
    statusid: { type: DataTypes.INTEGER, allowNull: false },
    proposal_typeid: { type: DataTypes.INTEGER, allowNull: false },
    entityid: { type: DataTypes.INTEGER, allowNull: false },
    allows_comments: { type: DataTypes.BOOLEAN, allowNull: false}
}, {
    tableName: 'vpv_proposal',
    timestamps: false
});

const VpvProposalComment = sequelize.define('vpv_proposal_comments', {
  commentid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  userid: { type: DataTypes.INTEGER, allowNull: false },
  proposalid: { type: DataTypes.INTEGER, allowNull: false },
  content: { type: DataTypes.TEXT, allowNull: false },
  created_at: { type: DataTypes.DATE, allowNull: false },
  status: { type: DataTypes.STRING(20), allowNull: false }, // Pendiente, Aprobado, Rechazado
  integrity_hash: { type: DataTypes.STRING(100), allowNull: false }
}, {
  tableName: 'vpv_proposal_comments',
  timestamps: false
});

const VpvDigitalDocument = sequelize.define('vpv_digital_documents', {
  documentid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  filename: { type: DataTypes.STRING(100), allowNull: false },
  storage_url: { type: DataTypes.STRING(255), allowNull: false },
  filesize: { type: DataTypes.INTEGER, allowNull: false },
  uploaded_at: { type: DataTypes.DATE, allowNull: false },
  uploaded_by: { type: DataTypes.INTEGER, allowNull: false },
  requestid: { type: DataTypes.INTEGER, allowNull: true } // se hizo nullable por decisión tuya
}, {
  tableName: 'vpv_digital_documents',
  timestamps: false
});

const VpvProposalDocumentComment = sequelize.define('vpv_proposal_documents_comments', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  proposalid: { type: DataTypes.INTEGER, allowNull: false },
  documentid: { type: DataTypes.INTEGER, allowNull: false },
  linked_at: { type: DataTypes.DATE, allowNull: false }
}, {
  tableName: 'vpv_proposal_documents_comments',
  timestamps: false
});


// Tablas relacionadas con votos
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
  proof: { type: DataTypes.BLOB, allowNull: true },
  checksum: { type: DataTypes.BLOB, allowNull: false },
  anonid: { type: DataTypes.INTEGER, allowNull: false },
  sessionid: { type: DataTypes.INTEGER, allowNull: false },
  userid: { type: DataTypes.INTEGER, allowNull: true }
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

const VoteBackup = sequelize.define('vote_backup', {
  backupid: { type: DataTypes.TINYINT, primaryKey: true, autoIncrement: true },
  register: { type: DataTypes.TEXT, allowNull: false }
}, {
  tableName: 'vote_backup',
  timestamps: false
});

const VoteQuestion = sequelize.define('vote_questions', {
    questionid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    description: { type: DataTypes.STRING(200), allowNull: false },
    required: { type: DataTypes.BOOLEAN, allowNull: false },
    max_answers: { type: DataTypes.SMALLINT, allowNull: false },
    createDate: { type: DataTypes.DATE, allowNull: false },
    updateDate: { type: DataTypes.DATE },
    question_typeid: { type: DataTypes.SMALLINT, allowNull: false },
    sessionid: { type: DataTypes.INTEGER, allowNull: false }
}, { tableName: 'vote_questions', timestamps: false });

const VoteOption = sequelize.define('vote_options', {
    optionid: { type: DataTypes.TINYINT, primaryKey: true, autoIncrement: true },
    description: { type: DataTypes.STRING(200), allowNull: false },
    value: { type: DataTypes.STRING(100), allowNull: false },
    url: { type: DataTypes.STRING(250), allowNull: false },
    order: { type: DataTypes.TINYINT, allowNull: false },
    checksum: { type: DataTypes.BLOB, allowNull: false },
    createDate: { type: DataTypes.DATE, allowNull: false },
    updateDate: { type: DataTypes.DATE },
    questionid: { type: DataTypes.INTEGER, allowNull: false }
}, { tableName: 'vote_options', timestamps: false });

const VpvDemographicData = sequelize.define('vpv_demographic_data', {
    demographicid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    code: { type: DataTypes.STRING(10), allowNull: false },
    description: { type: DataTypes.STRING(100), allowNull: false },
    demographic_typeid: { type: DataTypes.TINYINT, allowNull: false }
  }, {
    tableName: 'vpv_demographic_data',
    timestamps: false
  });


const VoteRule = sequelize.define('vote_rules', {
  ruleid: { type: DataTypes.TINYINT, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING(50), allowNull: false },
  dataType: { type: DataTypes.STRING(50), allowNull: false }
}, { tableName: 'vote_rules', timestamps: false });

const VoteAcceptanceRule = sequelize.define('vote_acceptance_rules', {
    acceptance_ruleid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    quantity: { type: DataTypes.INTEGER, allowNull: false },
    description: { type: DataTypes.STRING(100), allowNull: false },
    enabled: { type: DataTypes.BOOLEAN, allowNull: false },
    sessionid: { type: DataTypes.INTEGER, allowNull: false },
    rule_typeid: { type: DataTypes.TINYINT, allowNull: false }
  }, { tableName: 'vote_acceptance_rules', timestamps: false });

const VpvWhitelist = sequelize.define('VpvWhitelist', {
    whitelistid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    initial_IP: { type: DataTypes.STRING, allowNull: false },
    end_IP: { type: DataTypes.STRING, allowNull: false },
    countryid: { type: DataTypes.INTEGER, allowNull: false },
    allowed: { type: DataTypes.BOOLEAN, allowNull: false },
  }, {
    tableName: 'vpv_whitelist',
    timestamps: false,
  });

const VoteSessionIpPermission = sequelize.define('VoteSessionIpPermission', {
    permissionid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    sessionid: { type: DataTypes.INTEGER, allowNull: false },
    whitelistid: { type: DataTypes.INTEGER, allowNull: false },
    allowed: { type: DataTypes.BOOLEAN, allowNull: false },
    created_date: { type: DataTypes.DATE, allowNull: false, defaultValue: sequelize.fn('getdate') }
  }, { tableName: 'vote_session_ip_permissions', timestamps: false });


const VoteSessionTimeRestriction = sequelize.define('VoteSessionTimeRestriction', {
    restrictionid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
    sessionid: { type: DataTypes.INTEGER, allowNull: false },
    start_time: { 
      type: DataTypes.TIME, 
      allowNull: false,
      get() { return this.getDataValue('start_time') ? this.getDataValue('start_time').toISOString().substring(11, 19) : null; }
    },
    end_time: { 
      type: DataTypes.TIME, 
      allowNull: false,
      get() { return this.getDataValue('end_time') ? this.getDataValue('end_time').toISOString().substring(11, 19) : null; }
    },
    day_of_week: { type: DataTypes.INTEGER, allowNull: false },
  }, { tableName: 'vote_session_time_restrictions', timestamps: false });

VpvProposal.associate = models => {
    VpvProposal.hasMany(models.cf_proposal_votes, { foreignKey: 'proposalid' });
};

const VpvCountry = sequelize.define('VpvCountry', {
  countryid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
  name: { type: DataTypes.STRING(60), allowNull: false },
  codeISO: { type: DataTypes.STRING(3), allowNull: false },
  register_enable: { type: DataTypes.BOOLEAN, allowNull: false }
}, { tableName: 'vpv_countries', timestamps: false });

const VpvState = sequelize.define('VpvState', {
  stateid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
  name: { type: DataTypes.STRING(60), allowNull: false },
  countryid: { type: DataTypes.INTEGER, allowNull: false }
}, { tableName: 'vpv_states', timestamps: false });


const VpvCity = sequelize.define('VpvCity', {
  cityid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
  name: { type: DataTypes.STRING(60), allowNull: false },
  stateid: { type: DataTypes.INTEGER, allowNull: false }
}, { tableName: 'vpv_cities', timestamps: false });

const VpvAddress = sequelize.define('VpvAddress', {
  addressid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
  line1: { type: DataTypes.STRING(200), allowNull: false },
  line2: { type: DataTypes.STRING(200), allowNull: false },
  zipcode: { type: DataTypes.STRING(9), allowNull: false },
  location: { type: DataTypes.GEOGRAPHY, allowNull: false },
  cityid: { type: DataTypes.INTEGER, allowNull: false }
}, { tableName: 'vpv_address', timestamps: false });
  
const VpvAddressAssignment = sequelize.define('VpvAddressAssignment', {
  asignationid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
  entitytype: { type: DataTypes.STRING(60), allowNull: false },
  entityid: { type: DataTypes.INTEGER },
  addressid: { type: DataTypes.INTEGER, allowNull: false },
  userid: { type: DataTypes.INTEGER }
}, { tableName: 'vpv_addressasignations', timestamps: false });

const VpvImpactZone = sequelize.define('VpvImpactZone', {
  zoneid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING(100), allowNull: false },
  zone_typeid: { type: DataTypes.INTEGER, allowNull: false }
}, {
  tableName: 'vpv_impact_zone',
  timestamps: false
});

const VpvProposalImpactZone = sequelize.define('VpvProposalImpactZone', {
  proposal_impactid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  proposalid: { type: DataTypes.INTEGER, allowNull: false },
  zoneid: { type: DataTypes.INTEGER, allowNull: false },
  impact_levelid: { type: DataTypes.INTEGER, allowNull: false },
  description: { type: DataTypes.STRING(255), allowNull: true }
}, {
  tableName: 'vpv_proposal_impact_zones',
  timestamps: false
});

//Tablas de validacion
const VpvValidationRequest = sequelize.define('vpv_validation_request', {
    requestid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    creation_date: { type: DataTypes.DATE, allowNull: false },
    finish_date: { type: DataTypes.DATE, allowNull: true },
    global_result: { type: DataTypes.TEXT, allowNull: true },
    userid: { type: DataTypes.INTEGER, allowNull: false },
    validation_typeid: { type: DataTypes.INTEGER, allowNull: false }
}, {
    tableName: 'vpv_validation_request',
    timestamps: false
});

const VpvValidationType = sequelize.define('vpv_validation_types', {
    validation_typeid: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false }
}, {
    tableName: 'vpv_validation_types',
    timestamps: false
});


//Relaciones entre tablas
VpvProposalImpactZone.belongsTo(VpvImpactZone, { foreignKey: 'zoneid' });
VpvProposalImpactZone.belongsTo(VpvProposal, { foreignKey: 'proposalid' });

VpvState.belongsTo(sequelize.models.VpvCountry, { foreignKey: 'countryid' });

VpvCity.belongsTo(sequelize.models.VpvState, { foreignKey: 'stateid' });

VpvAddress.belongsTo(sequelize.models.VpvCity, { foreignKey: 'cityid' });

VpvAddressAssignment.belongsTo(sequelize.models.VpvAddress, { foreignKey: 'addressid' });

VpvLivenessCheck.hasMany(VpvLivenessCheckMedia, { foreignKey: 'livenessid' });
VpvBiometricMedia.hasMany(VpvLivenessCheckMedia, { foreignKey: 'biomediaid' });

VpvLivenessCheckMedia.belongsTo(VpvLivenessCheck, { foreignKey: 'livenessid' });
VpvLivenessCheckMedia.belongsTo(VpvBiometricMedia, { foreignKey: 'biomediaid' });

User.hasMany(MFADevice, { foreignKey: 'userid' });
User.hasMany(AuthMethod, { foreignKey: 'userid' });

MFADevice.belongsTo(User, { foreignKey: 'userid' });
MFADevice.hasMany(AuthMethod, { foreignKey: 'device_id' });
MFADevice.hasMany(MFACode, { foreignKey: 'device_id' });

AuthMethod.belongsTo(User, { foreignKey: 'userid' });
AuthMethod.belongsTo(MFADevice, { foreignKey: 'device_id' });
AuthMethod.hasMany(MFACode, { foreignKey: 'method_id' });

MFACode.belongsTo(AuthMethod, { foreignKey: 'method_id' });
MFACode.belongsTo(MFADevice, { foreignKey: 'device_id' });

VoteSessionIpPermission.belongsTo(sequelize.models.VpvWhitelist, {
  foreignKey: 'whitelistid',
  targetKey: 'whitelistid'
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

User.hasMany(UserKey, { foreignKey: 'userid' });
UserKey.belongsTo(User, { foreignKey: 'userid' });

VpvProposalComment.belongsTo(User, { foreignKey: 'userid' });
VpvProposalComment.belongsTo(VpvProposal, { foreignKey: 'proposalid' });

VpvDigitalDocument.belongsTo(User, { foreignKey: 'uploaded_by' });
VpvDigitalDocument.belongsTo(VpvValidationRequest, { foreignKey: 'requestid' }); //Permite NULL

VpvValidationRequest.belongsTo(VpvValidationType, { foreignKey: 'validation_typeid' });
VpvValidationRequest.belongsTo(User, { foreignKey: 'userid' });

VpvProposalDocumentComment.belongsTo(VpvProposal, { foreignKey: 'proposalid' });
VpvProposalDocumentComment.belongsTo(VpvDigitalDocument, { foreignKey: 'documentid' });

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
  UserKey,
  MFACode,
  AuthMethod,
  MFADevice,
  VpvBiometricMedia,
  VpvLivenessCheck,
  VpvLivenessCheckMedia,
  VoteBackup,
  VoteQuestion,
  VoteOption,
  VpvLog,
  CfProposalVote,
  VpvProposal,
  VpvDemographicData,
  VoteRule,
  VoteAcceptanceRule,
  VpvWhitelist,
  VoteSessionIpPermission,
  VoteSessionTimeRestriction,
  VpvCountry,
  VpvState,
  VpvCity,
  VpvAddress,
  VpvAddressAssignment,
  VpvImpactZone,
  VpvProposalImpactZone,
  VpvValidationRequest,
  VpvValidationType,
  VpvProposalComment,
  VpvDigitalDocument,
  VpvProposalDocumentComment,
};

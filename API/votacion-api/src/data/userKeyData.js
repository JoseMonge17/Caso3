const { UserKey } = require('../db/sequelize');

async function findPublicKeyById(key_id) {
  const record = await UserKey.findOne({
    where: { key_id }
  });

  if (!record) return null;

  return {
    keyId: record.key_id,
    publicKey: record.public_key,
    algorithm: record.algorithm
  };
}

module.exports = { findPublicKeyById };
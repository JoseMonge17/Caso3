const crypto = require('crypto');
const { AuthSession } = require('../db/sequelize');
const { Op } = require('sequelize');

async function findByToken(token) {
  const hashedToken = crypto.createHash('sha256').update(token).digest(); // ← esto genera el mismo hash que HASHBYTES('SHA2_256')
    console.log('Hash generado:', hashedToken.toString('hex'));

  return await AuthSession.findOne({
    where: {
      session_token_hash: {
        [Op.eq]: hashedToken
      }
    }
  });
}

module.exports = { findByToken };
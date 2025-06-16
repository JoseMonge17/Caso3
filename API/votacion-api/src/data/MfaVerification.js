const { MFACode, AuthMethod } = require('../db/sequelize');
const { Op } = require('sequelize');
const crypto = require('crypto');

async function verifyMfaCode(method_id, code) {
    const hashedCode = crypto.createHash('sha256').update(code).digest();

    const record = await MFACode.findOne({
        where: {
        method_id,
        code_hash: hashedCode,
        code_status: 'PENDING',
        remaining_attempts: { [Op.gt]: 0 }
        }
    });

    if (!record) {
        return { authenticated: false, error: 'Código inválido o expirado' };
    }

    // Código válido, actualizar status
    //record.code_status = 'VERIFIED';
    await record.save();

    return { authenticated: true, message: 'Autenticación MFA completada' };
}

module.exports = {
  verifyMfaCode
};
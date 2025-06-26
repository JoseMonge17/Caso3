const { MFACode, AuthMethod } = require('../db/sequelize');
const { Op } = require('sequelize');
const crypto = require('crypto');

async function verifyMfaCode(method_id, code)
{
    //Encriptación del código brindado
    const hashedCode = crypto.createHash('sha256').update(code).digest();

    //Busca por medio del código y el método de MFA si lo puede verificar
    const record = await MFACode.findOne({
        where: {
            method_id,
            code_hash: hashedCode,
            code_status: 'PENDING',
            remaining_attempts: { [Op.gt]: 0 } //Op es un operador de sequelize //Op.gt significa mayor que, por lo tanto busca algún registro que en ese campo sea mayor que cero.
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
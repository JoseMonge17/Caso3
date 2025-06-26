const { VpvLog } = require('../db/sequelize');
const crypto = require('crypto');

async function insertLog(description, computer, trace, userid, value1, log_typeid, log_sourceid, log_severityid) 
{
    try {
        const hash = crypto.createHash('sha256');
        hash.update(Buffer.from(description || ''));
        hash.update(Buffer.from(trace || ''));
        hash.update(Buffer.from(value1 || ''));
        hash.update(Buffer.from(userid?.toString() || ''));
        hash.update(Buffer.from(log_typeid.toString()));
        hash.update(Buffer.from(log_sourceid.toString()));
        hash.update(Buffer.from(log_severityid.toString()));
        hash.update(Buffer.from('VotoPuraVidaCheckSumLog'));

        const checksum = hash.digest();
        
        await VpvLog.create(
        {
            description,
            posttime: new Date(),
            computer,
            trace,
            reference_id1: userid,
            value1,
            checksum,
            log_typeid,
            log_sourceid,
            log_severityid
        });
    } catch (error) {
        console.error('Error al insertar log:', error.message);
    }
}

module.exports = { insertLog };
const { VpvBiometricMedia, VpvLivenessCheck, VpvLivenessCheckMedia, sequelize } = require('../db/sequelize');

async function saveLivenessData(payload, biometricMedia, userid) {
    try 
    {
        const result = await sequelize.transaction(async (t) => 
        {
            // Crear el registro de liveness
            const liveness = await VpvLivenessCheck.create({
                check_type: payload.check_type,
                check_date: new Date(payload.check_date),
                result: payload.result,
                confidence_score: payload.confidence_score,
                algorithm_used: payload.algorithm_used,
                device_info: payload.device_info,
                userid: userid,
                requestid: payload.requestid
            }, { transaction: t });

            // Crear y asociar los registros y media biométricos
            for (const media of biometricMedia) 
            {
                const mediaRecord = await VpvBiometricMedia.create({
                    filename: media.filename,
                    storage_url: media.storage_url,
                    file_size: media.file_size,
                    uploaddate: new Date(media.uploaddate),
                    hashvalue: Buffer.from(media.hashvalue, 'hex'),
                    encryption_key_id: media.encryption_key_id,
                    is_original: media.is_original,
                    userid: userid,
                    biotypeid: media.biotypeid,
                    mediatypeid: media.mediatypeid
                }, { transaction: t });

                await VpvLivenessCheckMedia.create({
                    livenessid: liveness.livenessid,
                    biomediaid: mediaRecord.biomediaid
                }, { transaction: t });
            }

            return { success: true, message: 'Datos de liveness guardados correctamente' };
        });

        return result;

    } catch (error) {
        console.error('Error en transacción de liveness:', error);
        return { success: false, error: error.message };
    }
}

module.exports = {
  saveLivenessData
};

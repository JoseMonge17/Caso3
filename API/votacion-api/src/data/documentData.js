const { VpvValidationRequest, VpvValidationType } = require('../db/sequelize');

/**
 * Simula un proceso de validación automática (como si lo hiciera Airflow)
 * @param {int} userid - Objeto con los datos del documento
 * @returns {Promise<{ success: boolean, global_result: string }>}
 */
async function workflow({ userid }) {
    const validation_typeid = await getValidationTypeIdByName('Validación de documento');

    const request = await VpvValidationRequest.create({
        creation_date: new Date(),
        userid,
        validation_typeid
    });

    //await new Promise(resolve => setTimeout(resolve, 1000));

    await request.update({
        finish_date: new Date(),
        global_result: 'Éxito'
    });

    return {
        success: true,
        global_result: 'Éxito'
    };
}

/**
 * Busca el ID de un tipo de validación por su nombre
 * @param {string} name - Nombre del tipo de validación
 * @returns {Promise<number>} - ID del tipo de validación
 */
async function getValidationTypeIdByName(name) {
    const type = await VpvValidationType.findOne({
        where: { name }
    });

    if (!type) throw new Error(`Tipo de validación no encontrado: '${name}'`);

    return type.validation_typeid;
}

module.exports = {
    getValidationTypeIdByName,
    workflow
};
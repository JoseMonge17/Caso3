const { VpvValidationRequest, VpvValidationType } = require('../db/sequelize');

/**
 * Simula un proceso de validación automática (como si lo hiciera Airflow)
 * @param {int} userid - Objeto con los datos del documento
 * @returns {Promise<{ success: boolean, global_result: string }>}
 */
async function workflow(userid, transaction) {

    const validation_typeid = await getValidationTypeIdByName('Validación de comentario'); // Tipo de validacion especifico

    console.log
    const request = await VpvValidationRequest.create({
        creation_date: new Date(),
        userid,
        validation_typeid
    }, { transaction });

    //await new Promise(resolve => setTimeout(resolve, 1000));

    await request.update({
        finish_date: new Date(),
        global_result: 'Éxito'
    }, { transaction });

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
async function getValidationTypeIdByName(name) {  // Input: validacion de comentario (esta en el llenado)
    const type = await VpvValidationType.findOne({ // Encuentra el primero
        where: { name }
    });

    if (!type) throw new Error(`Tipo de validación no encontrado: '${name}'`); 

    return type.validation_typeid; // nulo en el caso de no encontrar
}

module.exports = {
    getValidationTypeIdByName,
    workflow
};
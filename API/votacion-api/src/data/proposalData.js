const { VpvProposal } = require('../db/sequelize');

/**
 * Obtiene una propuesta por su ID primario
 * @param {number} proposalid - ID de la propuesta
 * @returns {Promise<Object|null>} - Propuesta encontrada o null
 */
async function getProposalById(proposalid) {
    return await VpvProposal.findByPk(proposalid);
}

module.exports = {
    getProposalById
};

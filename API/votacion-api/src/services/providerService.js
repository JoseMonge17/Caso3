const { fetchProvidersFromSP } = require('../data/providerData');
const { getUserFromToken } = require('../auth');

async function getProvidersBySP() {
     // validaciones o lógica adicional
    const tokenPayload = getUserFromToken(event);

    return await fetchProvidersFromSP();
}

module.exports = { getProvidersBySP };
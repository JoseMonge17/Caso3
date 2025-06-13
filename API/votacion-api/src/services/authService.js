const { findById} = require('../data/authUserData');

async function getUser(userId) 
{
    const user = await findById(userId);

    // Confirmar existencia activa del ciudadano en el sistema
    if (!user) throw new Error('Usuario no encontrado');

    //      Validar estado
    if (user.status.name !== "Activo") {
        throw new Error(`Usuario en estado '${user.status.name}'`);
    }
    
    return user;
}


module.exports = { getUser };
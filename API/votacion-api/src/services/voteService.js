const { findById } = require('../data/authUserData');
const { getUserFromToken } = require('../auth');

async function vote(event) 
{
    const tokenPayload = getUserFromToken(event);

    const user = await findById(tokenPayload.id);
    
    if (!user) throw new Error('Usuario no encontrado');

    // validar estado
    if (user.status.name !== "Activado") {
        throw new Error(`Usuario en estado '${user.status.name}'`);
    }


    return { userid: user.userid, username: user.username};
}

module.exports = { vote };
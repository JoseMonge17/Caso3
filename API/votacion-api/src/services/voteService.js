const { findByUsername } = require('../data/authUserData');

async function vote({usuario}) 
{
    const user = await findByUsername(usuario.username);
    if (!user) throw new Error('Usuario no encontrado');

    // validar estado
    if (user.status.name !== "Activado") {
        throw new Error(`Usuario en estado '${user.status.name}'`);
    }


    return { userid: user.userid, username: user.username};
}

module.exports = { vote };
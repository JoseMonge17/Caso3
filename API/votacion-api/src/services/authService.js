const { findById} = require('../data/authUserData');
const { findByToken } = require('../data/authSessionData');
const { findByUserId: findPermissionsByUser } = require('../data/permissionsData');
const { findPublicKeyById } = require('../data/userKeyData');

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

async function getSessionByToken(token) 
{
  const tokenBuffer = Buffer.from(token, 'utf8'); // Asegúrate de usar el mismo formato de codificación que al guardar
  console.log(tokenBuffer);
  const session = await findByToken(tokenBuffer);

  if (!session) throw new Error('Sesión no encontrada');

  return session;
}

async function getPermissionsByUser(userId) 
{
  const permissions = await findPermissionsByUser(userId);

  if (!permissions || permissions.length === 0) {
    console.warn('Usuario sin permisos asignados');
    return [];
  }

  return permissions;
}

async function getUserKeyById(key_id) 
{
  const key = await findPublicKeyById(key_id);

  if (!key) {
    throw new Error('Public key no encontrada para key_id: ' + key_id);
  }

  return key;
}

module.exports = { 
    getUser,
    getSessionByToken,
    getPermissionsByUser,
    getUserKeyById };
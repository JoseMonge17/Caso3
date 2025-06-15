const { UserRole, RolePermission, Permission, Role } = require('../db/sequelize');
const { Op } = require('sequelize');

async function findByUserId(userid) {
  const userRoles = await UserRole.findAll({
    where: { userid, enabled: true },
    include: [{
      model: Role,
      include: [{
        model: RolePermission,
        where: { enable: true, deleted: false },
        include: [Permission]
      }]
    }]
  });

  // Extraer los permisos y devolverlos como array plano
  const permissions = [];
  userRoles.forEach(userRole => {
    const rolePermissions = userRole.Role.RolePermissions;
    rolePermissions.forEach(rp => {
      if (rp.Permission) {
        permissions.push({
          id: rp.Permission.permissionid,
          code: rp.Permission.permissioncode,
          description: rp.Permission.description,
          htmlObject: rp.Permission.htmlObject
        });
      }
    });
  });

  return permissions;
}

module.exports = { findByUserId };
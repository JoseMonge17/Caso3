const { sequelize, User, UserStatus } = require('../db/sequelize');

async function findById(userid) 
{
    return await User.findByPk(userid, 
    {
        include: [{ model: UserStatus, as: 'status' }]
    });
}

module.exports = { findById };
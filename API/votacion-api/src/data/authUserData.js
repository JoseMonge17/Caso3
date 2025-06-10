const { sequelize, User, UserStatus } = require('../db/sequelize');

async function findByUsername(username) 
{
    return await User.findOne({
        where: { username },
        include: [{ model: UserStatus, as: 'status' }]
    });
}

module.exports = { findByUsername };
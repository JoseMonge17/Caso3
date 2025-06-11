const { User, UserStatus, UserDemographic } = require('../db/sequelize');

async function findById(userid) 
{
    return await User.findByPk(userid, 
    {
        include: [{ model: UserStatus, as: 'status' }]
    });
}

async function getDemographicData(userid) 
{
    return await UserDemographic.findAll(
    {
        where: { userid, enabled: true }
    });
}

module.exports = { findById, getDemographicData, };
const { User, UserStatus, UserDemographic } = require('../db/sequelize');
const { Op } = require('sequelize');

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

async function getIdUsers (directList)
{
    const users = await User.findAll({
        where: {
            [Op.or]: directList.map(item => ({
                [Op.and]: [
                { username: item.username },
                { identification: item.identification }
                ]
            }))
        },
        attributes: ['userid'],
    });

    const userIds = users.map(user => user.userid);

    return userIds;
};

module.exports = { findById, getDemographicData, getIdUsers };
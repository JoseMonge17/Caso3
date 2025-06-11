const { VotingRule, VoteCriteria, VoteSession, VoteElegibility } = require('../db/sequelize');

async function getVotingRulesForSession(sessionid) {
    return await VotingRule.findAll({
        where: { sessionid, enabled: true },
        include: [{ model: VoteCriteria, as: 'criteria' }]
    });
}

async function getSessionById(sessionid) {
    return await VoteSession.findByPk(sessionid);
}

async function hasUserVoted(userid, sessionid) {
    const record = await VoteElegibility.findOne({
        where: { userid, sessionid }
    });

    return record;
}

module.exports = {
    getVotingRulesForSession,
    getSessionById,
    hasUserVoted
};

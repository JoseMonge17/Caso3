const { VotingRule, VoteCriteria, VoteSession, VoteElegibility, VoteBallot } = require('../db/sequelize');
const crypto = require('crypto');

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

async function registerEncryptedVote({ sessionid, eligibility, encryptedVote, signature, proof, checksum }) {
    await VoteBallot.create({
        signature: Buffer.from(signature),
        encryptedVote: Buffer.from(encryptedVote),
        proof: Buffer.from(proof),
        checksum: Buffer.from(checksum),
        anonid: eligibility.elegibilityid,
        sessionid
    });

    await VoteElegibility.update(
        { voted: true },
        { where: { elegibilityid: eligibility.elegibilityid } }
    );

    return { message: 'Voto registrado correctamente' };
}

async function createEligibility(userid, sessionid) 
{
    const eligibility = await VoteElegibility.create({
        anonid: crypto.randomUUID(),            // identificador anónimo
        voted: false,
        sessionid,
        userid
    });
    console.log("Adios")
    return eligibility;
}

module.exports = {
  getVotingRulesForSession,
  getSessionById,
  hasUserVoted,
  registerEncryptedVote,
  createEligibility
};


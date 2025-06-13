const { VotingRule, VoteCriteria, VoteSession, VoteElegibility, VoteBallot, VoteDemographicStat, VoteCommitment } = require('../db/sequelize');
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
    return eligibility;
}

async function updateDemographicStat(demographicid, optionid, value) {
    const existing = await VoteDemographicStat.findOne({
        where: { demographicid, optionid }
    });

    if (existing) {
        existing.sum += 1;
        await existing.save();
        return { updated: true };
    } else {
        await VoteDemographicStat.create({
        sum: 1,
        value,
        demographicid,
        optionid
        });
        return { created: true };
    }
}

async function updateCommitment(optionid, maxWeight) 
{
    const existing = await VoteCommitment.findOne({ where: { optionid } });
    console.log(maxWeight)
    if (existing) 
        {
        existing.sum += 1;
        existing.value += maxWeight;
        await existing.save();
    } else 
    {
        await VoteCommitment.create({
        optionid,
        sum: 1,
        value: maxWeight
        });
    }
}

module.exports = {
  getVotingRulesForSession,
  getSessionById,
  hasUserVoted,
  registerEncryptedVote,
  createEligibility,
  updateDemographicStat,
  updateCommitment
};


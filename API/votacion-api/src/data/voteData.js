const { VotingRule, VoteCriteria, VoteSession, VoteElegibility, VoteBallot, VoteDemographicStat, VoteCommitment, VoteBackup, VoteQuestion, VoteOption } = require('../db/sequelize');
const { Op } = require('sequelize');
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

async function registerEncryptedVote({ sessionid, eligibility, encryptedVote, signature, proof, transaction, userid }) {
    const sigBuffer = Buffer.from(signature, 'base64');
    const voteBuffer = userid ? Buffer.from(encryptedVote, 'utf-8') : Buffer.from(encryptedVote, 'base64');
    const proofBuffer = proof ? Buffer.from(proof, 'base64') : Buffer.alloc(0);

    const hash = crypto.createHash('sha256');
    hash.update(sigBuffer);
    hash.update(voteBuffer);
    hash.update(Buffer.from("VotoPuraVidaCheckSumAsegurado")); 
    hash.update(proofBuffer);
    hash.update(Buffer.from(eligibility.elegibilityid.toString()));
    hash.update(Buffer.from(sessionid.toString()));

    const checksum = hash.digest();

    await VoteBallot.create({
        signature: sigBuffer,
        encryptedVote: voteBuffer,
        proof: proofBuffer,
        checksum,
        anonid: eligibility.elegibilityid,
        sessionid,
        userid
    }, { transaction });

    await VoteElegibility.update(
        { voted: true },
        { where: { elegibilityid: eligibility.elegibilityid }, transaction }
    );

    return { message: 'Voto registrado correctamente con verificación de integridad.' };
}
async function backupVote({ sessionid, eligibility, encryptedVote, signature, proof, transaction }) {
    const backupPayload = {
        timestamp: new Date().toISOString(),
        sessionid,
        elegibilityid: eligibility.elegibilityid,
        anonid: eligibility.anonid,
        encryptedVote,
        signature,
        proof
    };

    await VoteBackup.create({
        register: JSON.stringify(backupPayload)
    }, { transaction });
}


async function createEligibility(userid, sessionid, transaction) 
{
    const eligibility = await VoteElegibility.create({
        anonid: crypto.randomUUID(),
        voted: false,
        sessionid,
        userid
    }, {transaction});
    return eligibility;
}

async function updateDemographicStat(demographicid, optionid, value, transaction) {
    const existing = await VoteDemographicStat.findOne({
        where: { demographicid, optionid },
        transaction
    });

    if (existing) {
        existing.sum += 1;
        await existing.save({ transaction });
        return { updated: true };
    } else {
        await VoteDemographicStat.create({
            sum: 1,
            value,
            demographicid,
            optionid
        }, { transaction });
        return { created: true };
    }
}

async function updateCommitment(optionid, maxWeight, transaction) {
    const existing = await VoteCommitment.findOne({ where: { optionid }, transaction });

    if (existing) {
        existing.sum += 1;
        existing.value += maxWeight;
        await existing.save({ transaction });
    } else {
        await VoteCommitment.create({
            optionid,
            sum: 1,
            value: maxWeight
        }, { transaction });
    }
}

async function getLastFiveVotes(userId)
{
    try 
    {
        const elegibilities = await VoteElegibility.findAll({
        where: {
            userid: userId,
            voted: true
        },
        order: [['elegibilityid', 'DESC']],
        limit: 5
        });

        const anonIds = elegibilities.map(e => e.elegibilityid);

        if (anonIds.length === 0) return [];

        const ballots = await VoteBallot.findAll({
        where: {
            anonid: {
            [Op.in]: anonIds
            }
        }
        });

        return ballots;
    } catch (error) {
        console.error('Error al obtener votos por userId:', error.message);
        return [];
    }
}

async function getQuestionsAndOptions(questionIds) 
{
    const questions = await VoteQuestion.findAll(
    {
        where: { questionid: { [Op.in]: questionIds } },
        raw: true
    });

    const options = await VoteOption.findAll(
    {
        where: { questionid: { [Op.in]: questionIds } },
        raw: true
    });

    return { questions, options };
}

module.exports = {
  getVotingRulesForSession,
  getSessionById,
  hasUserVoted,
  registerEncryptedVote,
  createEligibility,
  updateDemographicStat,
  updateCommitment,
  backupVote,
  getLastFiveVotes,
  getQuestionsAndOptions
};


const { VotingRule, VoteCriteria, VoteSession, VoteElegibility, VoteBallot, VoteDemographicStat, VoteCommitment, VoteBackup, VoteQuestion, VoteOption, VpvLog, CfProposalVote, VpvProposal, VpvDemographicData, VoteRule, VoteAcceptanceRule, VoteSessionIpPermission, VpvWhitelist, VoteSessionTimeRestriction } = require('../db/sequelize');
const { Op } = require('sequelize');
const crypto = require('crypto');

async function getVotingRulesForSession(sessionid) 
{
    return await VotingRule.findAll({
        where: { sessionid, enabled: true },
        include: [{ model: VoteCriteria, as: 'criteria' }]
    });
}

async function getSessionById(sessionid) 
{
    return await VoteSession.findByPk(sessionid);
}

async function hasUserVoted(userid, sessionid) 
{
    const record = await VoteElegibility.findOne({
        where: { userid, sessionid }
    });

    return record;
}

async function registerEncryptedVote({ sessionid, eligibility, encryptedVote, signature, proof, transaction, userid }) 
{
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

async function backupVote({ sessionid, eligibility, encryptedVote, signature, proof, transaction }) 
{
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

async function updateDemographicStat(demographicid, optionid, value, transaction) 
{
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

async function updateCommitment(optionid, maxWeight, transaction) 
{
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

async function insertLog(description, computer, trace, userid, value1, log_typeid, log_sourceid, log_severityid) 
{
    try {
        const hash = crypto.createHash('sha256');
        hash.update(Buffer.from(description || ''));
        hash.update(Buffer.from(trace || ''));
        hash.update(Buffer.from(value1 || ''));
        hash.update(Buffer.from(userid?.toString() || ''));
        hash.update(Buffer.from(log_typeid.toString()));
        hash.update(Buffer.from(log_sourceid.toString()));
        hash.update(Buffer.from(log_severityid.toString()));
        hash.update(Buffer.from('VotoPuraVidaCheckSumLog'));

        const checksum = hash.digest();
        
        await VpvLog.create(
        {
            description,
            posttime: new Date(),
            computer,
            trace,
            reference_id1: userid,
            value1,
            checksum,
            log_typeid,
            log_sourceid,
            log_severityid
        });
    } catch (error) {
        console.error('Error al insertar log:', error.message);
    }
}

async function getProposal(sessionid) 
{
    const vote = await CfProposalVote.findOne({ where: { sessionid } });
    if (!vote) return null;

    const proposal = await VpvProposal.findByPk(vote.proposalid);
    if (!proposal) return null;

    return {
        name: proposal.name,
        description: proposal.description,
        version: proposal.version
    };
}

async function getSession(proposalid) 
{
    const vote = await CfProposalVote.findOne({
        where: 
        {
            proposalid,
            result: false
        }
    });

    if (!vote) return null;

    const session = await VoteSession.findByPk(vote.sessionid);
    if (!session) return null;

    return session;
}

async function createSession({startDate, endDate, voteTypeid, sessionStatusid, visibilityid}, proposalid, transaction) 
{
    const randomString = crypto.randomBytes(16).toString('hex');

    const public_key = Buffer.from(randomString, 'utf8');

    // Crear sesión de votos
    const session = await VoteSession.create({
        startDate,
        endDate,
        public_key,
        sessionStatusid,
        voteTypeid,
        visibilityid
    }, { transaction });

    await CfProposalVote.create(
        {
            date: new Date(),
            result: 0,
            sessionid: session.sessionid,
            proposalid
        }, { transaction }
    );

    return session
}

async function configureQuestions(sessionid, questions, transaction) 
{
    const now = new Date();

    for (const q of questions) 
    {
        let question = q
        if(q.questionid)
        {
            await VoteQuestion.update({
                description: q.description,
                required: !!q.required,
                max_answers: q.max_answers,
                updateDate: now,
                question_typeid: q.question_typeid
            }, 
            { 
                where:
                { 
                    sessionid,
                    questionid: q.questionid
                },
                transaction
            });
        }
        else
        {
            question = await VoteQuestion.create({
                description: q.description,
                required: !!q.required,
                max_answers: q.max_answers,
                createDate: now,
                updateDate: null,
                question_typeid: q.question_typeid,
                sessionid
            }, { transaction });
        }

        for (const opt of q.options) 
        {
            const raw = `${opt.description}-${opt.value}-${opt.order}`;
            const checksum = crypto.createHash('sha256').update(raw).digest();

            if(opt.optionid)
            {
                await VoteOption.update({
                    description: opt.description,
                    value: opt.value,
                    url: opt.url,
                    order: opt.order,
                    checksum: checksum,
                    updateDate: now
                }, 
                { 
                    where:
                    {
                        questionid: question.questionid,
                        optionid: opt.optionid
                    },
                    transaction
                });
            }
            else
            {
                await VoteOption.create({
                    description: opt.description,
                    value: opt.value,
                    url: opt.url,
                    order: opt.order,
                    checksum: checksum,
                    createDate: now,
                    updateDate: null,
                    questionid: question.questionid
                }, { transaction });
            }
        }
    }
}

async function searchCriterias(criterias) 
{
    for (const criterio of criterias) 
    {
        const resultado = await VpvDemographicData.findOne({
            where: {
                code: criterio.code,
                description: criterio.value
            }
        });

        let demographicid = resultado.demographicid

        criterio.demographicid = demographicid;

        let criteria = await VoteCriteria.findOne(
        {
            where: { demographicid },
            attributes: ['criteriaid']
        });

        if (!criteria) 
        {
            criteria = await VoteCriteria.create({
                demographicid,
                type: resultado.description,
                datatype: 'text'
            });
        }

        criterio.criteriaid = criteria.criteriaid;
    }

    return criterias;
}

async function updateSession(session, transaction) 
{
    const sessionid = session.sessionid
    const updated = await VoteSession.update(
    {
        startDate: session.startDate,
        endDate: session.endDate,
        voteTypeid: session.voteTypeid,
        sessionStatusid: session.sessionStatusid,
        visibilityid: session.visibilityid
    },
    {
        where: { sessionid },
        transaction
    }
    );
    return updated;
}

async function configureCriterias(sessionid, criterios, transaction) 
{
    for (const criterio of criterios) 
    {
        const existing = await VotingRule.findOne({
            where: {
                sessionid,
                criteriaid: criterio.criteriaid
            }, transaction
        });
        if(existing)
        {
            await VotingRule.update(
            {
                value: criterio.value,
                weight: parseFloat(criterio.weigth),
                enabled: true
            },
            {
                where: 
                {
                    sessionid,
                    criteriaid: criterio.criteriaid
                },
                transaction
            });
        }
        else
        {
            await VotingRule.create(
            {
                value: criterio.value,
                weight: parseFloat(criterio.weigth),
                enabled: true,
                sessionid,
                criteriaid: criterio.criteriaid
            }, { transaction });
        }
    }
}

async function configureRules(sessionid, rules, transaction) 
{
    for (const rule of rules) 
    {
        const ruleType = await VoteRule.findOne({
            where: { name: rule.rule }
        });

        const existing = await VoteAcceptanceRule.findOne({
            where: {
                sessionid,
                rule_typeid: ruleType.ruleid
            }, transaction
        });
        if(existing)
        {
            await VoteAcceptanceRule.update(
            {
                quantity: rule.value,
                description: ruleType.name + " " + rule.value,
                enabled: true
            },
            {
                where: 
                {
                    sessionid,
                    rule_typeid: ruleType.ruleid
                },
                transaction
            });
        }
        else
        {
            await VoteAcceptanceRule.create(
            {
                quantity: rule.value,
                description: ruleType.name + " " + rule.value,
                enabled: true,
                sessionid,
                rule_typeid: ruleType.ruleid
            }, { transaction });
        }
    }
}

const uploadRestrictedIPs = async (sessionid, restrictedIPs, transaction) => {

    for (const ip of restrictedIPs) 
    {
        let whitelist = await VpvWhitelist.findOne({
            where: { 
                initial_IP: ip.initial_IP, 
                end_IP: ip.end_IP, 
                countryid: ip.countryid 
            },
            transaction
        });

        if (!whitelist) 
        {
            whitelist = await VpvWhitelist.create({
                initial_IP: ip.initial_IP,
                end_IP: ip.end_IP,
                countryid: ip.countryid,
                allowed: true
            }, { transaction });
        }

        await VoteSessionIpPermission.create({
            sessionid,
            whitelistid: whitelist.whitelistid,
            allowed: ip.allowed,
            created_date: new Date(),
        }, { transaction });
    }
};

const uploadRestrictedTimes = async (sessionid, schedules, transaction) => {

    for (const schedule of schedules) 
    {
        let existingRestriction = await VoteSessionTimeRestriction.findOne({
            where: {
                sessionid,
                day_of_week: schedule.day_of_week
            },
            transaction
        });

        if (existingRestriction) 
        {
            existingRestriction.start_time = schedule.start_time;
            existingRestriction.end_time = schedule.end_time;
            existingRestriction.allowed = schedule.allowed;

            await existingRestriction.save({ transaction });
        } 
        else 
        {
            await VoteSessionTimeRestriction.create({
                sessionid,
                start_time: schedule.start_time,
                end_time: schedule.end_time,
                day_of_week: schedule.day_of_week,
                allowed: schedule.allowed
            }, { transaction });
        }
    }
};

module.exports = 
{
    getVotingRulesForSession,
    getSessionById,
    hasUserVoted,
    registerEncryptedVote,
    createEligibility,
    updateDemographicStat,
    updateCommitment,
    backupVote,
    getLastFiveVotes,
    getQuestionsAndOptions,
    insertLog,
    getProposal,
    getSession,
    createSession,
    configureQuestions,
    searchCriterias,
    configureCriterias,
    updateSession,
    configureRules,
    uploadRestrictedIPs,
    uploadRestrictedTimes
};


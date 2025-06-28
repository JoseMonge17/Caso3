const { VotingRule, VoteCriteria, VoteSession, VoteElegibility, VoteBallot, VoteDemographicStat, VoteCommitment, VoteBackup, VoteQuestion, VoteOption, CfProposalVote, VpvProposal, VpvDemographicData, VoteRule, VoteAcceptanceRule, VoteSessionIpPermission, VpvWhitelist, VoteSessionTimeRestriction, VpvCountry, VpvState, VpvCity, VpvAddress, VpvAddressAssignment, VpvImpactZone, VpvProposalImpactZone  } = require('../db/sequelize');
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
    // Convierte la firma de base64 a un Buffer (formato binario)
    const sigBuffer = Buffer.from(signature, 'base64');
    // Convierte el voto a un Buffer, dependiendo de si el userid es nulo o no
    // Si no es nulo, el voto se trata como un string codificado en 'utf-8'
    // Si es nulo, se trata como base64
    const voteBuffer = userid ? Buffer.from(encryptedVote, 'utf-8') : Buffer.from(encryptedVote, 'base64');
    // Convierte proof a un Buffer Si no existe, se asigna un Buffer vacío
    const proofBuffer = proof ? Buffer.from(proof, 'base64') : Buffer.alloc(0);

    // Crea un hash SHA-256 para realizar el checksum de la información
    const hash = crypto.createHash('sha256');
    // Agrega la información del voto
    hash.update(sigBuffer);
    hash.update(voteBuffer);
    // Agrega una constante para verificar la integridad y asegurar la autenticidad
    hash.update(Buffer.from("VotoPuraVidaCheckSumAsegurado")); 
    hash.update(proofBuffer);
    hash.update(Buffer.from(eligibility.elegibilityid.toString()));
    hash.update(Buffer.from(sessionid.toString()));

    // Genera el checksum final usando el hash
    const checksum = hash.digest();

    //Registra el voto
    await VoteBallot.create({
        signature: sigBuffer,
        encryptedVote: voteBuffer,
        proof: proofBuffer,
        checksum,
        anonid: eligibility.elegibilityid,
        sessionid,
        userid
    }, { transaction });

    //Actualiza el registro, indicando que el usuario ya votó
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
        // Buscar los últimos 5 registros de elegibilidad donde el usuario haya votado
        const elegibilities = await VoteElegibility.findAll({
            where: {
                userid: userId,
                voted: true
            },
            order: [['elegibilityid', 'DESC']],
            limit: 5
        });

        // Extraer los identificadores únicos anónimos de los resultados obtenidos
        const anonIds = elegibilities.map(e => e.elegibilityid);

        // Si no hay votos registrados, retornar un arreglo vacío
        if (anonIds.length === 0) return [];

        // Obtener los votos que coincidan con los IDs anónimos
        const ballots = await VoteBallot.findAll({
        where: {
            anonid: {
                [Op.in]: anonIds // Busca donde el campo anonid esté dentro del array de IDs
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

async function getProposalById(proposalid) 
{
    const proposal = await VpvProposal.findByPk(proposalid);
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
    try 
    {
        //Crea un string random para la public_key
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
    } catch (error) {
        throw new Error("Error en crear la sesión de votos: " + error.message);
    }
}

async function configureQuestions(sessionid, questions, transaction) 
{
    try 
    {
        const now = new Date();

        // Recorre todas las preguntas proporcionadas
        for (const q of questions) 
        {
            let question = q

            // Si la pregunta ya existe se actualiza
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
            else // Si la pregunta no existe aún se crea
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

            // Luego procesa sus opciones de respuesta
            for (const opt of q.options) 
            {
                 // Se genera un checksum basado en los datos principales de la opción
                const raw = `${opt.description}-${opt.value}-${opt.order}`;
                const checksum = crypto.createHash('sha256').update(raw).digest();

                // Si la opción ya existe se actualiza
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
                else // Si la opción no existe aún se crea
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
    } catch (error) {
        throw new Error("Error en configurar las preguntas y respuestas: " + error.message);
    }
}

async function searchCriterias(criterias) 
{
    for (const criterio of criterias) 
    {
        // Busca un registro en la tabla VpvDemographicData que coincida con el código y valor del criterio
        const resultado = await VpvDemographicData.findOne({
            where: {
                code: criterio.code,
                description: criterio.value
            }
        });

        // Extrae el ID demográfico del resultado encontrado
        let demographicid = resultado.demographicid

        // Lo asigna al objeto criterio actual para mantener la relación
        criterio.demographicid = demographicid;

        // Busca en la tabla VoteCriteria si ya existe un criterio vinculado a ese demographicid
        let criteria = await VoteCriteria.findOne(
        {
            where: { demographicid },
            attributes: ['criteriaid']
        });

        // Si no existe ese criterio, lo crea
        if (!criteria) 
        {
            criteria = await VoteCriteria.create({
                demographicid,
                type: resultado.description,
                datatype: 'text'
            });
        }

        // Asocia el ID del criterio al objeto original
        criterio.criteriaid = criteria.criteriaid;
    }

    // Devuelve el arreglo de criterios actualizado, con demographicid y criteriaid agregados
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
    try 
    {
        // Recorre todos los criterios enviados
        for (const criterio of criterios) 
        {
            // Verifica si ya existe una regla de votación para este criterio en la sesión dada
            const existing = await VotingRule.findOne({
                where: {
                    sessionid,
                    criteriaid: criterio.criteriaid
                }, transaction
            });

            // Si la regla ya existe, la actualiza
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
            else // Si no existe, la crea desde cero
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
    } catch (error) {
        throw new Error("Error en configurar criterios: " + error.message);
    }
}

async function configureRules(sessionid, rules, transaction) 
{
    try 
    {
        // Recorre todas las reglas enviadas
        for (const rule of rules) 
        {
            //Busca el tipo de regla que se va a aplicar
            const ruleType = await VoteRule.findOne({
                where: { name: rule.rule }
            });

            // Busca si ya existe una regla de aceptación configurada para esta sesión y tipo de regla
            const existing = await VoteAcceptanceRule.findOne({
                where: {
                    sessionid,
                    rule_typeid: ruleType.ruleid
                }, transaction
            });

            // Si ya existe la regla, se actualiza con los nuevos valores
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
            else // Si no existe, se crea una nueva entrada con los valores especificados
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
    } catch (error) {
        throw new Error("Error en configurar las reglas de la sesión de votos: " + error.message);
    }
}

async function uploadRestrictedIPs (sessionid, restrictedIPs, transaction)
{
    try 
    {
        // Recorre cada objeto de whitelist en el arreglo recibido
        for (const ip of restrictedIPs) 
        {
            // Verifica si ya existe un rango de IPs en la whitelist con el mismo rango y país
            let whitelist = await VpvWhitelist.findOne({
                where: { 
                    initial_IP: ip.initial_IP, 
                    end_IP: ip.end_IP, 
                    countryid: ip.countryid 
                },
                transaction
            });

            // Si no existe, lo crea en la tabla de whitelist
            if (!whitelist) 
            {
                whitelist = await VpvWhitelist.create({
                    initial_IP: ip.initial_IP,
                    end_IP: ip.end_IP,
                    countryid: ip.countryid,
                    allowed: true
                }, { transaction });
            }

            // Verifica si ya existe una regla de restricción para esta sesión y este whitelistid
            const restriction = await VoteSessionIpPermission.findOne({
                where: { 
                    sessionid,
                    whitelistid: whitelist.whitelistid
                },
                transaction
            });

            // Si ya existe, la actualiza con el nuevo valor
            if(restriction)
            {
                await VoteSessionIpPermission.update(
                {
                    allowed: ip.allowed,
                },
                {
                    where: 
                    {
                        sessionid,
                        whitelistid: whitelist.whitelistid
                    },
                    transaction
                });
            }
            else // Si no existe, crea una nueva restricción IP para esta sesión
            {
                await VoteSessionIpPermission.create({
                    sessionid,
                    whitelistid: whitelist.whitelistid,
                    allowed: ip.allowed,
                    created_date: new Date(),
                }, { transaction });
            }
        }
    } catch (error) {
        throw new Error("Error en configurar la restricción de IPs: " + error.message);
    }
};

async function uploadRestrictedTimes (sessionid, schedules, transaction)
{
    try 
    {
        // Recorre cada horario dentro del arreglo
        for (const schedule of schedules) 
        {
            // Busca si ya existe una restricción horaria para el mismo día de la semana en esa sesión
            let existingRestriction = await VoteSessionTimeRestriction.findOne({
                where: {
                    sessionid,
                    day_of_week: schedule.day_of_week
                },
                transaction
            });

            // Si ya existe una restricción para ese día, se actualiza con los nuevos valores
            if (existingRestriction) 
            {
                existingRestriction.start_time = schedule.start_time;
                existingRestriction.end_time = schedule.end_time;
                existingRestriction.allowed = schedule.allowed;

                await existingRestriction.save({ transaction });
            } 
            else // Si no existe, se crea una nueva restricción horaria para ese día
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
    } catch (error) {
        throw new Error("Error en configurar los horarios de votación: " + error.message);
    }
};

async function getRestrictionTime(sessionid, day)
{
    return restriction = await VoteSessionTimeRestriction.findOne({
        where: { sessionid, day_of_week: day }
    });
}

async function getRestrictionIPs(sessionid, countriesid)
{
    //Busca todos los registros de la tabla intermedia VoteSessionIpPermission y se trae incluidos de una vez todos los whitelists
    const whitelistRecords = await VoteSessionIpPermission.findAll({
        where: { sessionid, allowed: false },
        include: [{
            model: VpvWhitelist,
            required: true,
            where: {
                countryid: {
                    [Op.in]: countriesid //Op.in es un operador de sequelize que se puede igualar al IN( ) de SQL
                }
            }
        }],
    });

    //Recorre todos los registros y obtienes los datos que vamos a ocupar para las validaciones de ip
    const restrictions = whitelistRecords.map(record => ({
        initial_IP: record.VpvWhitelist.initial_IP,
        end_IP: record.VpvWhitelist.end_IP,
        countryid: record.VpvWhitelist.countryid,
        allowed: record.allowed,
    }));

    return restrictions;
}

async function getCountriesByUserId (userid)
{
    try {
        const addressAssignments = await VpvAddressAssignment.findAll({
        where: { userid },
        include: [{
            model: VpvAddress,
            include: [{
            model: VpvCity,
            include: [{
                model: VpvState,
                include: [VpvCountry]
            }]
            }]
        }]
        });

        const countryIds = [];

        addressAssignments.forEach(assignment => {
            const countryid = assignment.VpvAddress.VpvCity.VpvState.VpvCountry.countryid;
            countryIds.push(countryid);
        });

        return countryIds;
    } catch (error) {
        throw new Error('Error al obtener los countryid asociados: ' + error.message);
    }
};

async function uploadImpactZones(proposalid, impactZoneData, transaction) 
{
    try 
    {
        // Recorre cada elemento del arreglo de zonas de impacto
        for (const item of impactZoneData) 
        {
            // Busca si ya existe una zona de impacto con el mismo nombre
            let impactZone = await VpvImpactZone.findOne({
                where: {
                    name: item.zone
                },
                transaction
            });

            // Si la zona no existe, la crea con su tipo
            if (!impactZone) 
            {
                impactZone = await VpvImpactZone.create({
                    name: item.zone,
                    zone_typeid: item.zone_typeid
                }, { transaction });
            }

            // Verifica si ya existe una relación entre la propuesta y la zona
            const existing = await VpvProposalImpactZone.findOne({
                where: {
                    proposalid,
                    zoneid: impactZone.zoneid
                },
                transaction
            });

            // Si ya existe la relación, actualiza el nivel de impacto y la descripción
            if (existing) 
            {
                await existing.update({
                    impact_levelid: item.impact_levelid,
                    description: item.description
                }, { transaction });
            } 
            else // Si no existe la relación, la crea desde cero
            {
                await VpvProposalImpactZone.create({
                    proposalid,
                    zoneid: impactZone.zoneid,
                    impact_levelid: item.impact_levelid,
                    description: item.description
                }, { transaction});
            }
        }
    } catch (error) {
        throw new Error("Error en configurar las zonas de impacto de las propuestas: " + error.message);
    }
}

async function uploadDirectList (sessionid, directList, transaction)
{
    try 
    {
        // Mapea cada userid de la lista directa a una llamada a la función de crear un registro de elegibilidad
        const promises = directList.map(async (userid) => {
            return createEligibility(userid, sessionid, transaction);
        });

        // Espera a que todas las elegibilidades sean creadas en paralelo
        await Promise.all(promises);
    } catch (error) {
        throw new Error("Error en configurar la lista directa de votantes: " + error.message);
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
    getProposal,
    getProposalById,
    getSession,
    createSession,
    configureQuestions,
    searchCriterias,
    configureCriterias,
    updateSession,
    configureRules,
    uploadRestrictedIPs,
    uploadRestrictedTimes,
    getRestrictionTime,
    getRestrictionIPs,
    getCountriesByUserId,
    uploadImpactZones,
    uploadDirectList
};


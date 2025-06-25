const { getDemographicData } = require('../data/authUserData');
const { getSessionById, getVotingRulesForSession, hasUserVoted, registerEncryptedVote, createEligibility, updateDemographicStat, updateCommitment, backupVote, getLastFiveVotes, getQuestionsAndOptions, insertLog, getProposal, getSession, createSession, configureQuestions, configureCriterias, searchCriterias, updateSession, configureRules, uploadRestrictedIPs, uploadRestrictedTimes, getRestrictionTime, getRestrictionIPs, getCountriesByUserId, getProposalById, uploadImpactZones} = require('../data/voteData');
const { sequelize } = require('../db/sequelize');
const { verifyMfaCode } = require('../data/MfaVerification');
const { saveLivenessData } = require('../data/livenessData');
const crypto = require('crypto');

async function vote(data, body) 
{
    const user = data.user
    
    // Validar autenticación multifactor (MFA) y comprobación de vida
    const { authenticated, error } = await verifyMfaCode(body.methodid, body.codeMFA);

    if (!authenticated) throw new Error(error);

    const result = await saveLivenessData(body.livenessCheck, body.biometricMedia, user.userid);

    if(!result.success) throw new Error(result.error);

    if(!body.livenessCheck.result) throw new Error("Identidad no confirmada")

    // Confirmar existencia activa del ciudadano en el sistema
    if (!user) throw new Error('Usuario no encontrado');

    //      Validar estado
    if (user.status.name !== "Active") throw new Error(`Usuario en estado '${user.status.name}'`);

    //Verificar si el usuario está habilitado para votar en esa propuesta según su perfil
    //      Validar que se envio una sesion de votos
    const sessionid = body.sessionid;
    if (!sessionid) throw new Error('No envió votación');

    //      Obtener los criterios para votar y los datos demograficos del usuario
    const userDemographics = await getDemographicData(user.userid);
    const votingRules = await getVotingRulesForSession(sessionid);

    //      Verifica si el usuario cumple con al menos una regla de votación activa
    const matchingRules = votingRules.filter(rule =>
        userDemographics.some(demo =>
            demo.demographicid === rule.criteria.demographicid &&
            demo.value.toLowerCase() === rule.value.toLowerCase()
        )
    );

    // Verifica si cumple al menos una regla
    const isAllowed = matchingRules.length > 0;

    // Obtiene el mayor peso entre las reglas que el usuario cumple
    const maxWeight = isAllowed ? matchingRules.reduce((max, rule) => Math.max(max, parseFloat(rule.weight)), 0) : 0;
    
    //      Valida Si la votación tiene al menos un criterio y si cumple con al menos una
    if (votingRules.length > 0 && !isAllowed) throw new Error('Usuario no cumple con los criterios para votar en esta sesión');

    const session = await getSessionById(sessionid);

    if (!session) throw new Error('Sesión de voto no encontrada');

    // Ver si la sesion de votos permite el IP del usuario
    const countriesUser = await getCountriesByUserId(user.userid);

    //Probar allowed
    const restrictionIPs = await getRestrictionIPs(sessionid, countriesUser);

    const ip= ipToNumber(body.IP)

    for (const record of restrictionIPs) 
    {
        const initialIPNum = ipToNumber(record.initial_IP);
        const endIPNum = ipToNumber(record.end_IP);

        if (ip >= initialIPNum && ip <= endIPNum) 
        {
            if (!record.allowed) throw new Error('IP no permitida para votar');
        }
    }

    const now = new Date();
    const day = now.getDay();
    if(day==0) day=7;

    const currentTime = now.toLocaleTimeString('en-GB');

    // Ver si la sesion de votos tiene restriccion de horarios
    const restrictionTime = await getRestrictionTime(sessionid, day);

    // Si existe una restriccion
    if(restrictionTime)
    {
        //Si las horas son iguales es que en ese dia no se permite votaciones
        if(restrictionTime.start_time == restrictionTime.end_time) throw new Error('La sesión de votos no permite votos hoy');

        //Si esta fuera de las horas permitidas
        if(currentTime < restrictionTime.start_time || currentTime > restrictionTime.end_time) throw new Error('No esta en las horas permitidas de votacion');
    }

    //Verificar que la propuesta siga abierta en el rango de fechas definido
    if (now < session.startDate || now > session.endDate) throw new Error('La sesión de votación está fuera de su rango de fechas');

    //Confirmar que el usuario no ha votado previamente en esa propuesta   
    const record = await hasUserVoted(user.userid, sessionid);
    if (record) 
    {
        if(record.voted) throw new Error('El usuario ya ha votado en esta sesión');
    }

    // Registrar el voto en la base de datos asociando la propuesta, fecha y decisión
    let eligibility = record;

    const allOptionIds = [];

    for (const answer of body.ballot.answers) 
    {
        if (Array.isArray(answer.optionsid)) 
        {
            allOptionIds.push(...answer.optionsid);
        }
    }
    
    const votoString = JSON.stringify(body.ballot.answers);

    let vote = votoString

    let vote_userid = user.userid

    //Ver si la votacion es secreta
    if(session.sessionStatusid==1)
    {
        // Cifrar el voto utilizando la llave vinculada a la identidad del votante
            // Convertir la clave recibida a Buffer real
        const keyBuffer = Buffer.from(data.userkey.publicKey.data);
            // Derivar una clave de 256 bits para AES
        const aesKey = crypto.createHash('sha256').update(keyBuffer).digest(); // 32 bytes
        
        const cipher = crypto.createCipheriv('aes-256-ecb', aesKey, null);
        vote = cipher.update(votoString, 'utf8', 'base64');
        vote += cipher.final('base64');

        vote_userid = null
    }

    //Inicio Transaccion
    try 
    {
        const result = await sequelize.transaction(async (t) => 
        {
            if (!eligibility) 
            {
                // Crear nuevo registro de elegibilidad
                eligibility = await createEligibility(user.userid, sessionid, t);
            }

            await registerEncryptedVote(
            {
                sessionid,
                eligibility,
                encryptedVote: vote,
                signature: body.ballot.signature,
                proof: body.ballot.proof,
                userid: vote_userid,
                transaction: t
            });

            //Vote backup
            await backupVote({
                sessionid,
                eligibility,
                encryptedVote: vote,
                signature: body.ballot.signature,
                proof: body.ballot.proof,
                transaction: t
            });

            // Sumarizar el voto dentro de la colección de resultados cifrados sin exponer contenido
            for (const optionid of allOptionIds) 
            {
                await updateCommitment(optionid, maxWeight, t);
                for (const demo of userDemographics) 
                {
                    await updateDemographicStat(demo.demographicid, optionid, demo.value, t);
                }
            }
        });
        return result;
    } catch (error) {
        await insertLog("Fallo en la votacion realizada", body.livenessCheck.device_info, "Modulo votaciones / Realizar votacion", user.userid, "userid", 2, 1, 3);
        console.error('Error en transacción de voto: ', error);
        return { success: false, error: error.message };
    }
}

const ipToNumber = (ip) => 
{
    return ip.split('.').reduce((acc, octet) => (acc << 8) + parseInt(octet), 0) >>> 0;
};

async function listVotes(data, body) 
{
    const user = data.user

    // Validar autenticación multifactor (MFA) y comprobación de vida
    const { authenticated, error } = await verifyMfaCode(body.methodid, body.codeMFA);

    if (!authenticated) 
    {
        throw new Error(error);
    }

    const result = await saveLivenessData(body.livenessCheck, body.biometricMedia, user.userid);

    if(!result.success) throw new Error(result.error);

    if(!body.livenessCheck.result) throw new Error("Identidad no confirmada")

    // Confirmar existencia activa del ciudadano en el sistema
    if (!user) throw new Error('Usuario no encontrado');

    //      Validar estado
    if (user.status.name !== "Active") {
        throw new Error(`Usuario en estado '${user.status.name}'`);
    }

    // Consultar en la base las cinco últimas propuestas en las que ha participado mediante voto

    const ballots = await getLastFiveVotes(user.userid);

    const votosSecretos = [];

    // Obtener la llave criptográfica del usuario
    const userKey = Buffer.from(data.userkey.publicKey.data);

    // Extraer los votos asociados, descifrarlos y mostrar: propuesta, fecha y decisión (resumen, no detalle)
    for (const ballot of ballots) 
    {
        const propuesta = await getProposal(ballot.sessionid);

        // Validacion del checksum
        const esValido = verifyChecksumBallot(ballot);

        if (!esValido) 
        {
            console.warn(`Checksum no coincide para ballot ${ballot.vote_registryid}`);
            votosSecretos.push({
                propuesta,
                fecha: new Date(ballot.voteDate).toLocaleString('es-CR', {
                    day: '2-digit',
                    month: '2-digit',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true,
                    timeZone: 'America/Costa_Rica'
                }),
                decision: "Su voto fue malversado"
            })
            continue;
        }

        let voto = null

        if (!ballot.userid) voto = desencriptarVoto(ballot.encryptedVote, userKey);
        else voto = decodeJson(ballot.encryptedVote);

        if (voto) 
        {
            votosSecretos.push({
                propuesta,
                fecha: new Date(ballot.voteDate).toLocaleString('es-CR', {
                    day: '2-digit',
                    month: '2-digit',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true,
                    timeZone: 'America/Costa_Rica'
                }),
                decision: await formatearVotoEstructurado(voto)
            });
        }
    }
    // Registrar esta operación como evento de consulta auditada
    await insertLog("Consulta auditada de últimas 5 votaciones realizada", body.livenessCheck.device_info, "Modulo votaciones / Mis ultimas 5 votaciones", user.userid, "userid", 1, 1, 1);

    return votosSecretos;
}

async function configureVoting(data, body)
{
    // Validar que el usuario tenga permisos para configurar esa propuesta
    if(!data.permissions.find(p => p.code === "VOTE_MANAGE")) throw new Error("No tiene permisos para configurar esta votación");

    const proposal = getProposalById(body.proposalid);
    if(!proposal) throw new Error("No existe la propuesta");

    //Validar si ya existe una session con el proposalid
    let session = await getSession(body.proposalid);

    if(session)
    {
        const now = new Date();
        const startDate = new Date(session.startDate);
        // No permitir actualizar esta configuración solo hasta que inicie el periodo de votación
        if (now >= startDate) throw new Error("La sesión de votación ya ha iniciado. No se puede modificar.");

        session.startDate = body.session.startDate;
        session.endDate = body.session.endDate;
        session.voteTypeid = body.session.voteTypeid;
        session.sessionStatusid = 5;
        session.visibilityid =  body.session.visibilityid;
    }

    // Busqueda previa de registros de la tabla vote_criterias
    const criterias = await searchCriterias(body.session.criterios)

    if(body.session.restrictedIPs)
    {
        body.session.rules.push({
            "rule": "Restricción IP",
            "value": true
        });
    }
    else
    {
        body.session.rules.push({
            "rule": "Restricción IP",
            "value": false
        });
    }

    if(body.session.schedules)
    {
        body.session.rules.push({
            "rule": "Restricción Horario",
            "value": true
        });
    }
    else
    {
        body.session.rules.push({
            "rule": "Restricción Horario",
            "value": false
        });
    }

    //Inicio de la transaccion
    try {
        const result = await sequelize.transaction(async (t) => 
        {
            // Guardar la configuración completa de la votación en estado preparado
            // Establecer fechas de apertura y cierre de la votación
            // Especificar el tipo de votación: única, múltiple, calificación, etc.
            if(session) await updateSession(session, t);
            else 
            {
                session = await createSession({
                    startDate: body.session.startDate,
                    endDate: body.session.endDate,
                    voteTypeid: body.session.voteTypeid,
                    sessionStatusid: 5,
                    visibilityid: body.session.visibilityid,
                }, body.proposalid, t);
            }

            // Definir población meta mediante filtros como edad, sexo, nacionalidad, ubicación, instituciones, etc.
            await configureCriterias(session.sessionid, criterias, t)

            // Cargar la(s) pregunta(s) asociada(s) a la propuesta y los posibles valores de respuesta
            await configureQuestions(session.sessionid, body.session.questions, t)

            //Cargar las reglas automáticas
            await configureRules(session.sessionid, body.session.rules, t)

            //To do: Probar actualizaciones
            //Cargar restricciones de IP
            await uploadRestrictedIPs(session.sessionid, body.session.restrictedIPs, t)

            //Cargar horarios
            await uploadRestrictedTimes(session.sessionid, body.session.schedules, t)

            //To do: Probar actualizaciones
            //Cargar zonas de impacto de la propuesta
            await uploadImpactZones(body.proposalid, body.impact_zone, t)
        });

        return result;
    } catch (error) {
        console.error('Error en transacción de configurar voto: ', error);
        return { success: false, error: error.message };
    }
}

function decodeJson(buffer) 
{
    try {
        const jsonStr = Buffer.from(buffer).toString('utf-8');
        return JSON.parse(jsonStr);
    } catch (err) {
        console.error('Error al decodificar voto:', err);
        return null;
    }
}

function desencriptarVoto(encryptedBuffer, keyBuffer) 
{
    try {
        const aesKey = crypto.createHash('sha256').update(keyBuffer).digest();

        const decipher = crypto.createDecipheriv('aes-256-ecb', aesKey, null);
        decipher.setAutoPadding(true);

        const encryptedBase64 = Buffer.from(encryptedBuffer).toString('base64');

        let decrypted = decipher.update(encryptedBase64, 'base64', 'utf8');
        decrypted += decipher.final('utf8');

        return JSON.parse(decrypted);
    } catch (err) {
        console.error('❌ Error al desencriptar el voto secreto:', err.message);
        return null;
    }
}

async function formatearVotoEstructurado(voto) 
{
    const questionIds = voto.map(v => v.questionid);

    const { questions, options } = await getQuestionsAndOptions(questionIds);

    return voto.map(respuesta => 
    {
        const pregunta = questions.find(q => q.questionid === respuesta.questionid);
        const respuestas = respuesta.optionsid.map(id => 
        {
            const op = options.find(o => o.optionid === id);
            return op.description;
        });

        return {
            Pregunta: pregunta ? pregunta.description : '(pregunta desconocida)',
            Respuestas: respuestas
        };
    });
}

function verifyChecksumBallot(ballot) {
    try {
        const sigBuffer = Buffer.from(ballot.signature);
        const voteBuffer = Buffer.from(ballot.encryptedVote);
        const proofBuffer = ballot.proof ? Buffer.from(ballot.proof) : Buffer.alloc(0);

        const hash = crypto.createHash('sha256');
        hash.update(sigBuffer);
        hash.update(voteBuffer);
        hash.update(Buffer.from('VotoPuraVidaCheckSumAsegurado1'));
        hash.update(proofBuffer);
        hash.update(Buffer.from(ballot.anonid.toString()));
        hash.update(Buffer.from(ballot.sessionid.toString()));

        const checksumGenerado = hash.digest();
        const checksumOriginal = Buffer.from(ballot.checksum);

        return checksumGenerado.equals(checksumOriginal);
    } catch (err) {
        console.error('Error verificando checksum:', err.message);
        return false;
    }
}

module.exports = { vote, listVotes, configureVoting };
const { findById, getDemographicData } = require('../data/authUserData');
const { getSessionById, getVotingRulesForSession, hasUserVoted, registerEncryptedVote, createEligibility, updateDemographicStat, updateCommitment, backupVote, getLastFiveVotes, getQuestionsAndOptions } = require('../data/voteData');
const { sequelize } = require('../db/sequelize');
const { verifyMfaCode } = require('../data/MfaVerification');
const { saveLivenessData } = require('../data/livenessData');
const crypto = require('crypto');
const { Console } = require('console');



async function vote(data, body) 
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
    if (votingRules.length > 0 && !isAllowed) 
    {
        throw new Error('Usuario no cumple con los criterios para votar en esta sesión');
    }

    //Verificar que la propuesta siga abierta en el rango de fechas definido
    const session = await getSessionById(sessionid);
    if (!session) throw new Error('Sesión de voto no encontrada');

    const now = new Date();

    if (now < session.startDate || now > session.endDate) 
    {
        throw new Error('La sesión de votación está fuera de su rango de fechas');
    }

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
    try {
        
        const result = await sequelize.transaction(async (t) => {
            if (!eligibility) {
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
        console.error('Error en transacción de voto: ', error);
        return { success: false, error: error.message };
    }
}

async function listVotes(data, body) 
{
    const user = data.user

    // Validar autenticación multifactor (MFA) y comprobación de vida
    const { authenticated, error } = await verifyMfaCode(body.methodid, body.codeMFA);

    if (!authenticated) 
    {
        throw new Error(error);
    }

    //const result = await saveLivenessData(body.livenessCheck, body.biometricMedia, user.userid);

    //if(!result.success) throw new Error(result.error);

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
        let voto = null

        if (!ballot.userid) voto = decryptVote(ballot.encryptedVote, userKey);
        else voto = decodeJson(ballot.encryptedVote);

        if (voto) 
        {
            votosSecretos.push({
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

    return votosSecretos;
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

function decryptVote(encryptedBuffer, keyBuffer) {
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

module.exports = { vote, listVotes };
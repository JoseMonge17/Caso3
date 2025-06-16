const { findById, getDemographicData } = require('../data/authUserData');
const { getSessionById, getVotingRulesForSession, hasUserVoted, registerEncryptedVote, createEligibility, updateDemographicStat, updateCommitment } = require('../data/voteData');
const { getUserFromToken } = require('../auth');
const { sequelize } = require('../db/sequelize');
const { verifyMfaCode } = require('../data/MfaVerification');
const { saveLivenessData } = require('../data/livenessData');



async function vote(event, body) 
{
    //const tokenPayload = getUserFromToken(event);

    const user = await findById(2);

    // Validar credenciales del usuario
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
    if (user.status.name !== "Activado") {
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

    for (const answer of body.answers) 
    {
        if (Array.isArray(answer.optionsid)) 
        {
            allOptionIds.push(...answer.optionsid);
        }
    }
    
    //Inicio Transaccion
    const t = await sequelize.transaction();
    try {
        if (!eligibility) {
            // Crear nuevo registro de elegibilidad
            eligibility = await createEligibility(user.userid, sessionid);
        }
        // Cifrar el voto utilizando la llave vinculada a la identidad del votante
        await registerEncryptedVote(
        {
            sessionid,
            eligibility,
            encryptedVote: 'voto_cifrado',
            signature: 'firma_digital',
            proof: 'prueba',
            checksum: 'verificacion'
        });
        //Vote backup

        // Sumarizar el voto dentro de la colección de resultados cifrados sin exponer contenido
        for (const optionid of allOptionIds) 
        {
            await updateCommitment(optionid, maxWeight);
            for (const demo of userDemographics) 
            {
                await updateDemographicStat(demo.demographicid, optionid, demo.value);
            }
        }

    } catch (error) {
        await t.rollback(); // Revierte todo si algo falla
        throw error;
    }

    

    return { userid: user.userid, username: user.username};
}

module.exports = { vote };
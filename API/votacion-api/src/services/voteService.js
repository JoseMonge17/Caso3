const { getDemographicData } = require('../data/authUserData');
const { insertLog } = require('../data/logData');
const { getSessionById, getVotingRulesForSession, hasUserVoted, registerEncryptedVote, createEligibility, updateDemographicStat, updateCommitment, backupVote, getRestrictionTime, getRestrictionIPs, getCountriesByUserId, getProposal} = require('../data/voteData');
const { sequelize } = require('../db/sequelize');
const { verifyMfaCode } = require('../data/MfaVerification');
const { saveLivenessData } = require('../data/livenessData');
const crypto = require('crypto');

async function vote(data, body) 
{
    const user = data.user
    
    // Validar autenticación multifactor (MFA)
    const { authenticated, error } = await verifyMfaCode(body.methodid, body.codeMFA);

    if (!authenticated) throw new Error(error);

    // Validar comprobación de vida
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

    // Funcion sencilla que se trae la session de votos por medio del PK
    const session = await getSessionById(sessionid);

    if (!session) throw new Error('Sesión de voto no encontrada');

    //      Obtener datos demograficos del usuario
    const userDemographics = await getDemographicData(user.userid);

    //Peso que va a tener el usuario en su voto
    let maxWeight = 0;

    //Confirmar que el usuario no ha votado previamente en esa propuesta   
    const record = await hasUserVoted(user.userid, sessionid);
    if (record) //Si el usuario está en lista directa o tiene un registro de voto, verifica si ya votó, si tiene un registro y no voto es que está en lista directa
    {
        if(record.voted) throw new Error('El usuario ya ha votado en esta sesión');

        maxWeight = 1;
    }
    else // Si el usuario no esta en lista directa tiene que pasar por el siguiente filtro para ver si puede votar o no
    {
        //Obtener los criterios de voto de la sesión de votos
        const votingRules = await getVotingRulesForSession(sessionid);

        //      Verifica si el usuario cumple con al menos una regla de votación activa
        //Se podria asimilar a dos for anidados, y se realiza una validación de que si el demographic es el mismo y value de cada uno tambien cumple con la regla
        const matchingRules = votingRules.filter(rule =>
            userDemographics.some(demo =>
                demo.demographicid === rule.criteria.demographicid &&
                demo.value.toLowerCase() === rule.value.toLowerCase()
            )
        );

        // Verifica si cumple al menos una regla
        const isAllowed = matchingRules.length > 0;

        // Obtiene el mayor peso entre las reglas que el usuario cumple
        //Valida si cumplió con una regla si no se le asigna 0
        //El .reduce recorre el array de matchingRules y va va acumulando el valor máximo encontrado.
        //Math.max, compara el maximo anterior con el que viene en la regla
        maxWeight = isAllowed ? matchingRules.reduce((max, rule) => Math.max(max, parseFloat(rule.weight)), 0) : 0;
        
        //      Valida Si la votación tiene al menos un criterio y si cumple con al menos una
        if (votingRules.length > 0 && !isAllowed) throw new Error('Usuario no cumple con los criterios para votar en esta sesión');

        // Ver si la sesion de votos permite el IP del usuario
        //Obtener todos los paises que pertenece el usuario por medio de los address
        const countriesUser = await getCountriesByUserId(user.userid);

        //Por medio de los ids de los paises, va a traerse todas las restricciones de la sesión de votos donde coincidan con los paises
        const restrictionIPs = await getRestrictionIPs(sessionid, countriesUser);

        // Convierte la ip en un número
        const ip= ipToNumber(body.IP)

        for (const record of restrictionIPs) 
        {
            // Convierte las ip en números
            const initialIPNum = ipToNumber(record.initial_IP);
            const endIPNum = ipToNumber(record.end_IP);

            //Valida si la IP está en el rango del registro
            if (ip >= initialIPNum && ip <= endIPNum) 
            {
                // Si no está permitido no lo deja votar
                if (!record.allowed) throw new Error('IP no permitida para votar');
            }
        }
    }

    //Formato de fechas y obtener el número del día
    const now = new Date();
    const day = now.getDay();
    if(day==0) day=7;

    const currentTime = now.toLocaleTimeString('en-GB');

    // Ver si la sesion de votos tiene restriccion de horarios
    const restrictionTime = await getRestrictionTime(sessionid, day);

    // Si existe mínimo una restriccion
    if(restrictionTime)
    {
        //Si las horas son iguales es que en ese dia no se permite votaciones
        if(restrictionTime.start_time == restrictionTime.end_time) throw new Error('La sesión de votos no permite votos hoy');

        //Valida si está fuera de las horas permitidas
        if(currentTime < restrictionTime.start_time || currentTime > restrictionTime.end_time) throw new Error('No esta en las horas permitidas de votacion');
    }

    //Verificar que la propuesta siga abierta en el rango de fechas definido
    if (now < session.startDate || now > session.endDate) throw new Error('La sesión de votación está fuera de su rango de fechas');

    // Registrar el voto en la base de datos asociando la propuesta, fecha y decisión
    let eligibility = record;

    //Array que guardará todos los id de las opciones que eligió el usuario
    const allOptionIds = [];

    for (const answer of body.ballot.answers) 
    {
        if (Array.isArray(answer.optionsid)) 
        {
            allOptionIds.push(...answer.optionsid); //Guarda los elementos del array answer.optionsid en allOptionIds, los ... nos ayuda a que no se guarde un array dentro de otro array
        }
    }
    
    //Tomamos todas las decisiones del usuario y las transformamos en un string
    const votoString = JSON.stringify(body.ballot.answers);

    let vote = votoString

    let vote_userid = user.userid

    //Ver si la votacion es secreta
    if(session.voteTypeid==1)
    {
        // Cifrar el voto utilizando la llave vinculada a la identidad del votante
            // Convertir la clave recibida a Buffer real osea a un objeto binario que Node.js pueda manejar
        const keyBuffer = Buffer.from(data.userkey.publicKey.data);
            // Derivar una clave de 256 bits para AES para obtener una clave simétrica de 32 bytes
        const aesKey = crypto.createHash('sha256').update(keyBuffer).digest();
         
        //Crea un objeto cipher para cifrar usando AES con clave de 256 bits No se usa IV (null) porque ECB no requiere vector de inicialización
        const cipher = crypto.createCipheriv('aes-256-ecb', aesKey, null);
        //Cifra el contenido de votoString codificado como utf8, y el resultado lo entrega en base64.
        vote = cipher.update(votoString, 'utf8', 'base64');
        // Completa el proceso de cifrado y añade los datos restantes en formato base64 al resultado.
        vote += cipher.final('base64');

        //Asigna null al vote_userid para anular la asociación con el votante, manteniendo el voto anónimo.
        vote_userid = null
    }

    //Obtener la propuesta a la que se hace la votación para informar al usuario en que propuesta votó
    const propuesta = await getProposal(sessionid);

    //Inicio Transaccion
    try 
    {
        const result = await sequelize.transaction(async (t) => 
        {
            if (!eligibility) 
            {
                // Si no tiene un registro crea nuevo registro de elegibilidad
                eligibility = await createEligibility(user.userid, sessionid, t);
            }

            //Guardar el voto del usuario
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

            //Crea un backup del voto
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
                // Actualiza los resultados de la votación
                await updateCommitment(optionid, maxWeight, t);

                for (const demo of userDemographics) 
                {
                    //Actualiza las estadisticas con los datos demograficos del usuario
                    await updateDemographicStat(demo.demographicid, optionid, demo.value, t);
                }
            }
        });
        
        return {
            success: result,
            propuesta,
            fecha: new Date().toLocaleString('es-CR', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true,
                timeZone: 'America/Costa_Rica'
        }),};
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

module.exports = { vote };
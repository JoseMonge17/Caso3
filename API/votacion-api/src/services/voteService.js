const { findById, getDemographicData } = require('../data/authUserData');
const { getSessionById, getVotingRulesForSession, hasUserVoted } = require('../data/voteData');
const { getUserFromToken } = require('../auth');

async function vote(event, body) 
{
    const tokenPayload = getUserFromToken(event);

    const user = await findById(tokenPayload.id);

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
    const isAllowed = votingRules.some( // Recorre todas las reglas activas de la sesión
    rule =>
        userDemographics.some( // Por cada regla, busca si el usuario tiene un dato demográfico que coincida
        demo =>
            // El tipo de dato demográfico (por ejemplo: género, provincia) debe ser el mismo
            demo.demographicid === rule.criteria.demographicid &&
            // El valor del dato debe coincidir con el valor definido en la regla
            demo.value.toLowerCase() === rule.value.toLowerCase()
        )
    );

    //      Valida Si la votación tiene al menos un criterio y si cumple con al menos una
    if (votingRules.length > 0 && !isAllowed) 
    {
        throw new Error('Usuario no cumple con los criterios para votar en esta sesión');
    }

    //      Verificar que la propuesta siga abierta en el rango de fechas definido
    const session = await getSessionById(sessionid);
    if (!session) throw new Error('Sesión de voto no encontrada');

    const now = new Date();

    if (now < session.startDate || now > session.endDate) 
    {
        throw new Error('La sesión de votación está fuera de su rango de fechas');
    }

    //   Confirmar que el usuario no ha votado previamente en esa propuesta   
    const record = await hasUserVoted(user.userid, sessionid);
    if (record) 
    {
        if(record.voted) throw new Error('El usuario ya ha votado en esta sesión');
    }


    return { userid: user.userid, username: user.username};
}

module.exports = { vote };
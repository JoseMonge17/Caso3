const { getSession, createSession, configureQuestions, configureCriterias, searchCriterias, updateSession, configureRules, uploadRestrictedIPs, uploadRestrictedTimes, getProposalById, uploadImpactZones, uploadDirectList, hasUserVoted} = require('../data/voteData');
const { getIdUsers } = require('../data/authUserData');
const { sequelize } = require('../db/sequelize');

async function configureVoting(data, body)
{
    
    const proposal = await getProposalById(body.proposalid);
    if(!proposal) throw new Error("No existe la propuesta");

    // Validar que el usuario tenga permisos para configurar esa propuesta
    if(!data.permissions.find(p => p.code === "VOTE_MANAGE")) throw new Error("No tiene permisos para configurar esta votación");

    // Busqueda previsa de los id de los usuarios de la lista directa
    const listUsers = await getIdUsers(body.session.directList);

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

        listUsers = listUsers.filter(async (userid) => {
            const record = await hasUserVoted(userid, session.sessionid);
            return !record;
        });
    }

    
    console.log(listUsers);

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
            await configureQuestions(session.sessionid, body.session.questions, t);

            //Cargar las reglas automáticas
            await configureRules(session.sessionid, body.session.rules, t);

            //To do: Probar actualizaciones
            //Cargar restricciones de IP
            await uploadRestrictedIPs(session.sessionid, body.session.restrictedIPs, t);

            //Cargar horarios
            await uploadRestrictedTimes(session.sessionid, body.session.schedules, t);

            console.log("Listas directas")
            //Cargar listas directas
            await uploadDirectList(session.sessionid, listUsers, t);

            console.log("Zones")
            //To do: Probar actualizaciones
            //Cargar zonas de impacto de la propuesta
            await uploadImpactZones(body.proposalid, body.impact_zone, t);
        });
        
        return {
            success: true,
            mensaje: "Configuracion aplicada correctamente a la sesion de votos para la propuesta ",
            proposal
        }
    } catch (error) {
        console.error('Error en transacción de configurar voto: ', error);
        return { success: false, error: error.message };
    }
}

module.exports = { configureVoting };
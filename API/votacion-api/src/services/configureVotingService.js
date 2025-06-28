const { getSession, createSession, configureQuestions, configureCriterias, searchCriterias, updateSession, configureRules, uploadRestrictedIPs, uploadRestrictedTimes, getProposalById, uploadImpactZones, uploadDirectList, hasUserVoted} = require('../data/voteData');
const { getIdUsers } = require('../data/authUserData');
const { sequelize } = require('../db/sequelize');

async function configureVoting(data, body)
{
    //Obtener la propuesta que se le quiere realizar la configuración de la sesión y validar si existe
    const proposal = await getProposalById(body.proposalid);
    if(!proposal) throw new Error("No existe la propuesta");

    // Validar que el usuario tenga permisos para configurar esa propuesta
    if(!data.permissions.find(p => p.code === "VOTE_MANAGE")) throw new Error("No tiene permisos para configurar esta votación");

    // Busqueda previa de los id de los usuarios de la lista directa
    let listUsers = await getIdUsers(body.session.directList);

    //Validar si ya existe una session con el proposalid
    let session = await getSession(body.proposalid);

    if(session) //Si ya existe
    {
        const now = new Date();
        const startDate = new Date(session.startDate);
        // No permitir actualizar esta configuración solo hasta que inicie el periodo de votación
        if (now >= startDate) throw new Error("La sesión de votación ya ha iniciado. No se puede modificar.");

        //Actualiza los datos de la session
        session.startDate = body.session.startDate;
        session.endDate = body.session.endDate;
        session.voteTypeid = body.session.voteTypeid;
        session.sessionStatusid = 5;
        session.visibilityid =  body.session.visibilityid;

        //Si la session ya existe filtra los ids, por lo que no tienen a un registro de elegibilidad
        listUsers = listUsers.filter(async (userid) => {
            const record = await hasUserVoted(userid, session.sessionid);
            return !record;
        });
    }

    // Busqueda previa de registros de la tabla vote_criterias
    const criterias = await searchCriterias(body.session.criterios)

    //Validacion de reglas automaticas, si acepta restricciones por IP o Horarios
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
    try 
    {
        const result = await sequelize.transaction(async (t) => 
        {
            // Guardar la configuración completa de la votación en estado preparado
            // Establecer fechas de apertura y cierre de la votación
            // Especificar el tipo de votación: única, múltiple, calificación, etc.

            //Si la session ya existia la actualiza
            if(session) await updateSession(session, t);
            else 
            {
                //Si no, la crea
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

            //Guardar o actualizar las reglas automáticas
            await configureRules(session.sessionid, body.session.rules, t);

            //Guardar o actualizar las restricciones de IP
            await uploadRestrictedIPs(session.sessionid, body.session.restrictedIPs, t);

            //Guardar o actualizar las restricciones de horarios
            await uploadRestrictedTimes(session.sessionid, body.session.schedules, t);

            //Guardar las listas directas
            //Para cada userid, para crear un registro de elegibility
            await uploadDirectList(session.sessionid, listUsers, t);

            //Guardar o actualizar las zonas de impacto de la propuesta
            await uploadImpactZones(body.proposalid, body.impact_zone, t);
        });
        
        return {
            success: true,
            mensaje: "Configuracion aplicada correctamente a la sesion de votos para la propuesta ",
            proposal
        }
    } catch (error) {
        await insertLog("Fallo en la configuraciond de la votacion", body.livenessCheck.device_info, "Modulo votaciones / Configurar votacion", user.userid, "userid", 3, 7, 3);
        return { success: false, error: error.message };
    }
}

module.exports = { configureVoting };
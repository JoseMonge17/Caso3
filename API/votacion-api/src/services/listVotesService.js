const { insertLog } = require('../data/logData');
const { getLastFiveVotes, getQuestionsAndOptions, getProposal} = require('../data/voteData');
const { verifyMfaCode } = require('../data/MfaVerification');
const { saveLivenessData } = require('../data/livenessData');
const crypto = require('crypto');

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
    if(votosSecretos.length==0)
    {
        return {
            success: true,
            mensaje: "El usuario no ha realizado votaciones"
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
        hash.update(Buffer.from('VotoPuraVidaCheckSumAsegurado'));
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

module.exports = {listVotes};
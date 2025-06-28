const { insertLog } = require('../data/logData');
const { getLastFiveVotes, getQuestionsAndOptions, getProposal} = require('../data/voteData');
const { verifyMfaCode } = require('../data/MfaVerification');
const { saveLivenessData } = require('../data/livenessData');
const crypto = require('crypto');

async function listVotes(data, body) 
{
    const user = data.user

    // Validar autenticación multifactor (MFA)
    const { authenticated, error } = await verifyMfaCode(body.methodid, body.codeMFA);

    if (!authenticated) 
    {
        throw new Error(error);
    }

    // Validar comprobación de vida
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

    //Array que guardará los votos
    const votosSecretos = [];

    // Obtener la llave criptográfica del usuario y transformarla en un buffer real
    const userKey = Buffer.from(data.userkey.publicKey.data);

    // Extraer los votos asociados, descifrarlos y mostrar: propuesta, fecha y decisión (resumen, no detalle)
    for (const ballot of ballots) 
    {
        // Obtener la propuesta a la que se realizó el voto para mostrarselo al usuario
        const propuesta = await getProposal(ballot.sessionid);

        // Validacion del checksum para ver si no se malversó el voto
        const esValido = verifyChecksumBallot(ballot);

        if (!esValido) //Voto malversado
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
                decision: "Su voto fue malversado"
            })
            continue;
        }

        let voto = null

        //Si el voto no trae userid es secreto, si lo trae es público, por lo tanto no necesita desencriptarse
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
    await insertLog("Consulta auditada de últimas 5 votaciones realizada", body.livenessCheck.device_info, "Modulo votaciones / Mis ultimas 5 votaciones", user.userid, "userid", 2, 5, 1);

    //Si está vacía es que el usuario no ha realizado votos
    if(votosSecretos.length==0)
    {
        return {
            success: true,
            mensaje: "El usuario no ha participado en ninguna votación"
        }
    }
    return votosSecretos;
}

// Decodificar un Buffer a JSON legible
function decodeJson(buffer) 
{
    try 
    {
        // Convierte el Buffer binario a string UTF-8
        const jsonStr = Buffer.from(buffer).toString('utf-8');

        // Convierte el string a objeto JSON
        return JSON.parse(jsonStr);
    } catch (err) {
        console.error('Error al decodificar voto:', err);
        return null;
    }
}

// Desencripta un voto encriptado usando AES-256-ECB y la key del usuario
function desencriptarVoto(encryptedBuffer, keyBuffer) 
{
    try 
    {
        // Deriva la clave AES de 256 bits a partir del buffer de la key
        const aesKey = crypto.createHash('sha256').update(keyBuffer).digest();

        // Crea un descifrador AES en modo ECB sin IV 
        const decipher = crypto.createDecipheriv('aes-256-ecb', aesKey, null);
        decipher.setAutoPadding(true); //Se activa el relleno automático por que si el texto que se está descifrando no es múltiplo exacto de 16 bytes, hay que rellenarlo para que calce

        // Convierte el buffer en base64
        const encryptedBase64 = Buffer.from(encryptedBuffer).toString('base64');

        // Descifra el contenido paso a paso y lo convierte a UTF-8
        let decrypted = decipher.update(encryptedBase64, 'base64', 'utf8');
        decrypted += decipher.final('utf8');

        // Devuelve el resultado como JSON
        return JSON.parse(decrypted);
    } catch (err) {
        console.error('Error al desencriptar el voto secreto:', err.message);
        return null;
    }
}

// Formatea un voto descifrado y lo estructura con las descripciones de preguntas y opciones
async function formatearVotoEstructurado(voto) 
{
    // Extrae los IDs de preguntas del arreglo de respuestas
    const questionIds = voto.map(v => v.questionid);

     // Obtiene las preguntas y opciones relacionadas
    const { questions, options } = await getQuestionsAndOptions(questionIds);

    //Mapea cada respuesta que dió el usuario
    return voto.map(respuesta => 
    {
        // Busca la descripción de la pregunta correspondiente
        const pregunta = questions.find(q => q.questionid === respuesta.questionid);

        // Busca las descripciones de las opciones seleccionadas
        const respuestas = respuesta.optionsid.map(id => 
        {
            const op = options.find(o => o.optionid === id);
            return op.description;
        });

        // Devuelve el objeto estructurado
        return {
            Pregunta: pregunta ? pregunta.description : '(pregunta desconocida)',
            Respuestas: respuestas
        };
    });
}

// Verifica que el checksum del voto coincida con el generado en tiempo real (integridad del voto)
function verifyChecksumBallot(ballot) 
{
    try 
    {
        // Convierte los campos del voto a Buffer para procesarlos con hash
        const sigBuffer = Buffer.from(ballot.signature);
        const voteBuffer = Buffer.from(ballot.encryptedVote);
        const proofBuffer = ballot.proof ? Buffer.from(ballot.proof) : Buffer.alloc(0); // Si no hay prueba, usa buffer vacío

        // Genera el hash SHA-256 para construir el checksum como en el momento del registro
        const hash = crypto.createHash('sha256');
        hash.update(sigBuffer);
        hash.update(voteBuffer);
        hash.update(Buffer.from('VotoPuraVidaCheckSumAsegurado'));
        hash.update(proofBuffer);
        hash.update(Buffer.from(ballot.anonid.toString()));
        hash.update(Buffer.from(ballot.sessionid.toString()));

        // Hash generado
        const checksumGenerado = hash.digest();
        // Carga el checksum original del voto guardado
        const checksumOriginal = Buffer.from(ballot.checksum);

        // Compara ambos buffers si son iguales, la integridad se mantiene
        return checksumGenerado.equals(checksumOriginal);
    } catch (err) {
        console.error('Error verificando checksum:', err.message);
        return false;
    }
}

module.exports = {listVotes};
const { getProposalById } = require('../data/proposalData');
const { insertComment, insertRejectedCommentLog, insertAttachmentAndLink } = require('../data/commentData.js');
const { workflow } = require('../data/documentData')
const crypto = require('crypto');

async function comment(data, body) 
{
    const user = data.user;
    const { proposalid, content, attachments = [] } = body;

    //Verificar si la propuesta permite comentarios
    // Yo: 1. Validación simple de si permite comentarios
    // El Profe: 1. Si 
    const proposal = await getProposalById(proposalid);
    if (!proposal) throw new Error('Propuesta no encontrada');
    if (!proposal.allows_comments) throw new Error('Esta propuesta no permite comentarios');

    //Validar sesión activa
    if (!user) throw new Error('Usuario no encontrado');

    //      Validar estado
    if (user.status.name !== "Active") throw new Error(`Usuario en estado '${user.status.name}'`);

    //Analizar el comentario y validar que cumpla con la estructura y documentación requerida
    // Yo: 3. Analizar el comentario y validar que cumpla con la estructura y documentación requerida. Este analisis como se realizaría profe? Por medio de IA, o que los comentarios tengan requisitos para cada propuesta, si es por medio de IA, solo es preparar el proceso y simular el proceso como si lo devolviera verdadero, no?
    // El Profe: 3. En teoria en tu modelo tenes efectivamente las reglas de validacion de comentarios, y si es por medio de la Ai, haces como si la llamaras, digamos que dejas el registro que hace trigger del workflow, dejas logs y marcas el comentario como aceptado o rechazado (esto podrias hacerlo con un random)
    const passedValidation = Math.random() > 0.25; // Simulación IA: 75% chance éxito

    //Procesar validación automática de documentos o contenido adjunto (uso de IA opcional)
    // Yo: 4. Procesar validación automática de documentos o contenido adjunto (uso de IA opcional): Esto se podría realizar con los workflows, no?
    // El Profe: 4. lo mismo que puse en 3
    const timestamp = new Date();
    const integrityHash = crypto
        .createHash('sha256')
        .update(`${user.userid}|${content}|${timestamp.toISOString()}`)
        .digest('hex');

    if (passedValidation)
    {
        // Validar y registrar attachments
        for (const file of attachments) {
            const validacion = await validar(file); // simula ejecución de workflow
            if (!validacion.success) {
                throw new Error(`Archivo adjunto rechazado: ${file.filename}`);
            }

            await insertAttachmentAndLink({
                proposalid,
                file,
                commentContext: {
                    userid: user.userid,
                    timestamp
                }
            });
        }

        //Si se acepta, subir el comentario a la base con metadatos de usuario, propuesta y estado
        // Yo: 5. Registro del comentario si es aprobado
        // El Profe: 5. correcto

        //Todos los comentarios deben tener un estado: pendiente, aprobado o rechazado
        // Yo: 7. Comentarios con estados
        // El Profe: 7. sip

        await insertComment({
            userid: user.userid,
            proposalid,
            content,
            status: 'approved',
            createdAt: timestamp,
            integrityHash
        });

        return { message: "Comentario aprobado y registrado correctamente" };
    }
    else
    {
        //Si se rechaza, registrar el intento con motivo del rechazo y timestamp
        // Yo: 6. Si se rechaza se guarda un log del rechazo
        // El Profe: 6. correcto en logs

        await insertRejectedCommentLog({
            userid: user.userid,
            proposalid,
            attemptedContent: content,
            reason: 'Rechazado por validación automática',
            createdAt: timestamp
        });

        return { message: "Comentario rechazado por validación automática" };
    }

    //El contenido debe almacenarse cifrado si incluye archivos o documentos sensibles
    // Yo: 8. Cifrado del contenido del comentario
    // El Profe: 8. talvez el comentario no lo cifras porque si no la demás gente no lo va a poder verlo, pero si como la firma de user, comentario, documentos, fecha en un campo para saber que efectivamente se procesó bien y que ese usuario es quien hizo el comentario
}

module.exports = { comment };
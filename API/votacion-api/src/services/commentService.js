const { getProposalById } = require('../data/proposalData');
const { insertComment, insertRejectedCommentLog, insertAttachmentAndLink } = require('../data/commentData.js');
const { workflow } = require('../data/documentData')
const crypto = require('crypto');
const { sequelize } = require('../db/sequelize');

async function comment(data, body) 
{
    const user = data.user;
    const { proposalid, content, attachments = [] } = body;

    console.log('Llegué al service')
    console.log('Usuario: '+user.userid)
    
    //Verificar si la propuesta permite comentarios
    const proposal = await getProposalById(proposalid);
    console.log(proposal)
    if (!proposal) throw new Error('Propuesta no encontrada');
    if (!proposal.allows_comments) throw new Error('Esta propuesta no permite comentarios');

    //Validar sesión activa
    if (!user) throw new Error('Usuario no encontrado');

    //      Validar estado
    if (user.status.name !== "Active") throw new Error(`Usuario en estado '${user.status.name}'`);

    //Analizar el comentario y validar que cumpla con la estructura y documentación requerida
    const passedValidation = Math.random() > 0.25; // Simulación IA: 75% chance éxito

    //Procesar validación automática de documentos o contenido adjunto (uso de IA opcional)
    const timestamp = new Date();
    const integrityHash = crypto
        .createHash('sha256')
        .update(`${user.userid}|${content}|${timestamp.toISOString()}`)
        .digest('hex');
    
    try 
    {
        const result = await sequelize.transaction(async (t) => 
        {
            if (passedValidation)
            {
                console.log("Pase validacion")
                // Validar y registrar attachments
                for (const file of attachments) {
                    const validacion = await workflow(user.userid); // simula ejecución de workflow
                    if (!validacion.success) {
                        throw new Error(`Archivo adjunto rechazado: ${file.filename}`);
                    }
                    console.log("Cree workflow")
                    await insertAttachmentAndLink({
                        proposalid,
                        file,
                        commentContext: {
                            userid: user.userid,
                            timestamp
                        }
                    });
                    console.log("Cree files")
                }

                //Si se acepta, subir el comentario a la base con metadatos de usuario, propuesta y estado

                //Todos los comentarios deben tener un estado: pendiente, aprobado o rechazado

                await insertComment({
                    userid: user.userid,
                    proposalid,
                    content,
                    status: 'approved',
                    createdAt: timestamp,
                    integrityHash
                });
                console.log("Cree Comentario")
                return { message: "Comentario aprobado y registrado correctamente" };
            }
            else
            {
                //Si se rechaza, registrar el intento con motivo del rechazo y timestamp

                await insertRejectedCommentLog({
                    userid: user.userid,
                    proposalid,
                    attemptedContent: content,
                    reason: 'Rechazado por validación automática',
                    createdAt: timestamp
                });

                return { message: "Comentario rechazado por validación automática" };
            }
        })
    } catch (error) {
        console.error('Error en transacción de voto: ', error);
        return { success: false, error: error.message };
    }
    //El contenido debe almacenarse cifrado si incluye archivos o documentos sensibles
}

module.exports = { comment };
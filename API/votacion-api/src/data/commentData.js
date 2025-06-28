const { VpvProposalComment, VpvLog, VpvDigitalDocument, VpvProposalDocumentComment } = require('../db/sequelize');
const crypto = require('crypto');
/**
 * Inserta un comentario aprobado en la tabla de comentarios
 */
async function insertComment({ userid, proposalid, content, status, createdAt, integrityHash },documentids, transaction) {
    let doc = await VpvProposalComment.create({
        userid,
        proposalid,
        content: content,
        publish: new Date(),
        statusid: 1,
        checksum: integrityHash
    }, { transaction });

    console.log(doc)
    for(const idDoc of documentids)
    {
        
        // Relacionarlo al comentario/propuesta
        await VpvProposalDocumentComment.create({
            proposal_commentid: doc.proposal_commentid,
            documentid: idDoc,
            enabled: 1
        }, { transaction });
    }
}

/**
 * Registra un intento de comentario rechazado en la tabla de logs
 */
async function insertRejectedCommentLog({ userid, proposalid, attemptedContent, reason, createdAt }) {
    await VpvLog.create({
        description: `Comentario rechazado: ${reason}`,
        posttime: createdAt,
        computer: 'Comentario API',
        trace: attemptedContent,
        reference_id1: userid,
        reference_id2: proposalid,
        value1: 'Comentario',
        value2: reason,
        checksum: 'rejected-comment',
        log_typeid: 2,        // asumido tipo 2: validación/rechazo
        log_sourceid: 1,      // módulo comentarios
        log_severityid: 3     // nivel de severidad medio
    });
}

/**
 * Inserta un archivo y lo vincula al comentario/propuesta
 */
async function insertAttachmentAndLink({ proposalid, file, commentContext }, transaction) {
    // Ruta física del archivo (ajusta si estás en entorno cloud/S3)
    const hash = crypto
        .createHash('sha256')
        .update(`${file.filename}-${file.size}-${file.mimetype || 'application/octet-stream'}`)
        .digest('hex');

    const checksum = crypto
        .createHash('md5')
        .update(`${file.filename}-${file.size}-${file.mimetype || 'application/octet-stream'}`)
        .digest('hex');

    // Metadata simulada
    const metadata = JSON.stringify({
        filename: file.filename,
        mimetype: file.mimetype || 'application/octet-stream',
        size: file.size,
        hash,
        checksum,
        uploaded_at: commentContext.timestamp
    });
    // Insertar documento digital
    const doc = await VpvDigitalDocument.create({
        name: file.filename,
        url: file.url,
        hash,
        metadata,
        validation_date: null,
        requestid: 1,
        document_typeid: 1
    }, { transaction });

    return doc
}

module.exports = {
    insertComment,
    insertRejectedCommentLog,
    insertAttachmentAndLink
};
const { VpvProposalComment, VpvLog, VpvDigitalDocument, VpvProposalDocumentComment } = require('../db/sequelize');

/**
 * Inserta un comentario aprobado en la tabla de comentarios
 */
async function insertComment({ userid, proposalid, content, status, createdAt, integrityHash }) {
    await VpvProposalComment.create({
        userid,
        proposalid,
        content,
        status,
        created_at: createdAt,
        integrity_hash: integrityHash
    });
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
async function insertAttachmentAndLink({ proposalid, file, commentContext }) {
    // Insertar documento digital
    const doc = await VpvDigitalDocument.create({
        filename: file.filename,
        storage_url: file.url,
        filesize: file.size,
        uploaded_at: commentContext.timestamp,
        uploaded_by: commentContext.userid
    });

    // Relacionarlo al comentario/propuesta
    await VpvProposalDocumentComment.create({
        proposalid,
        documentid: doc.documentid,
        linked_at: commentContext.timestamp
    });
}

module.exports = {
    insertComment,
    insertRejectedCommentLog,
    insertAttachmentAndLink
};
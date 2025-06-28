// Importa la función de la capa de data que ejecuta el stored procedure (SP)
const { createOrUpdateProposal } = require('../data/createUpdatePropData');

// Función principal que orquesta la preparación de datos para enviar al SP
async function procesarCrearActualizarPropuestaSP(body, user) {
  // Extrae el ID del usuario autenticado (proviene del contexto de autorización)
  const userid = user.userid;

  // Parsea el body recibido desde el handler (ya debe venir como JSON string)
  const input = JSON.parse(body || '{}');

  // ----------------------------
  // Validaciones mínimas requeridas
  // ----------------------------
  const camposFaltantes = [];

  if (!input.name) camposFaltantes.push('name');                             // Nombre de la propuesta
  if (!input.description) camposFaltantes.push('description');               // Descripción general
  if (input.origin_typeid == null) camposFaltantes.push('origin_typeid');    // Origen (tipo de origen)
  if (input.proposal_typeid == null) camposFaltantes.push('proposal_typeid'); // Tipo de propuesta
  if (!Array.isArray(input.documents)) camposFaltantes.push('documents (debe ser array)'); // Documentos requeridos

  // Si falta algún campo, lanza un error que será capturado por el handler
  if (camposFaltantes.length > 0) {
    throw {
      statusCode: 400,
      message: `Faltan campos obligatorios: ${camposFaltantes.join(', ')}`
    };
  }

  // ----------------------------
  // Preparar los parámetros a enviar al SP
  // ----------------------------
  const params = {
    name: input.name,
    description: input.description,
    origin_typeid: input.origin_typeid,
    userid, // Se obtiene del token, no del frontend
    proposal_typeid: input.proposal_typeid,
    entityid: input.entityid ?? null,                 // Puede no estar presente (null si no aplica)
    allows_comments: input.allows_comments ?? false,  // Comentar permitido o no (valor por defecto: false)
    documents: input.documents,                       // Lista de documentos (normalizados en el handler)
    target_population: input.target_population ?? [], // Lista de ids de demografía (puede venir vacía)
    version_comment: input.version_comment ?? null    // Comentario opcional de versión
  };

  // Ejecutar el SP mediante la función de la capa data y retornar su resultado
  return await createOrUpdateProposal(params);
}

// Exportar la función para uso en el handler
module.exports = { procesarCrearActualizarPropuestaSP };
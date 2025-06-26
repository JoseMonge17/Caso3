**Caso #3**

**Voto Pura Vida**

IC-4301 Bases de Datos I

Instituto Tecnológico de Costa Rica

Campus Tecnológico Central Cartago

Escuela de Ingeniería en Computación

II Semestre 2024

Prof. Msc. Rodrigo Núñez Núñez

Carlos José Ávalos Mendieta

Carné: 2024207640

José Julián Monge Brenes

Carné: 2024247024

José Daniel Monterrosa Quirós

Carné: 2024084503

Rodrigo Sebastian Donoso Chaves

Carné: 2024070154

Victor Andrés Fung

Carné: 

Fecha de entrega: 28 de junio de 2025

# Índice

- [Diseño de la base de datos](#diseño-de-la-base-de-datos)
- [Implementación de la API](#implementación-de-la-api)
  - [Endpoints implementados por Stored Procedures](#endpoints-implementados-por-stored-procedures)
    - [Endpoint crearActualizarPropuesta](#endpoint-crearactualizarpropuesta)
    - [Endpoint revisarPropuesta](#endpoint-revisarpropuesta)
    - [Endpoint invertir](#endpoint-invertir)
    - [Endpoint repartirDividendos](#endpoint-repartirdividendos)
  - [Endpoints implementados por ORM](#endpoints-implementados-por-orm)
    - [Endpoint votar](#endpoint-votar)
    - [Endpoint comentar](#endpoint-comentar)
    - [Endpoint listarVotos](#endpoint-listarvotos)
    - [Endpoint configurarVotacion](#endpoint-configurarvotacion)
- [Dashboard de consultas](#dashboard-de-consultas)

# Diseño de la base de datos

# Implementación de la API

## Endpoints implementados por Stored Procedures

### Endpoint crearActualizarPropuesta
### Endpoint revisarPropuesta
### Endpoint invertir
### Endpoint repartirDividendos

## Endpoints implementados por ORM

### Endpoint votar
http://localhost:3000/dev/api/vote

#### JSON de prueba
```json
{
    "methodid": "1",
    "codeMFA": "123456",
    "livenessCheck": 
    {
        "check_type": "Facial Recognition",
        "check_date": "2025-06-15T14:00:00",
        "result": true,
        "confidence_score": 97.25,
        "algorithm_used": "FaceNet v3",
        "device_info": "Pixel 6 - Android 13",
        "requestid": 2
    },
    "biometricMedia": 
    [
        {
        "filename": "selfie_front.jpg",
        "storage_url": "https://example.com/uploads/selfie_front.jpg",
        "file_size": 245000,
        "uploaddate": "2025-06-15T14:00:05",
        "hashvalue": "aabbccddeeff00112233445566778899",
        "encryption_key_id": "key1",
        "is_original": true,
        "biotypeid": 1,
        "mediatypeid": 1
        },
        {
        "filename": "selfie_left.jpg",
        "storage_url": "https://example.com/uploads/selfie_left.jpg",
        "file_size": 235000,
        "uploaddate": "2025-06-15T14:00:06",
        "hashvalue": "112233445566778899aabbccddeeff00",
        "encryption_key_id": "key2",
        "is_original": false,
        "biotypeid": 1,
        "mediatypeid": 1
        },
        {
        "filename": "selfie_right.jpg",
        "storage_url": "https://example.com/uploads/selfie_right.jpg",
        "file_size": 228000,
        "uploaddate": "2025-06-15T14:00:07",
        "hashvalue": "ffeeddccbbaa99887766554433221100",
        "encryption_key_id": "key3",
        "is_original": false,
        "biotypeid": 1,
        "mediatypeid": 1
        }
    ],
    "sessionid": 1,
    "ballot": 
    {
        "voteDate": "2025-06-15T15:45:00",
        "signature": "ZmluZ2VycHJpbnQ=",  
        "proof": "cHJvb2ZfZGVfY29ub2NpbWllbnRl",
        "answers": 
        [
            {
                "questionid": 1,
                "optionsid": [1]
            }
        ]
    }
}
```

#### Código

Donde se llama el handler en el function
```javascript
const { vote } = require('../services/voteService');

module.exports.handler = async (event) => 
{
    try 
    {
        // Aqui se llama la data del usuario que provee el middleware una vez realizado el proceso de autorización
        const data = JSON.parse(event.requestContext.authorizer.data);

        // Nos traemos la información enviada por la aplicación o en este caso el Postman
        const body = JSON.parse(event.body);

        // Llamada a la función del service correspondiente donde se va a manejar toda la lógica
        const result = await vote(data, body);

        // Retorno de la API para mostrar en la aplicación o en este caso el Postman
        return {
            statusCode: 200,
            body: JSON.stringify(result)
        };

    } catch (error) 
    {
        // Retorno en caso de error de la API para mostrar en la aplicación o en este caso el Postman
        return {
            statusCode: 400,
            body: JSON.stringify({ error: error.message })
        };
    }
};
```

Función en el service donde se va a realizar toda la lógica del endpoint
```javascript
const { getDemographicData } = require('../data/authUserData');
const { insertLog } = require('../data/logData');
const { getSessionById, getVotingRulesForSession, hasUserVoted, registerEncryptedVote, createEligibility, updateDemographicStat, updateCommitment, backupVote, getRestrictionTime, getRestrictionIPs, getCountriesByUserId, getProposal} = require('../data/voteData');
const { sequelize } = require('../db/sequelize');
const { verifyMfaCode } = require('../data/MfaVerification');
const { saveLivenessData } = require('../data/livenessData');
const crypto = require('crypto');

async function vote(data, body) 
{
    const user = data.user
    
    // Validar autenticación multifactor (MFA)
    const { authenticated, error } = await verifyMfaCode(body.methodid, body.codeMFA);

    if (!authenticated) throw new Error(error);

    // Validar comprobación de vida
    const result = await saveLivenessData(body.livenessCheck, body.biometricMedia, user.userid);

    if(!result.success) throw new Error(result.error);

    if(!body.livenessCheck.result) throw new Error("Identidad no confirmada")

    // Confirmar existencia activa del ciudadano en el sistema
    if (!user) throw new Error('Usuario no encontrado');

    //      Validar estado
    if (user.status.name !== "Active") throw new Error(`Usuario en estado '${user.status.name}'`);

    //Verificar si el usuario está habilitado para votar en esa propuesta según su perfil
    //      Validar que se envio una sesion de votos
    const sessionid = body.sessionid;
    if (!sessionid) throw new Error('No envió votación');

    // Funcion sencilla que se trae la session de votos por medio del PK
    const session = await getSessionById(sessionid);

    if (!session) throw new Error('Sesión de voto no encontrada');

    //      Obtener datos demograficos del usuario
    const userDemographics = await getDemographicData(user.userid);

    //Peso que va a tener el usuario en su voto
    let maxWeight = 0;

    //Confirmar que el usuario no ha votado previamente en esa propuesta   
    const record = await hasUserVoted(user.userid, sessionid);
    if (record) //Si el usuario está en lista directa o tiene un registro de voto, verifica si ya votó, si tiene un registro y no voto es que está en lista directa
    {
        if(record.voted) throw new Error('El usuario ya ha votado en esta sesión');

        maxWeight = 1;
    }
    else // Si el usuario no esta en lista directa tiene que pasar por el siguiente filtro para ver si puede votar o no
    {
        //Obtener los criterios de voto de la sesión de votos
        const votingRules = await getVotingRulesForSession(sessionid);

        //      Verifica si el usuario cumple con al menos una regla de votación activa
        //Se podria asimilar a dos for anidados, y se realiza una validación de que si el demographic es el mismo y value de cada uno tambien cumple con la regla
        const matchingRules = votingRules.filter(rule =>
            userDemographics.some(demo =>
                demo.demographicid === rule.criteria.demographicid &&
                demo.value.toLowerCase() === rule.value.toLowerCase()
            )
        );

        // Verifica si cumple al menos una regla
        const isAllowed = matchingRules.length > 0;

        // Obtiene el mayor peso entre las reglas que el usuario cumple
        //Valida si cumplió con una regla si no se le asigna 0
        //El .reduce recorre el array de matchingRules y va va acumulando el valor máximo encontrado.
        //Math.max, compara el maximo anterior con el que viene en la regla
        maxWeight = isAllowed ? matchingRules.reduce((max, rule) => Math.max(max, parseFloat(rule.weight)), 0) : 0;
        
        //      Valida Si la votación tiene al menos un criterio y si cumple con al menos una
        if (votingRules.length > 0 && !isAllowed) throw new Error('Usuario no cumple con los criterios para votar en esta sesión');

        // Ver si la sesion de votos permite el IP del usuario
        //Obtener todos los paises que pertenece el usuario por medio de los address
        const countriesUser = await getCountriesByUserId(user.userid);

        //Por medio de los ids de los paises, va a traerse todas las restricciones de la sesión de votos donde coincidan con los paises
        const restrictionIPs = await getRestrictionIPs(sessionid, countriesUser);

        // Convierte la ip en un número
        const ip= ipToNumber(body.IP)

        for (const record of restrictionIPs) 
        {
            // Convierte las ip en números
            const initialIPNum = ipToNumber(record.initial_IP);
            const endIPNum = ipToNumber(record.end_IP);

            //Valida si la IP está en el rango del registro
            if (ip >= initialIPNum && ip <= endIPNum) 
            {
                // Si no está permitido no lo deja votar
                if (!record.allowed) throw new Error('IP no permitida para votar');
            }
        }
    }

    //Formato de fechas y obtener el número del día
    const now = new Date();
    const day = now.getDay();
    if(day==0) day=7;

    const currentTime = now.toLocaleTimeString('en-GB');

    // Ver si la sesion de votos tiene restriccion de horarios
    const restrictionTime = await getRestrictionTime(sessionid, day);

    // Si existe mínimo una restriccion
    if(restrictionTime)
    {
        //Si las horas son iguales es que en ese dia no se permite votaciones
        if(restrictionTime.start_time == restrictionTime.end_time) throw new Error('La sesión de votos no permite votos hoy');

        //Valida si está fuera de las horas permitidas
        if(currentTime < restrictionTime.start_time || currentTime > restrictionTime.end_time) throw new Error('No esta en las horas permitidas de votacion');
    }

    //Verificar que la propuesta siga abierta en el rango de fechas definido
    if (now < session.startDate || now > session.endDate) throw new Error('La sesión de votación está fuera de su rango de fechas');

    // Registrar el voto en la base de datos asociando la propuesta, fecha y decisión
    let eligibility = record;

    //Array que guardará todos los id de las opciones que eligió el usuario
    const allOptionIds = [];

    for (const answer of body.ballot.answers) 
    {
        if (Array.isArray(answer.optionsid)) 
        {
            allOptionIds.push(...answer.optionsid); //Guarda los elementos del array answer.optionsid en allOptionIds, los ... nos ayuda a que no se guarde un array dentro de otro array
        }
    }
    
    //Tomamos todas las decisiones del usuario y las transformamos en un string
    const votoString = JSON.stringify(body.ballot.answers);

    let vote = votoString

    let vote_userid = user.userid

    //Ver si la votacion es secreta
    if(session.voteTypeid==1)
    {
        // Cifrar el voto utilizando la llave vinculada a la identidad del votante
            // Convertir la clave recibida a Buffer real osea a un objeto binario que Node.js pueda manejar
        const keyBuffer = Buffer.from(data.userkey.publicKey.data);
            // Derivar una clave de 256 bits para AES para obtener una clave simétrica de 32 bytes
        const aesKey = crypto.createHash('sha256').update(keyBuffer).digest();
         
        //Crea un objeto cipher para cifrar usando AES con clave de 256 bits No se usa IV (null) porque ECB no requiere vector de inicialización
        const cipher = crypto.createCipheriv('aes-256-ecb', aesKey, null);
        //Cifra el contenido de votoString codificado como utf8, y el resultado lo entrega en base64.
        vote = cipher.update(votoString, 'utf8', 'base64');
        // Completa el proceso de cifrado y añade los datos restantes en formato base64 al resultado.
        vote += cipher.final('base64');

        //Asigna null al vote_userid para anular la asociación con el votante, manteniendo el voto anónimo.
        vote_userid = null
    }

    //Obtener la propuesta a la que se hace la votación para informar al usuario en que propuesta votó
    const propuesta = await getProposal(sessionid);

    //Inicio Transaccion
    try 
    {
        const result = await sequelize.transaction(async (t) => 
        {
            if (!eligibility) 
            {
                // Si no tiene un registro crea nuevo registro de elegibilidad
                eligibility = await createEligibility(user.userid, sessionid, t);
            }

            //Guardar el voto del usuario
            await registerEncryptedVote(
            {
                sessionid,
                eligibility,
                encryptedVote: vote,
                signature: body.ballot.signature,
                proof: body.ballot.proof,
                userid: vote_userid,
                transaction: t
            });

            //Crea un backup del voto
            await backupVote({
                sessionid,
                eligibility,
                encryptedVote: vote,
                signature: body.ballot.signature,
                proof: body.ballot.proof,
                transaction: t
            });

            // Sumarizar el voto dentro de la colección de resultados cifrados sin exponer contenido
            for (const optionid of allOptionIds) 
            {
                // Actualiza los resultados de la votación
                await updateCommitment(optionid, maxWeight, t);

                for (const demo of userDemographics) 
                {
                    //Actualiza las estadisticas con los datos demograficos del usuario
                    await updateDemographicStat(demo.demographicid, optionid, demo.value, t);
                }
            }
        });
        
        return {
            success: result,
            propuesta,
            fecha: new Date().toLocaleString('es-CR', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true,
                timeZone: 'America/Costa_Rica'
        }),};
    } catch (error) {
        await insertLog("Fallo en la votacion realizada", body.livenessCheck.device_info, "Modulo votaciones / Realizar votacion", user.userid, "userid", 2, 1, 3);
        console.error('Error en transacción de voto: ', error);
        return { success: false, error: error.message };
    }
}

const ipToNumber = (ip) => 
{
    return ip.split('.').reduce((acc, octet) => (acc << 8) + parseInt(octet), 0) >>> 0;
};

module.exports = { vote };
```

Funciones de llamada de la carpeta data, la cuál realiza el manejo de datos

Validación del MFA
```javascript
async function verifyMfaCode(method_id, code)
{
    //Encriptación del código brindado
    const hashedCode = crypto.createHash('sha256').update(code).digest();

    //Busca por medio del código y el método de MFA si lo puede verificar
    const record = await MFACode.findOne({
        where: {
            method_id,
            code_hash: hashedCode,
            code_status: 'PENDING',
            remaining_attempts: { [Op.gt]: 0 } //Op es un operador de sequelize //Op.gt significa mayor que, por lo tanto busca algún registro que en ese campo sea mayor que cero.
        }
    });

    if (!record) {
        return { authenticated: false, error: 'Código inválido o expirado' };
    }

    // Código válido, actualizar status
    record.code_status = 'VERIFIED';
    await record.save();

    return { authenticated: true, message: 'Autenticación MFA completada' };
}
```

Guardar el registro de la prueba de vida
```javascript
async function saveLivenessData(payload, biometricMedia, userid) {
    try 
    {
        const result = await sequelize.transaction(async (t) => 
        {
            // Crear el registro de liveness
            const liveness = await VpvLivenessCheck.create({
                check_type: payload.check_type,
                check_date: new Date(payload.check_date),
                result: payload.result,
                confidence_score: payload.confidence_score,
                algorithm_used: payload.algorithm_used,
                device_info: payload.device_info,
                userid: userid,
                requestid: payload.requestid
            }, { transaction: t });

            // Crear y asociar los registros y media biométricos
            for (const media of biometricMedia) 
            {
                const mediaRecord = await VpvBiometricMedia.create({
                    filename: media.filename,
                    storage_url: media.storage_url,
                    file_size: media.file_size,
                    uploaddate: new Date(media.uploaddate),
                    hashvalue: Buffer.from(media.hashvalue, 'hex'),
                    encryption_key_id: media.encryption_key_id,
                    is_original: media.is_original,
                    userid: userid,
                    biotypeid: media.biotypeid,
                    mediatypeid: media.mediatypeid
                }, { transaction: t });

                await VpvLivenessCheckMedia.create({
                    livenessid: liveness.livenessid,
                    biomediaid: mediaRecord.biomediaid
                }, { transaction: t });
            }

            return { success: true, message: 'Datos de liveness guardados correctamente' };
        });

        return result;

    } catch (error) {
        console.error('Error en transacción de liveness:', error);
        return { success: false, error: error.message };
    }
}
```

Obtener los registros de las restricciones de las IP´s
```javascript
async function getRestrictionIPs(sessionid, countriesid)
{
    //Busca todos los registros de la tabla intermetida VoteSessionIpPermission y se trae incluidos de una vez todos los whitelists
    const whitelistRecords = await VoteSessionIpPermission.findAll({
        where: { sessionid, allowed: false },
        include: [{
            model: VpvWhitelist,
            required: true,
            where: {
                countryid: {
                    [Op.in]: countriesid //Op.in es un operador de sequelize que se puede igualar al IN( ) de SQL
                }
            }
        }],
    });

    //Recorre todos los registros y obtienes los datos que vamos a ocupar para las validaciones de ip
    const restrictions = whitelistRecords.map(record => ({
        initial_IP: record.VpvWhitelist.initial_IP,
        end_IP: record.VpvWhitelist.end_IP,
        countryid: record.VpvWhitelist.countryid,
        allowed: record.allowed,
    }));

    return restrictions;
}
```

Función para registrar el voto de un usuario
```javascript
async function registerEncryptedVote({ sessionid, eligibility, encryptedVote, signature, proof, transaction, userid }) 
{
    // Convierte la firma de base64 a un Buffer (formato binario)
    const sigBuffer = Buffer.from(signature, 'base64');
    // Convierte el voto a un Buffer, dependiendo de si el userid es nulo o no
    // Si no es nulo, el voto se trata como un string codificado en 'utf-8'
    // Si es nulo, se trata como base64
    const voteBuffer = userid ? Buffer.from(encryptedVote, 'utf-8') : Buffer.from(encryptedVote, 'base64');
    // Convierte proof a un Buffer Si no existe, se asigna un Buffer vacío
    const proofBuffer = proof ? Buffer.from(proof, 'base64') : Buffer.alloc(0);

    // Crea un hash SHA-256 para realizar el checksum de la información
    const hash = crypto.createHash('sha256');
    // Agrega la información del voto
    hash.update(sigBuffer);
    hash.update(voteBuffer);
    // Agrega una constante para verificar la integridad y asegurar la autenticidad
    hash.update(Buffer.from("VotoPuraVidaCheckSumAsegurado")); 
    hash.update(proofBuffer);
    hash.update(Buffer.from(eligibility.elegibilityid.toString()));
    hash.update(Buffer.from(sessionid.toString()));

    // Genera el checksum final usando el hash
    const checksum = hash.digest();

    //Registra el voto
    await VoteBallot.create({
        signature: sigBuffer,
        encryptedVote: voteBuffer,
        proof: proofBuffer,
        checksum,
        anonid: eligibility.elegibilityid,
        sessionid,
        userid
    }, { transaction });

    //Actualiza el registro, indicando que el usuario ya votó
    await VoteElegibility.update(
        { voted: true },
        { where: { elegibilityid: eligibility.elegibilityid }, transaction }
    );

    return { message: 'Voto registrado correctamente con verificación de integridad.' };
}
```

```javascript
```
```javascript
```
```javascript
```
```javascript
```
```javascript
```
### Endpoint comentar
### Endpoint listarVotos
### Endpoint configurarVotacion

# Dashboard de consultas
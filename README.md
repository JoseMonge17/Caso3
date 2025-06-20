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
        "hashvalue": "aabbccddeeff00112233445566778899",  // en backend convertís esto a Buffer
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
async function vote(data, body) 
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

    //Verificar si el usuario está habilitado para votar en esa propuesta según su perfil
    //      Validar que se envio una sesion de votos
    const sessionid = body.sessionid;
    if (!sessionid) throw new Error('No envió votación');

    //      Obtener los criterios para votar y los datos demograficos del usuario
    const userDemographics = await getDemographicData(user.userid);
    const votingRules = await getVotingRulesForSession(sessionid);

    //      Verifica si el usuario cumple con al menos una regla de votación activa

    const matchingRules = votingRules.filter(rule =>
        userDemographics.some(demo =>
            demo.demographicid === rule.criteria.demographicid &&
            demo.value.toLowerCase() === rule.value.toLowerCase()
        )
    );
    // Verifica si cumple al menos una regla
    const isAllowed = matchingRules.length > 0;

    // Obtiene el mayor peso entre las reglas que el usuario cumple
    const maxWeight = isAllowed ? matchingRules.reduce((max, rule) => Math.max(max, parseFloat(rule.weight)), 0) : 0;
    
    //      Valida Si la votación tiene al menos un criterio y si cumple con al menos una
    if (votingRules.length > 0 && !isAllowed) 
    {
        throw new Error('Usuario no cumple con los criterios para votar en esta sesión');
    }

    //Verificar que la propuesta siga abierta en el rango de fechas definido
    const session = await getSessionById(sessionid);
    if (!session) throw new Error('Sesión de voto no encontrada');

    const now = new Date();

    if (now < session.startDate || now > session.endDate) 
    {
        throw new Error('La sesión de votación está fuera de su rango de fechas');
    }

    //Confirmar que el usuario no ha votado previamente en esa propuesta   
    const record = await hasUserVoted(user.userid, sessionid);
    if (record) 
    {
        if(record.voted) throw new Error('El usuario ya ha votado en esta sesión');
    }

    // Registrar el voto en la base de datos asociando la propuesta, fecha y decisión
    let eligibility = record;

    const allOptionIds = [];

    for (const answer of body.ballot.answers) 
    {
        if (Array.isArray(answer.optionsid)) 
        {
            allOptionIds.push(...answer.optionsid);
        }
    }
    
    const votoString = JSON.stringify(body.ballot.answers);

    let vote = votoString

    let vote_userid = user.userid

    //Ver si la votacion es secreta
    if(session.sessionStatusid==1)
    {
        // Cifrar el voto utilizando la llave vinculada a la identidad del votante
            // Convertir la clave recibida a Buffer real
        const keyBuffer = Buffer.from(data.userkey.publicKey.data);
            // Derivar una clave de 256 bits para AES
        const aesKey = crypto.createHash('sha256').update(keyBuffer).digest(); // 32 bytes
        
        const cipher = crypto.createCipheriv('aes-256-ecb', aesKey, null);
        vote = cipher.update(votoString, 'utf8', 'base64');
        vote += cipher.final('base64');

        vote_userid = null
    }

    //Inicio Transaccion
    try 
    {
        const result = await sequelize.transaction(async (t) => 
        {
            if (!eligibility) 
            {
                // Crear nuevo registro de elegibilidad
                eligibility = await createEligibility(user.userid, sessionid, t);
            }

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

            //Vote backup
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
                await updateCommitment(optionid, maxWeight, t);
                for (const demo of userDemographics) 
                {
                    await updateDemographicStat(demo.demographicid, optionid, demo.value, t);
                }
            }
        });
        return result;
    } catch (error) {
        console.error('Error en transacción de voto: ', error);
        return { success: false, error: error.message };
    }
}
```
### Endpoint comentar
### Endpoint listarVotos
### Endpoint configurarVotacion

# Dashboard de consultas
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

[Ver Diagrama en formato pdf](Diagrama.pdf)

# Implementación de la API

### **Estructura de la API:**  

El proyecto **Voto Pura Vida** sigue una arquitectura limpia y modular, organizada en tres capas principales: **Handlers**, **Services** y **Data**. Esta separación garantiza escalabilidad, mantenibilidad y una clara división de responsabilidades. Cada capa tiene un propósito específico y se comunica únicamente con la siguiente, evitando acoplamientos innecesarios.  

---

#### **1. Capa de Handlers**  
**Ubicación:** src/functions/  
**Responsabilidad:** Manejar solicitudes http, extraer datos de la petición y delegar la lógica a los servicios.  

- **Ejemplo:** `src/functions/distributeDividends.js`  
  ```javascript
  const { procesarDividendosSP } = require('../services/distributeDividendsService');

  module.exports.handler = async (event) => {
    const user = JSON.parse(event.requestContext.authorizer.data).user;
    try {
      const result = await procesarDividendosSP(event.body, user);
      return { statusCode: 200, body: JSON.stringify(result) };
    } catch (err) {
      return { statusCode: 500, body: JSON.stringify({ error: err.message }) };
    }
  };
  ```
  - **Flujo:**  
    1. Recibe el evento HTTP (ej: POST /api/distributeDividends).  
    2. Extrae datos del usuario desde el contexto de autorización.  
    3. Invoca el servicio correspondiente (procesarDividendosSP).  
    4. Devuelve la respuesta HTTP (éxito o error).  
---

#### **2. Capa de Services**  
**Ubicación:** src/services/  
**Responsabilidad:** Orquestar reglas de negocio, validaciones y transformaciones de datos antes de interactuar con la base de datos.  

- **Ejemplo:** `src/services/distributeDividendsService.js`  
  ```javascript
  const { distributeDividends } = require('../data/distributeDividendsData');

  async function procesarDividendosSP(body, user) {
    const input = JSON.parse(body || '{}');
    if (!input.project_id || !input.finance_report_id) {
      throw new Error('Faltan parámetros requeridos');
    }
    return await distributeDividends({ ...input, userid: user.userid });
  }
  ```
  - **Flujo:**  
    1. Valida los parámetros de entrada (ej: project_id obligatorio).  
    2. Combina datos del request con información del usuario (ej: userid).  
    3. Llama a la capa de datos (distributeDividends).  
---

#### **3. Capa de Data (Acceso a Base de Datos)**  
**Ubicación:** src/data/  
**Responsabilidad:** Interactuar directamente con la base de datos mediante **Stored Procedures** u **ORM** (Sequelize).  

- **Ejemplo con Stored Procedures:** src/data/distributeDividendsData.js  
  ```javascript
  const { executeSP, sql } = require('../db/config');

  async function distributeDividends(params) {
    const spParams = {
      projectId: params.project_id,
      UsuarioEjecutor: params.userid,
    };
    return await executeSP('SP_RepartirDividendos', spParams, {
      projectId: sql.Int,
      UsuarioEjecutor: sql.Int,
    });
  }
  ```
  - **Flujo:**  
    1. Mapea parámetros de JavaScript a tipos de SQL Server (**sql.Int**, **sql.NVarChar**).  
    2. Ejecuta el procedimiento almacenado (**executeSP**).  

- **Ejemplo con ORM (Sequelize):** src/data/authUserData.js  
  ```javascript
  const { User } = require('../db/sequelize');

  async function findById(userid) {
    return await User.findByPk(userid, {
      include: [{ model: UserStatus, as: 'status' }]
    });
  }
  ```
  - **Ventajas:**  
    - Consultas legibles y tipadas.  
    - Relaciones predefinidas (ej: **User ↔ UserStatus**).  

---

#### **4. Configuración de la Base de Datos**  
**Ubicación:** src/db/  
- **config.js:** Conexión a SQL Server con mssql.  
  ```javascript
  const config = {
    user: 'votouser',
    server: 'localhost',
    database: 'VotoPuraVida',
    options: { encrypt: true }
  };
  ```
- **sequelize.js:** Modelos de Sequelize (ej: User, VoteSession).  
  ```javascript
  const User = sequelize.define('vpv_users', {
    userid: { type: DataTypes.INTEGER, primaryKey: true },
    username: { type: DataTypes.STRING(100) },
  });
  ```

---

**Ejemplo completo (End-to-End):**  
1. Un cliente envía `POST /api/distributeDividends` con un JWT válido.  
2. El **handler** extrae el `userid` del token y pasa el cuerpo de la petición al **service**.  
3. El **service** valida los campos y envía los datos a la capa **data**.  
4. La capa **data** ejecuta un stored procedure en SQL Server u ORM y devuelve los resultados.  

---

### **Middleware de Autorización:**  

El middleware de autorización en **Voto Pura Vida** actúa como un guardián de seguridad para todos los endpoints protegidos. Su función principal es validar la identidad del usuario, verificar sus permisos y enriquecer el contexto de la solicitud con datos críticos (como roles, claves públicas y sesiones activas). A continuación, se describe su implementación paso a paso:

---

#### **1. Configuración en `serverless.yml`**  
Cada endpoint protegido declara el middleware *authorizerFunction* en su configuración. Por ejemplo:  
```yaml
functions:
  vote:
    handler: src/functions/vote.handler
    events:
      - http:
          path: /api/vote
          method: post
          authorizer:
            name: authorizerFunction  # Nombre de la función Lambda del autorizador
            type: token               # Tipo de autorización (JWT)
```

- **type: token**: Indica que el cliente debe enviar un JWT en el header **Authorization**.  
- **Flujo**:  
  - Cuando se llama a **/api/vote**, AWS Lambda (o **serverless-offline** localmente) ejecuta primero **authMiddleware.handler**.  
  - Solo si el middleware retorna **isAuthorized: true**, se invoca el handler principal (**vote.handler**).

---

#### **2. Implementación del Middleware (`authMiddleware.js`)**  
El middleware sigue un flujo estricto de validación:  

##### **a. Extracción y Verificación del Token**  
```javascript
const token = event.authorizationToken?.split(" ")[1]; // Extrae "Bearer <token>"
const decoded = jwt.verify(token, SECRET_KEY); // Verifica firma JWT
```
- **SECRET_KEY**: Clave secreta para firmar/verificar tokens (debe almacenarse en variables de entorno en producción).  
- Si el token es inválido o está expirado, **jwt.verify** lanza un error y el middleware retorna **Effect: "Deny"**.

##### **b. Consulta a la Base de Datos**  
El middleware realiza múltiples consultas para validar la sesión y permisos:  
```javascript
const user = await getUser(decoded.id); // Obtiene usuario por ID
const session = await getSessionByToken(token); // Busca sesión activa
const permissions = await getPermissionsByUser(user.userid); // Permisos del usuario
const userkey = await getUserKeyById(session.key_id); // Clave pública del usuario
```
- **`getSessionByToken`**:  
  - Hashea el token con SHA-256 (para coincidir con el almacenado en BD).  
  - Verifica que la sesión no esté expirada (expiration_date).  
  ```javascript
  const hashedToken = crypto.createHash('sha256').update(token).digest();
  await AuthSession.findOne({ where: { session_token_hash: hashedToken } });
  ```

##### **c. Construcción del Contexto**  
Si todo es válido, el middleware empaqueta los datos en el **context**:  
```javascript
return {
  principalId: decoded.id,
  policyDocument: { /* ... */ },
  isAuthorized: true,
  context: {
    "data": JSON.stringify({
      user,        // Datos del usuario (ej: userid, roles)
      permissions, // Lista de permisos (ej: ["vote", "create_proposal"])
      userkey      // Clave pública para operaciones criptográficas
    })
  }
};
```
- **Uso en Handlers**:  
  Los endpoints acceden a estos datos desde **event.requestContext.authorizer.data**.  
  ```javascript
  // Ejemplo en distributeDividends.handler
  const user = JSON.parse(event.requestContext.authorizer.data).user;
  ```

##### **d. Manejo de Errores**  
Si falla cualquier paso, el middleware deniega el acceso:  
```javascript
return {
  principalId: "anonymous",
  policyDocument: { Effect: "Deny" },
  isAuthorized: false
};
```

---

#### **3. Capa de Servicio (`authService.js`)**  
El middleware delega la lógica de negocio a servicios especializados:  

##### **`getUser`**  
- Valida que el usuario exista y esté activo:  
  ```javascript
  if (user.status.name !== "Active") throw new Error("Usuario inactivo");
  ```

##### **`getSessionByToken`**  
- Usa el modelo `AuthSession` de Sequelize para buscar sesiones:  
  ```javascript
  const session = await AuthSession.findOne({ where: { session_token_hash: hashedToken } });
  ```

##### **`getPermissionsByUser`**  
- Consulta permisos asociados a roles del usuario:  
  ```javascript
  const permissions = await RolePermission.findAll({ 
    where: { roleid: user.roles.map(r => r.roleid) } 
  });
  ```

---

#### **4. Seguridad Adicional**  
- **Cifrado de Tokens**:  
  Los tokens de sesión se almacenan hasheados (SHA-256) en BD para prevenir robos.  
- **Validación de Claves Públicas**:  
  La clave pública (`userkey`) se usa para firmar operaciones críticas (ej: votos).  

---

### **¿Por qué esta Implementación?**  
- **Seguridad en Capas**: Combina JWT, hashing y validación en BD.  
- **Eficiencia**: Centraliza la lógica de autorización en un solo lugar.  
- **Flexibilidad**: El contexto inyectado evita repetir consultas en cada endpoint.  
- **Preparado para la Nube**: El formato del middleware es compatible con AWS API Gateway.  

Este diseño garantiza que solo usuarios autenticados y autorizados puedan interactuar con endpoints.

## Endpoints implementados por Stored Procedures

### Endpoint crearActualizarPropuesta
### Endpoint revisarPropuesta
### Endpoint invertir

#### JSON de prueba 

```json
{
  "proposalid": 2,
  "monto": 185000.00,
  "codigoPago": "PMT-USDC-20240625-1025A",
  "token": "ch_tok_26QCj2mJ7bP9H3xV5t8LkE4s",
  "metodoPagoId": 2
}
```
#### Caoa Handler (/functions/investHandler.js)

```javascript
const { procesarInversionSP } = require('../services/investService');

module.exports.handler = async (event) => {
  console.log("Iniciando handler de inversión");
  // Obtener los datos del context  
  const data = JSON.parse(event.requestContext.authorizer.data);

  //obtener solamente los datos del usuario
  const user = data.user;
  try {
    // llamar a la capa de service pasando el body y el usuario
    const result = await procesarInversionSP(event.body, user);
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" }, 
      body: JSON.stringify({ // formato que se le retorna al cliente en caso de éxito
        status: 'success',
        data: result,
        timestamp: new Date().toISOString()
      })
    };
  } catch (err) {
    // Determinar el código de estado adecuado
    const statusCode = err.statusCode || 500;
    const errorDetails = process.env.NODE_ENV === 'development' ? 
      { 
        message: err.message,
        stack: err.stack,
        ...(err.details && { details: err.details })
      } : 
      { message: err.message };
    
    return {
      statusCode,
      headers: { 
        "Content-Type": "application/json",
        "X-Request-ID": event.requestContext?.requestId || 'unknown'
      },
      body: JSON.stringify({ // formato que se le retorna al cliente en caso de error
        status: 'error',
        error: statusCode === 400 ? 'Validación fallida' : 
              statusCode === 401 ? 'No autorizado' : 
              statusCode === 403 ? 'Acceso denegado' : 
              'Error en el servidor',
        ...errorDetails,
        timestamp: new Date().toISOString()
      })
    };
  }
};
```
#### Capa Service (/services/investService.js)
```javascript
const { ejecutarInversionSP } = require('../data/investData');

async function procesarInversionSP(body, user) {
  // 1. Obtener userid del token
  const userid = user.userid; 

  // 2. Parsear y validar input
  const input = typeof body === 'string' ? JSON.parse(body || '{}') : body;

  // Validación robusta de parámetros requeridos
  const requiredParams = ['proposalid', 'monto', 'codigoPago', 'token', 'metodoPagoId'];
  const missingParams = requiredParams.filter(param => input[param] === undefined || input[param] === null);

  if (missingParams.length > 0) { 
    throw {
      statusCode: 400,
      message: {
        errorMessage: `Parámetros requeridos faltantes: ${missingParams.join(', ')}`,
        details: {
          requiredParams,
          receivedParams: Object.keys(input).filter(k => input[k] !== undefined)
        }
      }
    };
  }

  // Validación detallada de cada parámetro
  const validationErrors = [];

  // Validar proposalid
  const proposalId = parseInt(input.proposalid);
  if (isNaN(proposalId) || !Number.isInteger(proposalId) || proposalId <= 0) {
    validationErrors.push({
      param: 'proposalid',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.proposalid,
      expectedType: 'positive integer'
    });
  }

  // Validar monto
  const monto = parseFloat(input.monto);
  if (isNaN(monto) || monto <= 0) {
    validationErrors.push({
      param: 'monto',
      problem: 'Debe ser un número positivo mayor que cero',
      received: input.monto,
      expectedType: 'positive number'
    });
  }

  // Validar metodoPagoId
  const metodoPagoId = parseInt(input.metodoPagoId);
  if (isNaN(metodoPagoId)) {
    validationErrors.push({
      param: 'metodoPagoId',
      problem: 'No es un número válido',
      received: input.metodoPagoId,
      expectedType: 'integer'
    });
  } else if (!Number.isInteger(metodoPagoId) || metodoPagoId <= 0) {
    validationErrors.push({
      param: 'metodoPagoId',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.metodoPagoId,
      expectedType: 'positive integer'
    });
  }

  // Validar codigoPago
  if (typeof input.codigoPago !== 'string' || input.codigoPago.trim().length === 0) {
    validationErrors.push({
      param: 'codigoPago',
      problem: 'Debe ser una cadena de texto no vacía',
      received: input.codigoPago,
      expectedType: 'non-empty string'
    });
  }

  // Validar token
  if (typeof input.token !== 'string' || input.token.trim().length === 0) {
    validationErrors.push({
      param: 'token',
      problem: 'Debe ser una cadena de texto no vacía',
      received: input.token,
      expectedType: 'non-empty string'
    });
  }

  // Si hay errores de validación, lanzar excepción con mensaje con detalles 
  if (validationErrors.length > 0) {
    throw {
      statusCode: 400,
      message: { 
        errorMessage : 'Validación fallida para uno o más parámetros', 
        details: {
          validationErrors,
          receivedInput: input
        }
      }
    };
  }

  // 3. Preparar parámetros para el SP
  const params = {
    proposalid: proposalId,
    monto: monto,
    codigoPago: input.codigoPago.trim(),
    token: input.token.trim(),
    metodoPagoId: metodoPagoId,
    userid // Añadimos el userid obtenido del token
  };

  return await ejecutarInversionSP(params);
}

module.exports = { procesarInversionSP };
```

#### Capa Data (/data/investData.js)

```javascript
const { executeSP, sql } = require('../db/config');

async function ejecutarInversionSP(params) {
  // Mapeo de parámetros al SP
  const spParams = {
    proposalid: params.proposalid,
    userid: params.userid,
    monto: params.monto, 
    codigoPago: params.codigoPago,
    token: params.token,
    metodoPagoId: params.metodoPagoId
  };

  // Configuración de tipos SQL
  const typesConfig = {
    proposalid: sql.Int,
    userid: sql.Int,
    monto: sql.Float, 
    codigoPago: sql.NVarChar(100),
    token: sql.NVarChar(200),
    metodoPagoId: sql.Int
  };

  try {
    const result = await executeSP('SP_CF_ProcesarInversion', spParams, typesConfig);
    
    // Formatear respuesta para el cliente
    return {
      success: true,
      investmentData: {
        investmentId: result[0]?.investmentid, // id de la inversión
        equityPercentage: result[0]?.equityPercentage, // porcentaje accionario sobre el proyecto asignado
        amountInvested: parseFloat(params.monto), // monto que invirtió 
        newTotalInvested: result[0]?.newTotalInvested // el total invertido en el proyecto luego de la inversión
      },
      metadata: {
        projectId: params.proposalid,
        investorId: params.userid,
        executedAt: new Date().toISOString()
      }
    };
    
  } catch (error) {
    console.error('Error en investData:', error.message);
    throw new Error(`Error en Inversión: ${error.message}`);
  }
}

module.exports = { ejecutarInversionSP };
```

En esta capa se llama al SP correspondiente ejecutando una función que está almacenada en (db/config.js)
```javascript
async function executeSP(spName, params = {}, typesConfig = {}) {
  try {
    const pool = await sql.connect(config);
    const request = pool.request();

    Object.entries(params).forEach(([key, value]) => {
      // Usa configuración explícita o determina el tipo
      const type = typesConfig[key] || determineType(key, value);
      request.input(key, type, value);
    });

    const result = await request.execute(spName);
    return result.recordset;
  } catch (err) {
    console.error(`Error en SP ${spName}:`, err);
    throw err;
  }
}
```

#### Store Procedure Invertir
```sql

```

### Endpoint repartirDividendos

#### JSON de prueba 

```json
{
  "project_id": 3,
  "finance_report_id": 1,
  "payment_methodid": 3, 
}
```

#### Capa Handler (/functions/distributeDividends.js)

```javascript
const { procesarDividendosSP } = require('../services/distributeDividendsService');

module.exports.handler = async (event) => {
  console.log("ya llegue al distribute");
  // Obtener los datos del context 
  const data = JSON.parse(event.requestContext.authorizer.data);
  //obtener solamente los datos del usuario
  const user = data.user;
  try {
    // llamar a la capa de service pasando el body y el usuario
    const result = await procesarDividendosSP(event.body, user);
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ // formato que se le retorna al cliente en caso de éxito
        status: 'success',
        data: result,
        timestamp: new Date().toISOString()
      })
    };
  } catch (err) {
    // Determinar el código de estado adecuado
    const statusCode = err.statusCode || 500;
    const errorDetails = process.env.NODE_ENV === 'development' ? 
      { 
        message: err.message,
        stack: err.stack,
        ...(err.details && { details: err.details })
      } : 
      { message: err.message };
    
    return {
      statusCode,
      headers: { 
        "Content-Type": "application/json",
        "X-Request-ID": event.requestContext?.requestId || 'unknown'
      },
      body: JSON.stringify({ // formato que se le retorna al cliente en caso de error
        status: 'error',
        error: statusCode === 400 ? 'Validación fallida' : 
              statusCode === 401 ? 'No autorizado' : 
              statusCode === 403 ? 'Acceso denegado' : 
              'Error en el servidor',
        ...errorDetails,
        timestamp: new Date().toISOString()
      })
    };
  }
};
```

#### Capa Service (/services/distributeDividendsService.js)

```javascript
const { distributeDividends } = require('../data/distributeDividendsData');

async function procesarDividendosSP(body, user) {
  // 1. Obtener userid del token
  const userid = user.userid; 

  // 2. Parsear y validar input TODO: Todas las entradas correctas
  const input = JSON.parse(body || '{}');
   // Validación básica de parámetros requeridos

   // Validación robusta de parámetros requeridos
  const requiredParams = ['project_id', 'finance_report_id', 'payment_methodid'];
  const missingParams = requiredParams.filter(param => input[param] === undefined || input[param] === null);

  if (missingParams.length > 0) { 
    throw {
      statusCode: 400,
      message: {
        errorMessage: `Parámetros requeridos faltantes: ${missingParams.join(', ')}`,
        details: {
          requiredParams,
          receivedParams: Object.keys(input).filter(k => input[k] !== undefined)
        }
      }
    };
  }

  // Validación detallada de cada parámetro
  const validationErrors = [];

  // Validar id del proyecto dado
  const project_id = parseInt(input.project_id);
  if (isNaN(project_id) || !Number.isInteger(project_id) || project_id <= 0) {
    validationErrors.push({
      param: 'project_id',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.project_id,
      expectedType: 'positive integer'
    });
  }

  // Validar id del reporte financiero 
  const finance_report_id = parseInt(input.finance_report_id);
  if (isNaN(finance_report_id) || !Number.isInteger(finance_report_id) || finance_report_id <= 0) {
    validationErrors.push({
      param: 'finance_report_id',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.finance_report_id,
      expectedType: 'positive integer'
    });
  }

  // Validar el método de pago
  const payment_methodid = parseInt(input.payment_methodid);
  if (isNaN(payment_methodid)) {
    validationErrors.push({
      param: 'payment_methodid',
      problem: 'No es un número válido',
      received: input.payment_methodid,
      expectedType: 'integer'
    });
  } else if (!Number.isInteger(payment_methodid) || payment_methodid <= 0) {
    validationErrors.push({
      param: 'payment_methodid',
      problem: 'Debe ser un entero positivo mayor que cero',
      received: input.payment_methodid,
      expectedType: 'positive integer'
    });
  }

  // Si hay errores de validación, lanzar excepción con mensaje con detalles 
  if (validationErrors.length > 0) {
    throw {
      statusCode: 400,
      message: { 
        errorMessage : 'Validación fallida para uno o más parámetros', 
        details: {
          validationErrors,
          receivedInput: input
        }
      }
    };
  }

  // 3. Inyectar userid en los parámetros
  const params = {
    ...input,
    userid // Añadimos el userid obtenido del token
  };

  return await distributeDividends(params);
}

module.exports = { procesarDividendosSP };
```

#### Capa Data (/data/distributeDividendsData.js)

```javascript
const { executeSP, sql } = require('../db/config');

async function distributeDividends(params) {
    // Mapeo de parámetros del JSON a los del SP
    const spParams = {
        projectId: params.project_id,
        ReporteGananciasID: params.finance_report_id,
        UsuarioEjecutor: params.userid,
        PayMethodId: params.payment_methodid
    };

    // Configuración de tipos para executeSP
    const typesConfig = {
        projectId: sql.Int,
        ReporteGananciasID: sql.Int,
        UsuarioEjecutor: sql.Int,
        PayMethodId: sql.Int
    };

    try {
        const result = await executeSP('SP_RepartirDividendos', spParams, typesConfig);
    
    // Formatear respuesta para el cliente
    return {
      success: true,
      transactionId: result[0]?.TransactionID,
      amounts: {
        total: result[0]?.TotalGanancias, // total de las ganancias
        fees: result[0]?.ComisionesAplicadas, // comisiones aplicadas
        distributed: result[0]?.DistribuidoInversionistas // fondos distribuidos entre inversionistas 
      },
      metadata: {
        projectId: params.project_id,
        executedBy: params.userid
      }
    };
  } catch (error) {
    console.error('Error en distributeDividends:', error.message);
    throw new Error(`Error financiero: ${error.message}`);
  }
}

module.exports = { distributeDividends };
```

En esta capa se llama al SP correspondiente ejecutando una función que está almacenada en (db/config.js)

```javascript
async function executeSP(spName, params = {}, typesConfig = {}) {
  try {
    const pool = await sql.connect(config);
    const request = pool.request();

    Object.entries(params).forEach(([key, value]) => {
      // Usa configuración explícita o determina el tipo
      const type = typesConfig[key] || determineType(key, value);
      request.input(key, type, value);
    });

    const result = await request.execute(spName);
    return result.recordset;
  } catch (err) {
    console.error(`Error en SP ${spName}:`, err);
    throw err;
  }
}
```

#### Store Procedure Repartir Dividendos
```sql

```


## Endpoints implementados por ORM

### Endpoint votar
http://localhost:3000/dev/api/vote

#### JSON de prueba

JSON de prueba 1
```json
{
    "methodid": "1",
    "codeMFA": "123456",
    "IP": "190.35.255.1",
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

JSON de prueba 2
```json
{
    "methodid": "1",
    "codeMFA": "123456",
    "IP": "190.35.255.1",
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
    "sessionid": 2,
    "ballot": 
    {
        "voteDate": "2025-06-26T15:45:00",
        "signature": "ZmluZ2VycHJpbnQ=",  
        "proof": "cHJvb2ZfZGVfY29ub2NpbWllbnRl",
        "answers": 
        [
            {
                "questionid": 2,
                "optionsid": [3]
            },
            {
                "questionid": 3,
                "optionsid": [5,6]
            }
        ]
    }
}
```

#### Código

Donde se llama el handler del function
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
### Endpoint comentar
### Endpoint listarVotos
http://localhost:3000/dev/api/listVotes

#### JSON de prueba
```json
{
    "methodid": "1",
    "codeMFA": "123456",
    "livenessCheck": {
        "check_type": "Facial Recognition",
        "check_date": "2025-06-15T14:00:00",
        "result": true,
        "confidence_score": 97.25,
        "algorithm_used": "FaceNet v3",
        "device_info": "Pixel 6 - Android 13",
        "requestid": 2
    },
    "biometricMedia": [
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
    ]
}
```

#### Código

Donde se llama el handler del function
```javascript
const { listVotes } = require('../services/listVotesService');

module.exports.handler = async (event) => 
{
    try 
    {
        // Aqui se llama la data del usuario que provee el middleware una vez realizado el proceso de autorización
        const data = JSON.parse(event.requestContext.authorizer.data);

        // Nos traemos la información enviada por la aplicación o en este caso el Postman
        const body = JSON.parse(event.body);

        // Llamada a la función del service correspondiente donde se va a manejar toda la lógica
        const result = await listVotes(data, body);

        // Retorno de la API para mostrar en la aplicación o en este caso el Postman
        return {
            statusCode: 200,
            body: JSON.stringify(result)
        };

    } catch (error) {
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
    await insertLog("Consulta auditada de últimas 5 votaciones realizada", body.livenessCheck.device_info, "Modulo votaciones / Mis ultimas 5 votaciones", user.userid, "userid", 1, 1, 1);

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
```

Funciones de llamada de la carpeta data, la cuál realiza el manejo de datos

Función que se trae los últimos 5 votos realizados por el usuario
```javascript
async function getLastFiveVotes(userId)
{
    try 
    {
        // Buscar los últimos 5 registros de elegibilidad donde el usuario haya votado
        const elegibilities = await VoteElegibility.findAll({
            where: {
                userid: userId,
                voted: true
            },
            order: [['elegibilityid', 'DESC']],
            limit: 5
        });

        // Extraer los identificadores únicos anónimos de los resultados obtenidos
        const anonIds = elegibilities.map(e => e.elegibilityid);

        // Si no hay votos registrados, retornar un arreglo vacío
        if (anonIds.length === 0) return [];

        // Obtener los votos que coincidan con los IDs anónimos
        const ballots = await VoteBallot.findAll({
        where: {
            anonid: {
                [Op.in]: anonIds // Busca donde el campo anonid esté dentro del array de IDs
            }
        }
        });

        return ballots;
    } catch (error) {
        console.error('Error al obtener votos por userId:', error.message);
        return [];
    }
}
```
### Endpoint configurarVotacion
http://localhost:3000/dev/api/configureVoting

#### JSON de prueba

JSON de prueba 1 (Crear)
```json
{
    "proposalid": 3,
    "impact_zone": [
        {
            "zone": "Ciudadanos de bajos ingresos",
            "zone_typeid": 1,
            "impact_levelid": 3,
            "description": "Afecta directamente el presupuesto de los ciudadanos de bajos ingresos."
        },
        {
            "zone": "Instituciones Públicas de Salud",
            "zone_typeid": 2,
            "impact_levelid": 4,
            "description": "Reducción del IVA podría comprometer el financiamiento de instituciones de salud."
        },
        {
            "zone": "Empresas proveedoras de electricidad",
            "zone_typeid": 3,
            "impact_levelid": 2,
            "description": "Impacto moderado en ingresos por tarifas reguladas."
        },
        {
            "zone": "Escuelas y colegios públicos",
            "zone_typeid": 4,
            "impact_levelid": 1,
            "description": "Impacto leve en el presupuesto operativo institucional."
        }
    ],
    "session": {
        "startDate": "2025-06-20T08:00:00Z",
        "endDate": "2025-06-29T20:00:00Z",
        "voteTypeid": 1,
        "visibilityid": 1,
        "criterios": [
            {
                "code" : "M",
                "value": "Male",
                "weigth": "1"
            },
            {
                "code" : "CRC",
                "value": "Costa Rica",
                "weigth": "1"
            }
        ],
        "questions": [
            {
                "description": "¿Está de acuerdo con reducir el IVA en servicios esenciales como agua y electricidad?",
                "questionid": null,
                "required": 1,
                "max_answers": 1,
                "question_typeid": 1,
                "options": [
                    {
                        "optionid": null,
                        "description": "Sí, totalmente de acuerdo",
                        "value": "si",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 1
                    },
                    {
                        "optionid": null,
                        "description": "No estoy de acuerdo",
                        "value": "no",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 2
                    }
                ]
            },
            {
                "questionid": null,
                "description": "¿Cuáles de estos criterios considera más relevantes al evaluar esta propuesta?",
                "required": 1,
                "max_answers": 2,
                "question_typeid": 2,
                "options": [
                    {
                        "optionid": null,
                        "description": "Impacto económico",
                        "value": "impacto",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 1
                    },
                    {
                        "optionid": null,
                        "description": "Viabilidad política",
                        "value": "viabilidad",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 2
                    },
                    {
                        "optionid": null,
                        "description": "Apoyo ciudadano",
                        "value": "apoyo",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 3
                    }
                ]
            }
        ],
        "rules": [
            {
                "rule": "Aceptación por mayoría",
                "value": true
            },
            {
                "rule": "Rechazo por mayoria",
                "value": true
            },
            {
                "rule": "Rechazo falta de votos",
                "value": 100
            }
        ],
        "directList": [
            {
                "username": "santiago_contreras542",
                "identification": "5-0653-1178"
            },
            {
                "username": "diana_soto989",
                "identification": "5-0238-3737"
            },
            {
                "username": "ángel_ruiz968",
                "identification": "2-6253-7211"
            }
        ],
        "restrictedIPs":[
            {
                "initial_IP": "190.30.0.1",
                "end_IP": "190.30.255.255",
                "countryid": 1,
                "allowed": false
            },
            {
                "initial_IP": "190.31.0.1",
                "end_IP": "190.31.255.255",
                "countryid": 1,
                "allowed": false
            }
        ],
        "schedules": [
            {
                "start_time": "08:00:00",
                "end_time": "12:00:00",
                "day_of_week": 1
            },
            {
                "start_time": "14:00:00",
                "end_time": "18:00:00",
                "day_of_week": 2
            },
            {
                "start_time": "14:00:00",
                "end_time": "18:00:00",
                "day_of_week": 3
            },
            {
                "start_time": "14:00:00",
                "end_time": "18:00:00",
                "day_of_week": 4
            },
            {
                "start_time": "09:00:00",
                "end_time": "21:00:00",
                "day_of_week": 5
            },
            {
                "start_time": "07:00:00",
                "end_time": "21:00:00",
                "day_of_week": 6
            },
            {
                "start_time": "10:00:00",
                "end_time": "18:00:00",
                "day_of_week": 7
            }
        ]
    }
}
```

JSON de prueba 2 (Actualizar)
```json
{
    "proposalid": 3,
    "impact_zone": [
        {
            "zone": "Ciudadanos de bajos ingresos",
            "zone_typeid": 1,
            "impact_levelid": 3,
            "description": "Afecta directamente el presupuesto de los ciudadanos de bajos ingresos."
        },
        {
            "zone": "Instituciones Públicas de Salud",
            "zone_typeid": 2,
            "impact_levelid": 4,
            "description": "Reducción del IVA podría comprometer el financiamiento de instituciones de salud."
        },
        {
            "zone": "Empresas proveedoras de electricidad",
            "zone_typeid": 3,
            "impact_levelid": 2,
            "description": "Impacto moderado en ingresos por tarifas reguladas."
        },
        {
            "zone": "Escuelas y colegios públicos",
            "zone_typeid": 4,
            "impact_levelid": 1,
            "description": "Impacto leve en el presupuesto operativo institucional."
        }
    ],
    "session": {
        "startDate": "2025-06-30T08:00:00Z",
        "endDate": "2025-07-07T20:00:00Z",
        "voteTypeid": 1,
        "visibilityid": 1,
        "criterios": [
            {
                "code" : "SJ",
                "value": "San Jose",
                "weigth": "1"
            },
            {
                "code" : "CRC",
                "value": "Costa Rica",
                "weigth": "1"
            }
        ],
        "questions": [
            {
                "description": "¿Está de acuerdo con reducir el IVA en servicios esenciales como agua?",
                "questionid": 2,
                "required": 1,
                "max_answers": 1,
                "question_typeid": 1,
                "options": [
                    {
                        "optionid": 3,
                        "description": "Sí",
                        "value": "si",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 1
                    },
                    {
                        "optionid": 4,
                        "description": "No",
                        "value": "no",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 2
                    }
                ]
            },
            {
                "questionid": 3,
                "description": "¿Cuáles de estos criterios considera más relevantes al evaluar?",
                "required": 1,
                "max_answers": 2,
                "question_typeid": 2,
                "options": [
                    {
                        "optionid": 5,
                        "description": "Impacto económico",
                        "value": "impacto",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 1
                    },
                    {
                        "optionid": 6,
                        "description": "Viabilidad política",
                        "value": "viabilidad",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 2
                    },
                    {
                        "optionid": 7,
                        "description": "Apoyo ciudadano",
                        "value": "apoyo",
                        "url": "https://i.imgur.com/JQ7rhJe.jpeg",
                        "order": 3
                    }
                ]
            }
        ],
        "rules": [
            {
                "rule": "Aceptación por mayoría",
                "value": true
            },
            {
                "rule": "Rechazo por mayoria",
                "value": false
            },
            {
                "rule": "Rechazo falta de votos",
                "value": 50
            }
        ],
        "directList": [
            {
                "username": "carlos_ramos991",
                "identification": "7-5906-5138"
            }
        ],
        "restrictedIPs":[
            {
                "initial_IP": "190.30.0.1",
                "end_IP": "190.30.255.255",
                "countryid": 1,
                "allowed": false
            },
            {
                "initial_IP": "190.31.0.1",
                "end_IP": "190.31.255.255",
                "countryid": 1,
                "allowed": true
            }
        ],
        "schedules": [
            {
                "start_time": "08:00:00",
                "end_time": "23:00:00",
                "day_of_week": 1
            },
            {
                "start_time": "14:00:00",
                "end_time": "14:00:00",
                "day_of_week": 2
            },
            {
                "start_time": "14:00:00",
                "end_time": "18:00:00",
                "day_of_week": 3
            },
            {
                "start_time": "14:00:00",
                "end_time": "18:00:00",
                "day_of_week": 4
            },
            {
                "start_time": "09:00:00",
                "end_time": "21:00:00",
                "day_of_week": 5
            },
            {
                "start_time": "07:00:00",
                "end_time": "21:00:00",
                "day_of_week": 6
            },
            {
                "start_time": "10:00:00",
                "end_time": "18:00:00",
                "day_of_week": 7
            }
        ]
    }
}

```

#### Código

Donde se llama el handler del function
```javascript
const { configureVoting } = require('../services/configureVotingService');

module.exports.handler = async (event) => 
{
    try 
    {
        // Aqui se llama la data del usuario que provee el middleware una vez realizado el proceso de autorización
        const data = JSON.parse(event.requestContext.authorizer.data);

        // Nos traemos la información enviada por la aplicación o en este caso el Postman
        const body = JSON.parse(event.body);

        // Llamada a la función del service correspondiente donde se va a manejar toda la lógica
        const result = await configureVoting(data, body);

        // Retorno de la API para mostrar en la aplicación o en este caso el Postman
        return {
            statusCode: 200,
            body: JSON.stringify(result)
        };

    } catch (error) {
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
    const listUsers = await getIdUsers(body.session.directList);

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
    try {
        const result = await sequelize.transaction(async (t) => 
        {
            // Guardar la configuración completa de la votación en estado preparado
            // Establecer fechas de apertura y cierre de la votación
            // Especificar el tipo de votación: única, múltiple, calificación, etc.
            if(session) await updateSession(session, t);
            else 
            {
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
        console.error('Error en transacción de configurar voto: ', error);
        return { success: false, error: error.message };
    }
}

module.exports = { configureVoting };
```

Funciones de llamada de la carpeta data, la cuál realiza el manejo de datos

Función que busca los criterios brindados, y retorna los criterios con sus respectivos ID´s
```javascript
async function searchCriterias(criterias) 
{
    for (const criterio of criterias) 
    {
        // Busca un registro en la tabla VpvDemographicData que coincida con el código y valor del criterio
        const resultado = await VpvDemographicData.findOne({
            where: {
                code: criterio.code,
                description: criterio.value
            }
        });

        // Extrae el ID demográfico del resultado encontrado
        let demographicid = resultado.demographicid

        // Lo asigna al objeto criterio actual para mantener la relación
        criterio.demographicid = demographicid;

        // Busca en la tabla VoteCriteria si ya existe un criterio vinculado a ese demographicid
        let criteria = await VoteCriteria.findOne(
        {
            where: { demographicid },
            attributes: ['criteriaid']
        });

        // Si no existe ese criterio, lo crea
        if (!criteria) 
        {
            criteria = await VoteCriteria.create({
                demographicid,
                type: resultado.description,
                datatype: 'text'
            });
        }

        // Asocia el ID del criterio al objeto original
        criterio.criteriaid = criteria.criteriaid;
    }

    // Devuelve el arreglo de criterios actualizado, con demographicid y criteriaid agregados
    return criterias;
}
```

Función que crea la sesión de votos a la propuesta en caso de que no exista
```javascript
async function createSession({startDate, endDate, voteTypeid, sessionStatusid, visibilityid}, proposalid, transaction) 
{
    try 
    {
        //Crea un string random para la public_key
        const randomString = crypto.randomBytes(16).toString('hex');

        const public_key = Buffer.from(randomString, 'utf8');

        // Crear sesión de votos
        const session = await VoteSession.create({
            startDate,
            endDate,
            public_key,
            sessionStatusid,
            voteTypeid,
            visibilityid
        }, { transaction });

        await CfProposalVote.create(
            {
                date: new Date(),
                result: 0,
                sessionid: session.sessionid,
                proposalid
            }, { transaction }
        );

        return session
    } catch (error) {
        throw new Error("Error en crear la sesión de votos: " + error.message);
    }
}
```

Función que configura los criterios de aceptación para votar en la propuesta
```javascript
async function configureCriterias(sessionid, criterios, transaction) 
{
    try 
    {
        // Recorre todos los criterios enviados
        for (const criterio of criterios) 
        {
            // Verifica si ya existe una regla de votación para este criterio en la sesión dada
            const existing = await VotingRule.findOne({
                where: {
                    sessionid,
                    criteriaid: criterio.criteriaid
                }, transaction
            });

            // Si la regla ya existe, la actualiza
            if(existing)
            {
                await VotingRule.update(
                {
                    value: criterio.value,
                    weight: parseFloat(criterio.weigth),
                    enabled: true
                },
                {
                    where: 
                    {
                        sessionid,
                        criteriaid: criterio.criteriaid
                    },
                    transaction
                });
            }
            else // Si no existe, la crea desde cero
            {
                await VotingRule.create(
                {
                    value: criterio.value,
                    weight: parseFloat(criterio.weigth),
                    enabled: true,
                    sessionid,
                    criteriaid: criterio.criteriaid
                }, { transaction });
            }
        }
    } catch (error) {
        throw new Error("Error en configurar criterios: " + error.message);
    }
}
```

Función para configurar las preguntas y respuestas que tendrá la sesión de votos
```javascript
async function configureQuestions(sessionid, questions, transaction) 
{
    try 
    {
        const now = new Date();

        // Recorre todas las preguntas proporcionadas
        for (const q of questions) 
        {
            let question = q

            // Si la pregunta ya existe se actualiza
            if(q.questionid)
            {
                await VoteQuestion.update({
                    description: q.description,
                    required: !!q.required,
                    max_answers: q.max_answers,
                    updateDate: now,
                    question_typeid: q.question_typeid
                }, 
                { 
                    where:
                    { 
                        sessionid,
                        questionid: q.questionid
                    },
                    transaction
                });
            }
            else // Si la pregunta no existe aún se crea
            {
                question = await VoteQuestion.create({
                    description: q.description,
                    required: !!q.required,
                    max_answers: q.max_answers,
                    createDate: now,
                    updateDate: null,
                    question_typeid: q.question_typeid,
                    sessionid
                }, { transaction });
            }

            // Luego procesa sus opciones de respuesta
            for (const opt of q.options) 
            {
                 // Se genera un checksum basado en los datos principales de la opción
                const raw = `${opt.description}-${opt.value}-${opt.order}`;
                const checksum = crypto.createHash('sha256').update(raw).digest();

                // Si la opción ya existe se actualiza
                if(opt.optionid)
                {
                    await VoteOption.update({
                        description: opt.description,
                        value: opt.value,
                        url: opt.url,
                        order: opt.order,
                        checksum: checksum,
                        updateDate: now
                    }, 
                    { 
                        where:
                        {
                            questionid: question.questionid,
                            optionid: opt.optionid
                        },
                        transaction
                    });
                }
                else // Si la opción no existe aún se crea
                {
                    await VoteOption.create({
                        description: opt.description,
                        value: opt.value,
                        url: opt.url,
                        order: opt.order,
                        checksum: checksum,
                        createDate: now,
                        updateDate: null,
                        questionid: question.questionid
                    }, { transaction });
                }
            }
        }
    } catch (error) {
        throw new Error("Error en configurar las preguntas y respuestas: " + error.message);
    }
}
```

Función para configurar las reglas automáticas de aceptación de la sesión
```javascript
async function configureRules(sessionid, rules, transaction) 
{
    try 
    {
        // Recorre todas las reglas enviadas
        for (const rule of rules) 
        {
            //Busca el tipo de regla que se va a aplicar
            const ruleType = await VoteRule.findOne({
                where: { name: rule.rule }
            });

            // Busca si ya existe una regla de aceptación configurada para esta sesión y tipo de regla
            const existing = await VoteAcceptanceRule.findOne({
                where: {
                    sessionid,
                    rule_typeid: ruleType.ruleid
                }, transaction
            });

            // Si ya existe la regla, se actualiza con los nuevos valores
            if(existing)
            {
                await VoteAcceptanceRule.update(
                {
                    quantity: rule.value,
                    description: ruleType.name + " " + rule.value,
                    enabled: true
                },
                {
                    where: 
                    {
                        sessionid,
                        rule_typeid: ruleType.ruleid
                    },
                    transaction
                });
            }
            else // Si no existe, se crea una nueva entrada con los valores especificados
            {
                await VoteAcceptanceRule.create(
                {
                    quantity: rule.value,
                    description: ruleType.name + " " + rule.value,
                    enabled: true,
                    sessionid,
                    rule_typeid: ruleType.ruleid
                }, { transaction });
            }
        }
    } catch (error) {
        throw new Error("Error en configurar las reglas de la sesión de votos: " + error.message);
    }
}
```

Función para configurar las restricciones de IP de quienes pueden votar
```javascript
async function uploadRestrictedIPs (sessionid, restrictedIPs, transaction)
{
    try 
    {
        // Recorre cada objeto de whitelist en el arreglo recibido
        for (const ip of restrictedIPs) 
        {
            // Verifica si ya existe un rango de IPs en la whitelist con el mismo rango y país
            let whitelist = await VpvWhitelist.findOne({
                where: { 
                    initial_IP: ip.initial_IP, 
                    end_IP: ip.end_IP, 
                    countryid: ip.countryid 
                },
                transaction
            });

            // Si no existe, lo crea en la tabla de whitelist
            if (!whitelist) 
            {
                whitelist = await VpvWhitelist.create({
                    initial_IP: ip.initial_IP,
                    end_IP: ip.end_IP,
                    countryid: ip.countryid,
                    allowed: true
                }, { transaction });
            }

            // Verifica si ya existe una regla de restricción para esta sesión y este whitelistid
            const restriction = await VoteSessionIpPermission.findOne({
                where: { 
                    sessionid,
                    whitelistid: whitelist.whitelistid
                },
                transaction
            });

            // Si ya existe, la actualiza con el nuevo valor
            if(restriction)
            {
                await VoteSessionIpPermission.update(
                {
                    allowed: ip.allowed,
                },
                {
                    where: 
                    {
                        sessionid,
                        whitelistid: whitelist.whitelistid
                    },
                    transaction
                });
            }
            else // Si no existe, crea una nueva restricción IP para esta sesión
            {
                await VoteSessionIpPermission.create({
                    sessionid,
                    whitelistid: whitelist.whitelistid,
                    allowed: ip.allowed,
                    created_date: new Date(),
                }, { transaction });
            }
        }
    } catch (error) {
        throw new Error("Error en configurar la restricción de IPs: " + error.message);
    }
};
```

Función para configurar los horarios de votación
```javascript
async function uploadRestrictedTimes (sessionid, schedules, transaction)
{
    try 
    {
        // Recorre cada horario dentro del arreglo
        for (const schedule of schedules) 
        {
            // Busca si ya existe una restricción horaria para el mismo día de la semana en esa sesión
            let existingRestriction = await VoteSessionTimeRestriction.findOne({
                where: {
                    sessionid,
                    day_of_week: schedule.day_of_week
                },
                transaction
            });

            // Si ya existe una restricción para ese día, se actualiza con los nuevos valores
            if (existingRestriction) 
            {
                existingRestriction.start_time = schedule.start_time;
                existingRestriction.end_time = schedule.end_time;
                existingRestriction.allowed = schedule.allowed;

                await existingRestriction.save({ transaction });
            } 
            else // Si no existe, se crea una nueva restricción horaria para ese día
            {
                await VoteSessionTimeRestriction.create({
                    sessionid,
                    start_time: schedule.start_time,
                    end_time: schedule.end_time,
                    day_of_week: schedule.day_of_week,
                    allowed: schedule.allowed
                }, { transaction });
            }
        }
    } catch (error) {
        throw new Error("Error en configurar los horarios de votación: " + error.message);
    }
};
```

Función para configurar la lista directa de votantes
```javascript
async function uploadDirectList (sessionid, directList, transaction)
{
    try 
    {
        // Mapea cada userid de la lista directa a una llamada a la función de crear un registro de elegibilidad
        const promises = directList.map(async (userid) => {
            return createEligibility(userid, sessionid, transaction);
        });

        // Espera a que todas las elegibilidades sean creadas en paralelo
        await Promise.all(promises);
    } catch (error) {
        throw new Error("Error en configurar la lista directa de votantes: " + error.message);
    }
};
```
Función para configurar las zonas de impacto de la propuesta
```javascript
async function uploadImpactZones(proposalid, impactZoneData, transaction) 
{
    try 
    {
        // Recorre cada elemento del arreglo de zonas de impacto
        for (const item of impactZoneData) 
        {
            // Busca si ya existe una zona de impacto con el mismo nombre
            let impactZone = await VpvImpactZone.findOne({
                where: {
                    name: item.zone
                },
                transaction
            });

            // Si la zona no existe, la crea con su tipo
            if (!impactZone) 
            {
                impactZone = await VpvImpactZone.create({
                    name: item.zone,
                    zone_typeid: item.zone_typeid
                }, { transaction });
            }

            // Verifica si ya existe una relación entre la propuesta y la zona
            const existing = await VpvProposalImpactZone.findOne({
                where: {
                    proposalid,
                    zoneid: impactZone.zoneid
                },
                transaction
            });

            // Si ya existe la relación, actualiza el nivel de impacto y la descripción
            if (existing) 
            {
                await existing.update({
                    impact_levelid: item.impact_levelid,
                    description: item.description
                }, { transaction });
            } 
            else // Si no existe la relación, la crea desde cero
            {
                await VpvProposalImpactZone.create({
                    proposalid,
                    zoneid: impactZone.zoneid,
                    impact_levelid: item.impact_levelid,
                    description: item.description
                }, { transaction});
            }
        }
    } catch (error) {
        throw new Error("Error en configurar las zonas de impacto de las propuestas: " + error.message);
    }
}
```
# Dashboard de consultas
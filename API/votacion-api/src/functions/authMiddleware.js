const jwt = require('jsonwebtoken');
const SECRET_KEY = "clave_ultrasecreta_para_pruebas"; 
const { getUser, getSessionByToken, getPermissionsByUser, getUserKeyById } = require('../services/authService');


module.exports.handler = async (event) => {
  console.log("estoy ene el authorizer");
  try {
    const token = event.authorizationToken?.split(" ")[1];

    const decoded = jwt.verify(token, SECRET_KEY);

    const user = await getUser(decoded.id);
    console.log("voy a entrar a session");
    const session = await getSessionByToken(token);
    console.log("salí session");
    const permissions = await getPermissionsByUser(user.userid);

    const userkey = await getUserKeyById(session.key_id);

    const data = {
      "user": user,
      "permissions": permissions,
      "session": session,
      "userkey": userkey
    };

    console.log("todo OK");
    return {
        principalId: decoded.id,      
        policyDocument: {
            Version: "2012-10-17",
            Statement: [{
                Action: "execute-api:Invoke",
                Effect: "Allow",
                Resource: event.methodArn
           }]
        },
        isAuthorized: true,
        context: {
            "data": JSON.stringify(data)
        }
    };
  } catch (err) {
    console.log(err);
    console.log("todo mal");
    return {
        principalId: "decoded.id",      
        policyDocument: {
            Version: "2012-10-17",
            Statement: [{
                Action: "execute-api:Invoke",
                Effect: "Deny",
                Resource: event.methodArn
           }]
        },
        isAuthorized: false
    };
  }
};



/* 
SESIÓN POR TOKEN 

-- Insert into vpv_auth_sessions table
INSERT INTO [dbo].[vpv_auth_sessions] (
    [device_id],
    [start_date],
    [last_activity_date],
    [expiration_date],
    [session_token_hash],
    [key_id]
) VALUES (
    NULL,  -- device_id (assuming no device association)
    DATEADD(SECOND, 1749918151, '1970-01-01'),  -- start_date (converted from iat)
    DATEADD(SECOND, 1749918151, '1970-01-01'),  -- last_activity_date (same as start_date initially)
    DATEADD(SECOND, 1750638151, '1970-01-01'),  -- expiration_date (converted from exp)
    HASHBYTES('SHA2_256', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwibmFtZSI6IlZpY3RvcmlhIiwiaWF0IjoxNzQ5OTY2OTM5LCJleHAiOjE3NTA2ODY5Mzl9.EQ5nYbEG8fxLYo-9fHJzo6O02Sw7UGHhGq2HzwRdGGc'),  -- session_token_hash
    1  -- key_id (matching the inserted key)
);


*/
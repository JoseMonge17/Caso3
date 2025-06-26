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
    //console.log(data);
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

-- Insert into vpv_user_keys table
INSERT INTO [dbo].[vpv_user_keys] (
    [userid],
    [algorithm],
    [creation_date],
    [key_status],
    [key_usage],
    [public_key]
) VALUES (
    2,  -- userid
    'HS256',  -- algorithm
    DATEADD(SECOND, 1749918151, '1970-01-01'),  -- creation_date (converted from Unix timestamp)
    'active',  -- key_status
    'auth',  -- key_usage
    CONVERT(VARBINARY(255), 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApU9v1H2MZL9kuhw7FozR
FbMHzn7VZ3RxjIWZgWbyhrzN2KzUuH8jNUXzV7kjIZO4EkD1PbHD9QnvqK3jZ/bJ
kT6DJhWxz8V7k7KhH6L7H3aWhf3Jm0os5Ro6TuHU0HwjsuJKkjlw0CPq5LHL9IYX
6GQ0GnG5mbYgHdN3rB9BdN9/3rLMcKHyglv+iZEDt+v1C5mjM0G2MkgEKf0ZVeGG
2OGzqzMKOmfHrTshf0z5rPBjNcM5oK5J9/YyN/BH7hMlZtzw1iXJkC3R2lzV5yz3
apZbqIFZUrwThbBpefqL0pTO5t8PGVQ5vXpWWJZtH+3RZghlxD7rA5N/OJpU7swL
YwIDAQAB')  -- public_key
);

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
    HASHBYTES('SHA2_256', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwibmFtZSI6IlJ1YsOpbiIsImlhdCI6MTc1MDk3MjIzNSwiZXhwIjoxNzUxNjkyMjM1fQ.p19PdgNr3nyr4zA8fNgeDkxj5iOVqaRadblfvyzNqWs'),  -- session_token_hash
    1  -- key_id (matching the inserted key)
);


*/
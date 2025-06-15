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
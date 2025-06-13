const jwt = require('jsonwebtoken');
const SECRET_KEY = "clave_ultrasecreta_para_pruebas"; 
const { getUser } = require('../services/authService');


module.exports.handler = async (event) => {
  console.log("estoy ene el authorizer");
  try {
    const token = event.authorizationToken?.split(" ")[1];

    const decoded = jwt.verify(token, SECRET_KEY);

    const user = await getUser(decoded.id);

    //const session = await getSessionByToken(token);

    //const permissions = await getPermissionsByUser(user.id);

    //user.session = session;
    //user.permissions = permissions;

    const permissions = [{"id": 1, "name": "Permiso1"}, {"id": 2, "name": "Permiso2"}];

    const data = {
      "user": user,
      "permissions": permissions
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
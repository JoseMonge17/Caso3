const jwt = require('jsonwebtoken');
const SECRET_KEY = "clave_ultrasecreta_para_pruebas"; 


module.exports.handler = async (event) => {
    console.log("estoy ene el authorizer");
  try {
    const token = event.authorizationToken?.split(" ")[1];

    const decoded = jwt.verify(token, SECRET_KEY);

    // const user = await getUser(decoded.id);

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
            "user": JSON.stringify({
                "id": "234",
                "name": "Carlos",
                "isAuthorized": true,
                "permissions": ["uno", "dos", "tres"]
            })
        }
    };
  } catch (err) {
    console.log("todo mal");
    return {
        principalId: decoded.id,      
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
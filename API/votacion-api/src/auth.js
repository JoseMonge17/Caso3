const jwt = require('jsonwebtoken');
const SECRET_KEY = "clave_ultrasecreta_para_pruebas"; 

function getUserFromToken(event) {
  const authHeader = event.headers?.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new Error("No token provided");
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    return decoded;
  } catch (err) {
    throw new Error("Invalid token: " + err.message);
  }
}

module.exports = { getUserFromToken };


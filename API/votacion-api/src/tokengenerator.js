const jwt = require('jsonwebtoken');

// Información del usuario
const userData = {
  id: 1,
  name: "John Doe",
};

// Clave secreta para firmar el token (solo para pruebas locales)
const secretKey = "clave_ultrasecreta_para_pruebas";

// Crear el token con duración de 1 hora
const token = jwt.sign(userData, secretKey, { expiresIn: '3h' });

console.log("✅ Token generado:");
console.log(token);

const { getUserFromToken } = require('../auth');
const { sql, config } = require('../db/config');

module.exports.handler = async (event) => {
  try {
    console.log(event);
    const tokenPayload = getUserFromToken(event);
    console.log(tokenPayload);

    await sql.connect(config);
    const result = await sql.query('EXEC sp_get_api_providers');

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(result.recordset)
    };
  } catch (err) {
    console.error(`Error ejecutando SP: ${err.message}`);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: `Error ejecutando SP: ${err.message}` })
    };
  }
};


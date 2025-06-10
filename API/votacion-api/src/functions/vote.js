const { vote } = require('../services/voteService');

module.exports.handler = async (event) => 
{
    try {
    const body = JSON.parse(event.body);

    const result = await vote({ usuario: body });

    return {
        statusCode: 200,
        body: JSON.stringify(result)
    };

    } catch (error) {
        return {
            statusCode: 400,
            body: JSON.stringify({ error: error.message })
        };
    }
};
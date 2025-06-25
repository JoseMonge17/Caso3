const { listVotes } = require('../services/listVotesService');

module.exports.handler = async (event) => 
{
    try {
        const data = JSON.parse(event.requestContext.authorizer.data);

        const body = JSON.parse(event.body);

        const result = await listVotes(data, body);

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
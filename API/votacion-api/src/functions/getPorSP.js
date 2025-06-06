const { app } = require('@azure/functions');
const { sql, config } = require('../db/config');

app.http('getPorSP', {
    methods: ['GET'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        try {
        await sql.connect(config);
        const result = await sql.query(`EXEC sp_get_api_providers`); // Reemplaza por el nombre real

        return {
            status: 200,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(result.recordset)
        };

        } catch (err) {
        context.log(`Error ejecutando SP: ${err.message}`);
        return {
            status: 500,
            body: `Error ejecutando SP: ${err.message}`
        };
        }
    }
});


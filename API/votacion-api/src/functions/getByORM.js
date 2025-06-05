const { app } = require('@azure/functions');
const { sequelize, ApiProvider } = require('../db/sequelize');

app.http('getByORM', {
  methods: ['GET'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    try {
      await sequelize.authenticate();
      const providers = await ApiProvider.findAll();

      return {
        status: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(providers)
      };
    } catch (err) {
      context.log(`Error ORM: ${err.message}`);
      return {
        status: 500,
        body: `Error al usar ORM: ${err.message}`
      };
    }
  }
});


const { sequelize, ApiProvider } = require('../db/sequelize');

module.exports.handler = async () => {
  await sequelize.authenticate();
  const providers = await ApiProvider.findAll();
  return {
    statusCode: 200,
    body: JSON.stringify(providers)
  };
};
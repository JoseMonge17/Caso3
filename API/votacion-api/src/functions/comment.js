const { comment } = require('../services/commentService');

module.exports.handler = async (event) => 
{
    try 
    {
        // Aqui se llama la data del usuario que provee el middleware una vez realizado el proceso de autorización
        const data = JSON.parse(event.requestContext.authorizer.data);

        // Nos traemos la información enviada por la aplicación o en este caso el Postman
        const body = JSON.parse(event.body);

        // Llamada a la función del service correspondiente donde se va a manejar toda la lógica
        const result = await comment(data, body);

        // Retorno de la API para mostrar en la aplicación o en este caso el Postman
        return {
            statusCode: 200,
            body: JSON.stringify(result)
        };

    } catch (error) 
    {
        // Retorno en caso de error de la API para mostrar en la aplicación o en este caso el Postman
        return {
            statusCode: 400,
            body: JSON.stringify({ error: error.message })
        };
    }
};
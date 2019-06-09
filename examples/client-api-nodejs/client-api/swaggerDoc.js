const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  swaggerDefinition: {
    info: {
      title: 'client api',
      version: '1.0.0',
      description: 'Example Client API for Tenor and Marvel',
    },
    basePath: '/api/v1',
    consumes: [
      'application/json'
    ],
    produces: [
      'application/json'
    ],
  },
  // List of files to be processes. You can also set globs './routes/*.js'
  apis: ['./src/gateways/http/router.js'],
  swagger: "2.0",
};

const specs = swaggerJsdoc(options);

module.exports = (app) => {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));
}

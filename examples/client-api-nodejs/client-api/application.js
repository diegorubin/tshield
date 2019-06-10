const express = require('express');
const router = require('./src/gateways/http/router')(express.Router());
const swaggerDoc = require('./swaggerDoc');

const app = express();
const port = 8080;

app.use('/api/v1', router);
swaggerDoc(app);

app.listen(port, () => {
  console.info('application running ', { meta: port });
});

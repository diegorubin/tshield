const express = require('express');
var exphbs  = require('express-handlebars');
const router = require('./src/gateways/http/router')(express.Router());

const app = express();
app.engine('handlebars', exphbs());
app.set('view engine', 'handlebars');

const port = 8080;

app.use('/', router);

app.listen(port, () => {
  console.info('application running ', { meta: port });
});

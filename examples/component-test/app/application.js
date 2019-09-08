const express = require('express');
var exphbs  = require('express-handlebars');
const router = require('./src/gateways/http/router')(express.Router());
const swaggerDoc = require('./swaggerDoc');

const app = express();
app.engine('handlebars', exphbs());
app.set('view engine', 'handlebars');

const port = 8080;

app.use('/api/v1', router);
app.get('/', function (req, res) {
  res.render('home');
});
swaggerDoc(app);

app.listen(port, () => {
  console.info('application running ', { meta: port });
});

const bodyParser = require('body-parser');

const searchController = require('./searchController');

module.exports = (router) => {
  router.use(bodyParser.urlencoded({ extended: false }));
  router.use(bodyParser.json());

  router.get('/', (req, res) => {
    res.render('home');
  });

  router.post('/', (req, res) => {
    searchController.search(req, res);
  });

  return router;
};

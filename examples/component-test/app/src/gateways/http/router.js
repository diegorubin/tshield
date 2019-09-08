const bodyParser = require('body-parser');
const marvelController = require('./marvelController');

module.exports = (router) => {
  router.use(bodyParser.json());

  /**
   * @swagger
   * /marvel-gif:
   *  get:
   *    description: return a marvel character full name and first comic with a tenor gif
   *    produces:
   *      - application/json
   *    parameters:
   *      -
   *        name: "name"
   *        in: "query"
   *        description: "name to filter by"
   *        required: true
   *        type: "string"
   *    responses:
   *      '200':
   *        description: |-
   *          200 response
   *        examples:
   *          application/json: |-
   *            {
   *              "name": "Spider-Man",
   *              "firstComic": "Spider-Man: 101 Ways to End the Clone Saga (1997) #1",
   *              "gifUrl": "https://media.tenor.com/images/837072ca19e3c5cebea76e2693f3100d/tenor.gif",
   *            }
   *
   */
  router.get('/marvel-gif', (req, res) => {
    marvelController.marvelGif(req, res);
  });

  return router;
};

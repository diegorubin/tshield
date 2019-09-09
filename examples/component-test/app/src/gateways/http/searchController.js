const getCharacterGif = require('../../usecases/getCharacterGif');

const searchControler = {
  search(req, res) {
    const search = req.body && req.body['search'];
    getCharacterGif(search).then((response) => {
      res.render('home', {
        search,
        result: response,
      });
    }).catch((error) => {
      res.render('home', {
        search,
        error: error,
      });
    })
  }
};

module.exports = searchControler;

const getCharacterGif = require('../../usecases/getCharacterGif');

const marvelControler = {
  marvelGif(req, res) {
    getCharacterGif(req.query.name).then((response) => {
      res.send(response);
    }).catch((error) => {
      res.send(error);
    })
  }
};

module.exports = marvelControler;

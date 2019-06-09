const getGifByCharacter = require('../../usecases/getGifByCharacter');

const marvelControler = {
  marvelGif(req, res) {
    getGifByCharacter(req.query.name).then((response) => {
      res.send(response);
    }).catch((error) => {
      res.send(error);
    })
  }
};

module.exports = marvelControler;

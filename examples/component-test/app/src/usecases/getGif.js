const tenorClient = require('../gateways/client/tenorClient');
const config = require('../../config');

module.exports = (characterName) => new Promise((resolve, reject) => {
  tenorClient.getGif(characterName).then((response) => {
    const firstResult = response.data
      && response.data.results
      && response.data.results[0];

    const firstMedia = firstResult
      && firstResult.media
      && firstResult.media[0];

    const gifUrl = firstMedia
      && firstMedia.gif
      && firstMedia.gif.url
      || config.tenor.gifNotFound;

    resolve({
      gifUrl,
    })
  }).catch((error) => {
    console.error(error);
    reject({
      status: 'error',
      error,
    })
  });
});

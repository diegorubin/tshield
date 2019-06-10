const marvelClient = require('../gateways/client/marvelClient');

module.exports = (characterName) => new Promise((resolve, reject) => {
  marvelClient.getCharacter(characterName).then((response) => {
    const firstResult = response.data
      && response.data.data
      && response.data.data.results
      && response.data.data.results[0];

    const name = firstResult
      && firstResult.name
      || 'Character not found';
    const firstComic = firstResult
      && firstResult.comics
      && firstResult.comics.items
      && firstResult.comics.items[0]
      && firstResult.comics.items[0].name
      || 'First Comic not found';

    resolve({
      name: name,
      firstComic: firstComic,
    })
  }).catch((error) => {
    console.error(error);
    reject({
      status: 'error',
      error,
    })
  });
});

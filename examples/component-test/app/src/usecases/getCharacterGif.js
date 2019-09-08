const getCharacterInfo = require('./getCharacterInfo');
const getGif = require('./getGif');

module.exports = (characterName) => new Promise((resolve, reject) => {
  getCharacterInfo(characterName).then((characterInfo) => {
    getGif(characterInfo.name).then((response) => {
      resolve({
        ...characterInfo,
        ...response,
      })
    }).catch((error) => {
      reject(error);
    })
  }).catch((error) => {
    reject(error);
  })
});

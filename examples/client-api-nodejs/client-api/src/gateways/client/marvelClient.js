const axios = require('axios');
const md5 = require('md5');
const querystring = require('querystring');
const config = require('../../../config');

const privateKey = config.marvel.privateKey;
const publicKey = config.marvel.publicKey;

module.exports = {
  getCharacter: (name) => {
    const ts = config.marvel.useStaticTs ? 12345 : Date.now();
    const hash = md5(ts+privateKey+publicKey);

    const data = {
      nameStartsWith: name,
      limit: 1,
      offset: 0,
      apikey: publicKey,
      ts,
      hash,
    };

    return axios.request({
      method: 'GET',
      url: `${config.marvel.url}${config.marvel.characters}?${querystring.stringify(data)}`,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }
};

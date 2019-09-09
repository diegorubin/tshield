const axios = require('axios');
const querystring = require('querystring');
const config = require('../../../config');

module.exports = {
  getGif: (name) => {
    const data = {
      q: name,
      limit: 1,
      key: config.tenor.key,
      media_filter: 'minimal',
    };

    return axios.request({
      method: 'GET',
      url: `${config.tenor.url}${config.tenor.search}?${querystring.stringify(data)}`,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }
};

const MARVEL_API = process.env.MARVEL_API || 'https://gateway.marvel.com';
const MARVEL_API_CHARACTERS = process.env.MARVEL_API_CHARACTERS || '/v1/public/characters';
const MARVEL_API_PRIVATE_KEY = process.env.MARVEL_API_PRIVATE_KEY || 'mock-marvel-private-key';
const MARVEL_API_PUBLIC_KEY = process.env.MARVEL_API_PUBLIC_KEY || 'mock-marvel-public-key';
const MARVEL_API_USE_STATIC_TS = process.env.MARVEL_API_USE_STATIC_TS || 'false';

const TENOR_API = process.env.TENOR_API || 'https://api.tenor.com';
const TENOR_API_SEARCH = process.env.TENOR_API_SEARCH || '/v1/search';
const TENOR_API_KEY = process.env.TENOR_API_KEY || 'mock-tenor-key';

const applicationConfig = {
  marvel: {
    url: MARVEL_API,
    characters: MARVEL_API_CHARACTERS,
    privateKey: MARVEL_API_PRIVATE_KEY,
    publicKey: MARVEL_API_PUBLIC_KEY,
    useStaticTs: MARVEL_API_USE_STATIC_TS === 'true',
  },
  tenor: {
    url: TENOR_API,
    search: TENOR_API_SEARCH,
    key: TENOR_API_KEY,
    gifNotFound: 'https://media.tenor.com/images/969e4730c44fc809a358ae9eb12391b5/tenor.gif'
  }
};

module.exports = applicationConfig;

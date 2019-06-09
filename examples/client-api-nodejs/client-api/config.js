const MARVEL_API = process.env.MARVEL_API || 'https://gateway.marvel.com';
const MARVEL_API_CHARACTERS = process.env.MARVEL_API_CHARACTERS || '/v1/public/characters';
const MARVEL_API_PRIVATE_KEY = process.env.MARVEL_API_PRIVATE_KEY || 'ca2d7a653a41e39631509acfe733c0b4490ff6bd';
const MARVEL_API_PUBLIC_KEY = process.env.MARVEL_API_PUBLIC_KEY || '13fd445760a05bf47e824f6ea98c8044';

const applicationConfig = {
  marvel: {
    url: MARVEL_API,
    characters: MARVEL_API_CHARACTERS,
    privateKey: MARVEL_API_PRIVATE_KEY,
    publicKey: MARVEL_API_PUBLIC_KEY,
  }
};

module.exports = applicationConfig;

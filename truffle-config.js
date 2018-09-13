require('dotenv').config()

var Web3 = require('web3');

console.log(process.env.DEVELOPMENT_ACCOUNT);

module.exports = {
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  networks: {
   development: {
      host: process.env.DEVELOPMENT_HOST,
      port: process.env.DEVELOPMENT_PORT, 
      network_id: "*", 
      gasPrice: 2000000000,
      gas: 6721975,
      from: process.env.DEVELOPMENT_ACCOUNT,
    },
    alastria: {
      provider: () => {
        return new Web3.providers.HttpProvider(process.env.ALASTRIA_URL, 0, process.env.ALASTRIA_USER, process.env.ALASTRIA_PASSWORD);
      },
      network_id: "*", 
      gasPrice: 0,
      gas: 4500000,
      from: process.env.ALASTRIA_ACCOUNT,
    }
  }
};

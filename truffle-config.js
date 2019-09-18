require('dotenv').config();
var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  networks: {
    development: {
      provider: () => new HDWalletProvider(process.env.DEVELOPMENT_MNEMONIC, process.env.DEVELOPMENT_URL),
      network_id: "*", 
      gasPrice: 0,
      type: "quorum"
     },
  }
};

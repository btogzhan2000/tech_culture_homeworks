require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  etherscan: {
    apiKey: process.env.bscscan_api_key,
  },
  networks: {
    bnbtestnet: {
      url: 'https://data-seed-prebsc-2-s1.binance.org:8545',
      chainId: 97,
      accounts: {
        mnemonic: process.env.wallet_seed_phrase,
      }
    },
  }
};

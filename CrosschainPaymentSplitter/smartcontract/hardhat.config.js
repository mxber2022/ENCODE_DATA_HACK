require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });
require("./tasks/01-deploy-split");
require("./tasks/02-whitelist");
require("./tasks/03-split");
/** @type import('hardhat/config').HardhatUserConfig */

const PRIVATE_KEY = process.env.PRIVATE_KEY;

module.exports = {
  solidity: "0.8.19",

  networks: {

    'ethereumSepolia': {
      url: process.env.ETHEREUM_SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY],
    },

    'polygonMumbai': {
      url: process.env.POLYGON_MUMBAI_RPC_URL,
      accounts: [PRIVATE_KEY],
    },

    'optimismGoerli': {
      url: process.env.OPTIMISM_GOERLI_RPC_URL,
      accounts: [PRIVATE_KEY],
    },

    'arbitrumTestnet': {
      url: process.env.ARBITRUM_TESTNET_RPC_URL,
      accounts: [PRIVATE_KEY],
    },

    'avalancheFuji': {
      url: process.env.AVALANCHE_FUJI_RPC_URL,
      accounts: [PRIVATE_KEY],
    },

  },

  etherscan: {
    apiKey: {
      "ethereumSepolia": process.env.API_KEY,
    },

    customChains: [
      {
        network: "ethereumSepolia",
        chainId: 11155111,
        urls: {
          apiURL: "https://api-sepolia.etherscan.io/api",
          browserURL: '',
        },

      },
    ],

  },
}

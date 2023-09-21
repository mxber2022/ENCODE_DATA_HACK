require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });
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
      "mantle-testnet": "myapikey",
    },

    customChains: [
      {
        network: "mantle-testnet",
        chainId: 5001,
        urls: {
          apiURL: "https://explorer.testnet.mantle.xyz/api",
          browserURL: '',
        },

      },
    ],

  },
}

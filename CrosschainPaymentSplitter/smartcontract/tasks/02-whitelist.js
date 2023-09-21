require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });
const {abi} = require('./abi.js');
const ethers = require('ethers')
/*
    Whitelist Chain Address
*/
const OPTIMISM_GOERLI = "2664363617261496610";
const AVALANCHE_FUJI = "14767482510784806043";
const ARBITRUM_GOERLI = "6101244977088475029";
const POLYGON_MUMBAI = "12532609583862916517";
const BNB_TESTNET = "13264668187771770619";
const BASE_GOERLI = "5790810961207155433";

task("whitelist", "whitelist the chain for token transfer") 
    .setAction(async (taskArgs, hre) => {
    
        const provider = new ethers.JsonRpcProvider(process.env.ETHEREUM_SEPOLIA_RPC_URL);
        console.log("provider: ", provider);
        const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
        console.log(signer);
        let contract = new ethers.Contract("0x3b5ed7c3E6725c58926F532e3e97C32EE8576ef1", abi, signer);

        const whitelist_optimism = await contract.whitelistChain(OPTIMISM_GOERLI);
        console.log("whitelist_optimism: ", whitelist_optimism.hash);

        const whitelist_fuji = await contract.whitelistChain(AVALANCHE_FUJI);
        console.log("whitelist_fuji: ", whitelist_fuji.hash);

        const whitelist_arbitrum = await contract.whitelistChain(ARBITRUM_GOERLI);
        console.log("whitelist_arbitrum: ", whitelist_arbitrum.hash);

        const whitelist_polygon = await contract.whitelistChain(POLYGON_MUMBAI);
        console.log("whitelist_polygon: ", whitelist_polygon.hash);

        const whitelist_bnb = await contract.whitelistChain(BNB_TESTNET);
        console.log("whitelist_bnb: ", whitelist_bnb.hash);

        const whitelist_base = await contract.whitelistChain(BASE_GOERLI);
        console.log("whitelist_base: ", whitelist_base.hash);
        
        console.log("WHITELIST COMPLETED");

    });

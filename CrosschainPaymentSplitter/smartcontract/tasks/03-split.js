require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });
const {abi} = require('./abi.js');
const ethers = require('ethers')
/*
    address tok = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05; //CCIP BnM
    //[["0x2f459D8589FDc0e11522B3BC5501552bBa0A9e63","13264668187771770619","1"],["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","12532609583862916517","2"]]
*/
const transactionsData = [
    ["0xee93bB019728aB5f8d268851Ca3EA4dC35050558", "2664363617261496610", "2"],
    ["0xee93bB019728aB5f8d268851Ca3EA4dC35050558", "14767482510784806043", "2"],
    ["0xee93bB019728aB5f8d268851Ca3EA4dC35050558", "6101244977088475029", "2"],
    ["0xee93bB019728aB5f8d268851Ca3EA4dC35050558", "12532609583862916517", "2"],
    ["0xee93bB019728aB5f8d268851Ca3EA4dC35050558", "13264668187771770619", "2"],
    ["0xee93bB019728aB5f8d268851Ca3EA4dC35050558", "5790810961207155433", "2"]
];

const provider = new ethers.JsonRpcProvider(process.env.ETHEREUM_SEPOLIA_RPC_URL);
const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
let contract = new ethers.Contract("0x3b5ed7c3E6725c58926F532e3e97C32EE8576ef1", abi, signer);

task("addpaymentdata", "adds the payment data to contract") 
    .setAction(async (taskArgs, hre) => {

        const addTransaction = await contract.addTransactions(transactionsData);
        console.log("Transaction payment data added: ", addTransaction.hash);
        console.log("payment data is added, congrats");

    });

task("split", "split the payment among payment data added above") 
    .setAction(async (taskArgs, hre) => {
        
        const split = await contract.split();
        console.log("cross chain payment is completed, congrats. Transaction Hash :", split.hash);
    });
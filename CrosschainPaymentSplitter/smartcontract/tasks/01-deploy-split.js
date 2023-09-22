require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const router_address = "0xD0daae2231E9CB96b94C8512223533293C3693Bf";
const link_address = "0x779877A7B0D9E8603169DdbD7836e478b4624789";

task("deploy-split", "Deploys the split.sol contract") 
    .setAction(async (taskArgs, hre) => {
        /* 
            Ethereum Sepolia 
        */
    
        const contract = await hre.ethers.deployContract("Split",[router_address, link_address], { gasLimit: "4000000" });
        await contract.waitForDeployment();

        console.log(`contract deployed to network ${hre.ethers.provider._networkName} and contract address is ${contract.target}`);
    });

task("verify-split", "verifies the split.sol contract") 
    .addParam("contract", "The smart contract address")
    .setAction(async (taskArgs, hre) => {
        await hre.run("verify:verify", {
            address: taskArgs.contract,
            constructorArguments: [
                router_address,
                link_address,
            ],
          });
    });

    // contract : 0x3b5ed7c3E6725c58926F532e3e97C32EE8576ef1
    // cross chain payment distributer

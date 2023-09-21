const hre = require("hardhat");

async function main() {

  const contract = await hre.ethers.deployContract("Split", { gasLimit: "4000000" });
  console.log(contract.target);  
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


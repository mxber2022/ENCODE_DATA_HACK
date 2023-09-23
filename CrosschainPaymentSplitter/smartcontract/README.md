# Hardhat Project

The following project have 2 smartcontract.

Smartcontract: Split
This contract contains logic to distrubute funds crosschain using chainlink ccip.
This repository contains a Hardhat project with following tasks: `deploy-split`, `verify-split`, `whitelist`, and `split`. These tasks are designed to help you interact with and manage a smart contract that splits incoming Ether among whitelisted addresses.

Smartcontract: Monitor
This uses chainlink automation to automatically transfer ccip BnM token when token value falls below specified value in the Split contract.

## Getting Started

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/your-username/hardhat-split-contracts.git
   ```

2. Navigate to the project directory:

   ```bash
   cd hardhat-split-contracts
   ```

3. Install the required dependencies:

   ```bash
   npm install
   ```

4. Create a `.env` file in the project root and set your rpc URL:

   ```env
    PRIVATE_KEY=YOUR_PRIVATE_KEY
    ETHEREUM_SEPOLIA_RPC_URL=YOUR_SEPOLIA_RPC_URL
    POLYGON_MUMBAI_RPC_URL=YOUR_POLYGON_MUMBAI_RPC_URL
    OPTIMISM_GOERLI_RPC_URL=YOUR_OPTIMISM_GOERLI_RPC_URL
    ARBITRUM_TESTNET_RPC_URL=YOUR_ARBITRUM_TESTNET_RPC_URL
    AVALANCHE_FUJI_RPC_URL=YOUR_AVALANCHE_FUJI_RPC_URL
   ```

   Replace `YOUR_SEPOLIA_RPC_URL`, `YOUR_POLYGON_MUMBAI_RPC_URL`, `YOUR_POLYGON_MUMBAI_RPC_URL`, `YOUR_OPTIMISM_GOERLI_RPC_URL`, `YOUR_ARBITRUM_TESTNET_RPC_URL`, `YOUR_AVALANCHE_FUJI_RPC_URL`  and `YOUR_PRIVATE_KEY` with your actual values.

## Task 01: Deploy Split Contract

To deploy the split contract, run the following command:

```bash
npx hardhat deploy-split --network <network-name>
```
To verify the split contract, run the following command:

```bash
npx hardhat verify-split --network <network-name>
```

Replace `<network-name>` with the target Ethereum network (e.g., `rinkeby`, `sepolia`).

## Task 02: Whitelist Addresses

To whitelist addresses for receiving Ether, modify the values of the transactionsData in the task folder file named "03-split.js"

Then, run the following command to whitelist the addresses:

```bash
yarn hardhat whitelist
```

## Task 03: Split Ether

To split Ether among the whitelisted addresses, run the following command:

```bash
yarn hardhat split
```

## Task 04: Additional Tasks

Feel free to create additional tasks and scripts in the `scripts` directory to interact with the split contract as needed for your project.

## Troubleshooting

If you encounter any issues or have questions, please refer to the Hardhat documentation or open an issue in this repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
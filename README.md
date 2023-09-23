# Cross-Chain Payment Distributor using Chainlink CCIP and Chainlink Automation


## Introduction

Welcome to the Cross-Chain Payment Distributor powered by Chainlink CCIP (Cross-Chain Interoperability Protocol) and Chainlink Automation. This repository contains the codebase and documentation for a versatile and decentralized payment distribution system that operates seamlessly across multiple blockchain networks.

With the growing adoption of blockchain technology, there is an increasing need for cross-chain transactions and payments. Chainlink CCIP provides a robust framework for connecting various blockchains, and Chainlink Automation streamlines the execution of smart contract-based actions, making cross-chain payment distribution more efficient and reliable.

This project leverages Chainlink CCIP and Chainlink Automation to facilitate cross-chain payments, making it an essential tool for decentralized finance (DeFi) applications, decentralized exchanges (DEXs), and any other use case requiring cross-chain compatibility.

## Features

- **Cross-Chain Compatibility**: Seamlessly transfer payments across different blockchain networks.
- **Chainlink CCIP Integration**: Utilize the power of Chainlink's Cross-Chain Interoperability Protocol for secure and trustless transactions.
- **Chainlink Automation**: Implement payment to smartcontract using Chainlink Automation, reducing the need for manual intervention.
- **Customizable Configuration**: Tailor the system to your specific use case with a flexible configuration setup.
- **Secure and Decentralized**: Leverage the security and decentralization of blockchain technology for trustless operations.
- **Scalable**: Designed for scalability, enabling you to handle a growing volume of cross-chain transactions.

## Real world usecase Examples

- cross chain funds distribution
- Recurring payment(cross chain) using chainlink automation
- chainlink automation to fund gas fees and ccip BnM token to smart contract. This avoids manual work.

## Chainlink automation used
- When ever CCIP BnM token balance falls below 1 on the Split contract, chainlink automation will automatically fund the split contract with CCIP BnM token with 0.1 token. You can use whatever amount you need.


## Getting Started

Follow these steps to get started with the Cross-Chain Payment Distributor using Chainlink CCIP and Chainlink Automation.

### Prerequisites

Before you begin, ensure you have the following prerequisites:

- Solid understanding of blockchain technology.
- Access to a development environment or blockchain testnet for testing.
- Familiarity with Chainlink CCIP and Chainlink Automation concepts.

### Installation

1. Clone the repository:

   ```shell
   git clone https://github.com/mxber2022/ENCODE_DATA_HACK
   ```

2. Install dependencies:

   ```shell
   cd cross-chain-payment-distributor
   cd frontend
   yarn
   ```

3. Configure your environment variables.

4. Start the application:

   ```shell
   yarn start
   ```


## Deployment details

chain - sepolia
Split smartcontract - 0x3b5ed7c3E6725c58926F532e3e97C32EE8576ef1 <br>
Monitor smartcontract - 0x5f06D6D224Bfe000CbE8eB42812EE96Dac2bF7dC <br>

Token used for fund distribution - ccip BnM
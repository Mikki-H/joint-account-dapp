
# Joint Account DApp

## Introduction

This project is a decentralized application (DApp) built on the Ethereum blockchain. The DApp allows users to create joint accounts with other users, transfer amounts between users, and close accounts. The application ensures that users can only transact if there exists a path between them in the user network.

## Features

- **Register User**: Register a new user with a unique ID and name.
- **Create Joint Account**: Create a joint account between two users and track their individual contributions.
- **Send Amount**: Transfer an amount from one user to another, ensuring sufficient balance and path existence.
- **Close Account**: Terminate the joint account between two users.

## Prerequisites

- Node.js and npm
- Truffle
- Ganache (or any other Ethereum client)
- Python 3
- Web3.py
- Matplotlib
- NumPy

## Setup

### 1. Install Dependencies

```bash
npm install -g truffle
npm install ganache --global
pip install web3 matplotlib numpy
```

### 2. Clone the Repository

```bash
git clone <repository-url>
cd joint-account-dapp
```

### 3. Start Ganache

```bash
ganache
```

### 4. Compile and Deploy Smart Contracts

```bash
truffle compile
truffle migrate
```

### 5. Update `interact.py`

Update the `contract_address` in `interact.py` with the deployed contract address from the migration output.

## Usage

### 1. Register Users and Create Accounts

Run the `interact.py` script to register 100 users, create joint accounts, and perform transactions.

```bash
python interact.py
```

### 2. Plot Transaction Success Ratios

The script will plot the success ratios of transactions over time.

## Smart Contract Functions

### `registerUser(uint _id, string memory _name)`

Registers a new user with a unique ID and name.

### `createAcc(uint _id1, uint _id2)`

Creates a joint account between two users and tracks their individual contributions.

### `sendAmount(uint _id1, uint _id2, uint _amount)`

Transfers an amount from one user to another, ensuring sufficient balance and path existence.

### `closeAccount(uint _id1, uint _id2)`

Terminates the joint account between two users.

## Python Script

### `interact.py`

- Registers 100 users.
- Creates joint accounts between users.
- Performs 1000 transactions and plots the success ratios.

## Directory Structure

```
joint-account-dapp/
├── build/
│   └── contracts/
│       └── JointAccountDApp.json
├── contracts/
│   └── JointAccountDApp.sol
├── migrations/
│   └── 2_deploy_contracts.js
├── scripts/
│   └── interact.py
├── test/
│   └── JointAccountDApp.test.js
├── truffle-config.js
└── README.md
```


## Useful Links

- [EthFiddle](https://ethfiddle.com/) - Online Solidity compiler
- [Set up Ethereum node](https://www.geeksforgeeks.org/how-to-setup-your-own-private-ethereum-network/)
- [Call smart contract function](https://stackoverflow.com/questions/57580702)

## Authors

-

## License

This project is licensed under the MIT License.


# BlockScore Smart Contracts Documentation

## Overview

BlockScore uses Solidity smart contracts for immutable credit record storage and automated loan management on Ethereum/Polygon blockchains.

## Contracts

### 1. CreditScore.sol

Main contract for managing credit records and scores.

**Location**: `code/blockchain/contracts/CreditScore.sol`

**Key Functions**:

| Function            | Parameters                                                          | Description               | Access               |
| ------------------- | ------------------------------------------------------------------- | ------------------------- | -------------------- |
| `addCreditRecord`   | `address user, uint256 amount, string recordType, int8 scoreImpact` | Add new credit record     | Authorized providers |
| `markRecordRepaid`  | `address user, uint256 recordIndex`                                 | Mark record as repaid     | Authorized providers |
| `getCreditProfile`  | `address user`                                                      | Get user credit profile   | Public               |
| `getCreditHistory`  | `address user`                                                      | Get all credit records    | Public               |
| `authorizeProvider` | `address provider`                                                  | Authorize credit provider | Owner only           |

**Example Usage**:

```javascript
// Deploy contract
const CreditScore = artifacts.require('CreditScore');
const instance = await CreditScore.deployed();

// Add credit record
await instance.addCreditRecord(
    '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
    1000, // amount
    'loan', // record type
    5, // score impact
);

// Get credit profile
const profile = await instance.getCreditProfile('0x742d35Cc6634C0532925a3b844Bc454e4438f44e');
console.log(profile.score.toString());
```

### 2. LoanContract.sol

Smart contract for automated loan management.

**Location**: `code/blockchain/contracts/LoanContract.sol`

**Key Functions**:

| Function         | Parameters                                                                 | Description          |
| ---------------- | -------------------------------------------------------------------------- | -------------------- |
| `createLoan`     | `address borrower, uint256 amount, uint256 interestRate, uint256 duration` | Create new loan      |
| `repayLoan`      | `uint256 loanId`                                                           | Make loan repayment  |
| `getLoanDetails` | `uint256 loanId`                                                           | Get loan information |

### 3. GovernanceToken.sol

ERC20 token for platform governance.

**Location**: `code/blockchain/contracts/GovernanceToken.sol`

**Features**:

- ERC20 compliant
- Used for voting on platform changes
- Reward distribution

## Deployment

### Local Development (Ganache)

```bash
cd code/blockchain
ganache-cli -p 8545
truffle migrate --network development
```

### Polygon Mumbai Testnet

```bash
cd code/blockchain
truffle migrate --network mumbai
```

### Configuration

Edit `code/blockchain/truffle-config.js`:

```javascript
networks: {
  mumbai: {
    provider: () => new HDWalletProvider(MNEMONIC, MUMBAI_RPC_URL),
    network_id: 80001,
    gas: 6721975,
    gasPrice: 20000000000
  }
}
```

## Contract Addresses

| Network | CreditScore Contract | LoanContract   |
| ------- | -------------------- | -------------- |
| Ganache | Auto-deployed        | Auto-deployed  |
| Mumbai  | Update in .env       | Update in .env |
| Polygon | Update in .env       | Update in .env |

See [Configuration Guide](CONFIGURATION.md) for setting contract addresses.

# BlockScore Documentation

## Overview

BlockScore is a decentralized credit scoring system built on blockchain technology. It combines smart contracts for on-chain credit record management with machine learning models for credit score prediction.

This documentation covers the usage of the system's components:

1. Solidity Smart Contracts
2. Node.js API
3. Python Scoring Model

## System Architecture

The BlockScore system consists of three main components:

1. **Blockchain Layer**: Ethereum smart contracts that store credit records and manage loan operations
2. **API Layer**: Node.js API that interfaces with the blockchain and provides endpoints for client applications
3. **AI Layer**: Python-based credit scoring models that analyze blockchain data to predict credit scores

## Smart Contracts

### CreditScore.sol

The CreditScore contract manages credit records and scoring for users on the blockchain.

#### Key Features:

- Store credit records with detailed information
- Track repayment status
- Calculate and update credit scores
- Role-based access control for credit providers

#### Contract Functions:

**Authorization Management:**

```solidity
// Authorize a new credit provider
function authorizeProvider(address provider) external onlyOwner

// Revoke authorization from a credit provider
function revokeProvider(address provider) external onlyOwner

// Check if an address is an authorized provider
function isAuthorizedProvider(address provider) external view returns (bool)
```

**Credit Record Management:**

```solidity
// Add a credit record for a user
function addCreditRecord(
    address user,
    uint256 amount,
    string calldata recordType,
    int8 scoreImpact
) external onlyAuthorizedProvider

// Mark a credit record as repaid
function markRepaid(address user, uint256 recordIndex) external onlyAuthorizedProvider

// Get a user's credit score
function getCreditScore(address user) external view returns (uint256 score, uint256 lastUpdated)

// Get a user's credit history
function getCreditHistory(address user) external view returns (CreditRecord[] memory)
```

### LoanContract.sol

The LoanContract manages loan creation, approval, and repayment with credit score integration.

#### Key Features:

- Create loan requests
- Approve loans
- Track repayment status
- Integrate with CreditScore contract

#### Contract Functions:

**Loan Management:**

```solidity
// Create a new loan request
function createLoan(uint256 amount, uint256 interestRate, uint256 durationDays) external returns (uint256 loanId)

// Approve a loan request
function approveLoan(uint256 loanId) external onlyOwner

// Mark a loan as repaid
function repayLoan(uint256 loanId) external

// Get all loans for a borrower
function getBorrowerLoans(address borrower) external view returns (uint256[] memory)

// Get loan details by ID
function getLoanDetails(uint256 loanId) external view returns (Loan memory)

// Get the credit score of a borrower
function getBorrowerCreditScore(address borrower) external view returns (uint256 score, uint256 lastUpdated)
```

## Node.js API

The Node.js API provides RESTful endpoints for interacting with the blockchain contracts and the Python scoring model.

### Setup and Configuration

1. Install dependencies:

```bash
cd code/backend
npm install
```

2. Configure environment variables in `.env` file:

```
BLOCKCHAIN_PROVIDER=http://localhost:8545
CREDIT_SCORE_ADDRESS=0x...
LOAN_CONTRACT_ADDRESS=0x...
JWT_SECRET=your-secret-key
PORT=3000
PYTHON_API_URL=http://localhost:5000
```

3. Start the API server:

```bash
node app.js
```

### API Endpoints

#### Authentication

**Register a new user:**

```
POST /api/auth/register
Content-Type: application/json

{
  "username": "user123",
  "password": "password123"
}
```

**Login:**

```
POST /api/auth/login
Content-Type: application/json

{
  "username": "user123",
  "password": "password123"
}
```

Response:

```json
{
    "success": true,
    "message": "Authentication successful",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
        "username": "user123",
        "role": "user",
        "walletAddress": null
    }
}
```

**Update wallet address:**

```
POST /api/auth/wallet
Authorization: Bearer <token>
Content-Type: application/json

{
  "walletAddress": "0x123456789abcdef..."
}
```

#### Credit Operations

**Get credit score:**

```
GET /api/credit/score/0x123456789abcdef...
```

Response:

```json
{
    "success": true,
    "data": {
        "score": 750,
        "lastUpdated": 1621500000
    }
}
```

**Get credit history:**

```
GET /api/credit/history/0x123456789abcdef...
```

Response:

```json
{
    "success": true,
    "data": [
        {
            "timestamp": 1621500000,
            "amount": 5000,
            "repaid": true,
            "repaymentTimestamp": 1623500000,
            "provider": "0x123...",
            "recordType": "loan",
            "scoreImpact": 5
        }
    ]
}
```

**Add credit record (requires provider authorization):**

```
POST /api/credit/record
Authorization: Bearer <token>
Content-Type: application/json

{
  "userAddress": "0x123456789abcdef...",
  "amount": 10000,
  "recordType": "loan",
  "scoreImpact": 5,
  "privateKey": "abcdef123456..."
}
```

**Mark record as repaid (requires provider authorization):**

```
POST /api/credit/record/repaid
Authorization: Bearer <token>
Content-Type: application/json

{
  "userAddress": "0x123456789abcdef...",
  "recordIndex": 0,
  "privateKey": "abcdef123456..."
}
```

**Calculate credit score using AI model:**

```
POST /api/credit/calculate-score
Content-Type: application/json

{
  "walletAddress": "0x123456789abcdef..."
}
```

Response:

```json
{
    "success": true,
    "data": {
        "address": "0x123456789abcdef...",
        "calculatedScore": 720,
        "blockchainScore": 750,
        "factors": [
            {
                "factor": "Good payment history",
                "impact": "positive",
                "description": "Generally repaying debts on time"
            }
        ]
    }
}
```

#### Loan Operations

**Get loan details:**

```
GET /api/loans/1
```

Response:

```json
{
    "success": true,
    "data": {
        "borrower": "0x123456789abcdef...",
        "amount": 10000,
        "interestRate": 500,
        "creationTimestamp": 1621500000,
        "dueDate": 1623500000,
        "approved": true,
        "repaid": false,
        "repaymentTimestamp": 0
    }
}
```

**Get borrower loans:**

```
GET /api/loans/borrower/0x123456789abcdef...
```

**Create loan:**

```
POST /api/loans/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 20000,
  "interestRate": 500,
  "durationDays": 30,
  "privateKey": "abcdef123456..."
}
```

**Approve loan (requires admin):**

```
POST /api/loans/approve/1
Authorization: Bearer <token>
Content-Type: application/json

{
  "privateKey": "abcdef123456..."
}
```

**Repay loan:**

```
POST /api/loans/repay/1
Authorization: Bearer <token>
Content-Type: application/json

{
  "privateKey": "abcdef123456..."
}
```

## Python Scoring Model

The Python scoring model analyzes blockchain credit history to predict credit scores.

### Setup and Configuration

1. Install dependencies:

```bash
cd code/ai_models
pip install -r training_scripts/requirements.txt
```

2. Start the model API server:

```bash
python server.py
```

### API Endpoints

**Health check:**

```
GET /health
```

**Predict credit score:**

```
POST /predict
Content-Type: application/json

{
  "creditHistory": [
    {
      "timestamp": 1621500000,
      "amount": 5000,
      "repaid": true,
      "repaymentTimestamp": 1623500000,
      "provider": "0x123...",
      "recordType": "loan",
      "scoreImpact": 5
    }
  ]
}
```

Response:

```json
{
    "score": 720,
    "confidence": 0.85,
    "factors": [
        {
            "factor": "Good payment history",
            "impact": "positive",
            "description": "Generally repaying debts on time"
        }
    ]
}
```

**Batch predict credit scores:**

```
POST /batch-predict
Content-Type: application/json

{
  "batch": [
    {
      "userId": "user1",
      "creditHistory": [...]
    },
    {
      "userId": "user2",
      "creditHistory": [...]
    }
  ]
}
```

## Integration Example

Here's an example of how to integrate the different components:

1. Deploy the smart contracts to an Ethereum network
2. Configure the Node.js API with the contract addresses
3. Start the Python model API server
4. Use the Node.js API to interact with both the blockchain and the scoring model

### Sample Integration Flow

1. User registers and logs in through the API
2. User updates their wallet address
3. User creates a loan request
4. Admin approves the loan, which adds a credit record
5. User repays the loan, which updates the credit record
6. User or third party can query the credit score, which uses both blockchain data and the AI model

## Running Tests

### Smart Contract Tests

```bash
cd code/blockchain
npx hardhat test
```

### Node.js API Tests

```bash
cd code/backend
npm test
```

### Python Model Tests

```bash
cd code/ai_models
python -m unittest discover tests
```

## Deployment

### Smart Contracts

```bash
cd code/blockchain
npx hardhat run scripts/deploy.js --network <network-name>
```

### Node.js API

```bash
cd code/backend
npm start
```

### Python Model API

```bash
cd code/ai_models
python server.py
```

## Security Considerations

1. **Private Keys**: Never share private keys in production. The API accepts private keys for demonstration purposes only.
2. **Authentication**: Use strong JWT secrets and consider shorter token expiration times in production.
3. **Provider Authorization**: Only authorize trusted entities as credit providers.
4. **Data Privacy**: Consider implementing additional privacy measures for sensitive financial data.

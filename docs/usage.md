# BlockScore Usage Guide

Common usage patterns and workflows for BlockScore platform.

## User Workflows

### 1. Register and Login

```bash
# Register new account
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"SecurePass123!"}'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"SecurePass123!"}'
```

### 2. Calculate Credit Score

```bash
# Store your access token
TOKEN="your-access-token-here"

# Calculate credit score
curl -X POST http://localhost:5000/api/credit/calculate-score \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"walletAddress":"0x742d35Cc6634C0532925a3b844Bc454e4438f44e"}'
```

### 3. Apply for Loan

```bash
curl -X POST http://localhost:5000/api/loans/apply \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "loan_type":"personal",
    "requested_amount":10000,
    "requested_term_months":36
  }'
```

## Web Dashboard Usage

1. Navigate to `http://localhost:3000`
2. Register account or login
3. Connect MetaMask wallet
4. View credit dashboard
5. Apply for loans
6. Track application status

## Smart Contract Integration

```javascript
// Web3.js example
const Web3 = require("web3");
const web3 = new Web3("http://localhost:8545");

// Load contract
const contractABI = require("./CreditScore.json");
const contract = new web3.eth.Contract(contractABI, contractAddress);

// Add credit record
await contract.methods
  .addCreditRecord(userAddress, amount, "loan", scoreImpact)
  .send({ from: providerAddress });
```

See [API Reference](API.md) for complete endpoint documentation.

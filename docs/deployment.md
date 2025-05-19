# BlockScore Deployment Guide

This guide provides instructions for deploying the BlockScore system components.

## Prerequisites

- Node.js v14+ and npm
- Python 3.8+
- Ethereum development environment (Hardhat, Ganache, or access to a testnet/mainnet)
- Git

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/BlockScore.git
cd BlockScore
```

### 2. Deploy Smart Contracts

```bash
cd code/blockchain

# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Deploy contracts to local network
npx hardhat run scripts/deploy.js --network localhost

# Or deploy to a testnet
npx hardhat run scripts/deploy.js --network goerli
```

Take note of the deployed contract addresses for CreditScore and LoanContract.

### 3. Set Up Node.js API

```bash
cd ../backend

# Install dependencies
npm install

# Create .env file
cat > .env << EOL
BLOCKCHAIN_PROVIDER=http://localhost:8545
CREDIT_SCORE_ADDRESS=0x... # Your deployed CreditScore contract address
LOAN_CONTRACT_ADDRESS=0x... # Your deployed LoanContract contract address
JWT_SECRET=your-secret-key
PORT=3000
PYTHON_API_URL=http://localhost:5000
EOL

# Start the API server
node app.js
```

### 4. Set Up Python Model API

```bash
cd ../ai_models

# Create and activate virtual environment (optional)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r training_scripts/requirements.txt

# Start the model API server
python server.py
```

### 5. Verify Deployment

1. Check that the Node.js API is running:
```bash
curl http://localhost:3000/health
```

2. Check that the Python Model API is running:
```bash
curl http://localhost:5000/health
```

3. Try a sample request:
```bash
# Register a user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

## Production Deployment

For production deployment, consider the following:

1. Use a process manager like PM2 for the Node.js API:
```bash
npm install -g pm2
pm2 start app.js --name blockscore-api
```

2. Use Gunicorn for the Python API:
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 server:app
```

3. Set up HTTPS using a reverse proxy like Nginx

4. Use environment variables for all sensitive configuration

5. Consider containerization with Docker for easier deployment

## Troubleshooting

1. **Contract deployment fails**: Ensure you have enough ETH in your account for gas fees

2. **API connection issues**: Check that the contract addresses in .env are correct

3. **Python model errors**: Verify that the model file exists and is accessible

4. **Authentication errors**: Ensure JWT_SECRET is properly set and consistent

For more detailed troubleshooting, check the logs of each component.

const express = require('express');
const { Web3 } = require('web3');
const CreditModel = require('../ai_models/credit_scoring_model.pkl');

const app = express();
app.use(express.json());

// Connect to Ethereum
const web3 = new Web3('http://localhost:8545');
const creditContract = require('../blockchain/build/contracts/CreditScore.json');

app.post('/calculate-score', async (req, res) => {
  const { walletAddress } = req.body;
  
  // Get blockchain data
  const txHistory = await creditContract.methods
    .getCreditHistory(walletAddress)
    .call();
  
  // AI prediction
  const score = CreditModel.predict(txHistory);
  
  res.json({ address: walletAddress, score });
});

app.listen(3000, () => {
  console.log('API running on port 3000');
});
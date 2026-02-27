/**
 * Configuration file for BlockScore API
 */
require("dotenv").config();

module.exports = {
  // Blockchain configuration
  blockchain: {
    provider: process.env.BLOCKCHAIN_PROVIDER || "http://localhost:8545",
    networkId: process.env.NETWORK_ID || "5777",
    gasLimit: process.env.GAS_LIMIT || 6721975,
  },

  // API configuration
  api: {
    port: process.env.PORT || 3000,
    jwtSecret: process.env.JWT_SECRET || "blockscore-secret-key",
    jwtExpiration: process.env.JWT_EXPIRATION || "24h",
  },

  // Model integration configuration
  modelIntegration: {
    pythonApiUrl: process.env.PYTHON_API_URL || "http://localhost:5000",
    modelEndpoint: process.env.MODEL_ENDPOINT || "/predict",
  },

  // Contract addresses (to be populated during deployment)
  contracts: {
    creditScoreAddress: process.env.CREDIT_SCORE_ADDRESS || "",
    loanContractAddress: process.env.LOAN_CONTRACT_ADDRESS || "",
  },
};

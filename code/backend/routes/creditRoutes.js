/**
 * API routes for credit score operations
 */
const express = require('express');
const router = express.Router();
const contractService = require('../services/contractService');
const { verifyToken, isCreditProvider } = require('../middleware/auth');
const axios = require('axios');
const config = require('../config');

/**
 * @route GET /api/credit/score/:address
 * @desc Get credit score for a blockchain address
 * @access Public
 */
router.get('/score/:address', async (req, res) => {
  try {
    const { address } = req.params;
    const result = await contractService.getCreditScore(address);
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error getting credit score:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get credit score'
    });
  }
});

/**
 * @route GET /api/credit/history/:address
 * @desc Get credit history for a blockchain address
 * @access Public
 */
router.get('/history/:address', async (req, res) => {
  try {
    const { address } = req.params;
    const history = await contractService.getCreditHistory(address);
    
    res.json({
      success: true,
      data: history
    });
  } catch (error) {
    console.error('Error getting credit history:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get credit history'
    });
  }
});

/**
 * @route POST /api/credit/record
 * @desc Add a new credit record
 * @access Private (Credit Provider)
 */
router.post('/record', verifyToken, isCreditProvider, async (req, res) => {
  try {
    const { userAddress, amount, recordType, scoreImpact, privateKey } = req.body;
    
    if (!userAddress || !amount || !recordType || scoreImpact === undefined || !privateKey) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }
    
    const receipt = await contractService.addCreditRecord(
      userAddress,
      amount,
      recordType,
      scoreImpact,
      privateKey
    );
    
    res.json({
      success: true,
      data: {
        transactionHash: receipt.transactionHash
      }
    });
  } catch (error) {
    console.error('Error adding credit record:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to add credit record'
    });
  }
});

/**
 * @route POST /api/credit/record/repaid
 * @desc Mark a credit record as repaid
 * @access Private (Credit Provider)
 */
router.post('/record/repaid', verifyToken, isCreditProvider, async (req, res) => {
  try {
    const { userAddress, recordIndex, privateKey } = req.body;
    
    if (!userAddress || recordIndex === undefined || !privateKey) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }
    
    const receipt = await contractService.markRecordRepaid(
      userAddress,
      recordIndex,
      privateKey
    );
    
    res.json({
      success: true,
      data: {
        transactionHash: receipt.transactionHash
      }
    });
  } catch (error) {
    console.error('Error marking record as repaid:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to mark record as repaid'
    });
  }
});

/**
 * @route POST /api/credit/calculate-score
 * @desc Calculate credit score using AI model
 * @access Public
 */
router.post('/calculate-score', async (req, res) => {
  try {
    const { walletAddress } = req.body;
    
    if (!walletAddress) {
      return res.status(400).json({
        success: false,
        message: 'Wallet address is required'
      });
    }
    
    // Get blockchain data
    const creditHistory = await contractService.getCreditHistory(walletAddress);
    
    // Call Python API for prediction
    const modelResponse = await axios.post(
      `${config.modelIntegration.pythonApiUrl}${config.modelIntegration.modelEndpoint}`,
      { creditHistory }
    );
    
    res.json({
      success: true,
      data: {
        address: walletAddress,
        calculatedScore: modelResponse.data.score,
        blockchainScore: (await contractService.getCreditScore(walletAddress)).score,
        factors: modelResponse.data.factors || []
      }
    });
  } catch (error) {
    console.error('Error calculating score:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to calculate score'
    });
  }
});

module.exports = router;

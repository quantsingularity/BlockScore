/**
 * API routes for loan operations
 */
const express = require('express');
const router = express.Router();
const contractService = require('../services/contractService');
const { verifyToken, isAdmin } = require('../middleware/auth');

/**
 * @route GET /api/loans/:loanId
 * @desc Get loan details by ID
 * @access Public
 */
router.get('/:loanId', async (req, res) => {
  try {
    const { loanId } = req.params;
    const loan = await contractService.getLoanDetails(parseInt(loanId));
    
    res.json({
      success: true,
      data: loan
    });
  } catch (error) {
    console.error('Error getting loan details:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get loan details'
    });
  }
});

/**
 * @route GET /api/loans/borrower/:address
 * @desc Get all loans for a borrower
 * @access Public
 */
router.get('/borrower/:address', async (req, res) => {
  try {
    const { address } = req.params;
    const loanIds = await contractService.getBorrowerLoans(address);
    
    // Get details for each loan
    const loanPromises = loanIds.map(id => contractService.getLoanDetails(id));
    const loans = await Promise.all(loanPromises);
    
    res.json({
      success: true,
      data: {
        loanIds,
        loans
      }
    });
  } catch (error) {
    console.error('Error getting borrower loans:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get borrower loans'
    });
  }
});

/**
 * @route POST /api/loans/create
 * @desc Create a new loan
 * @access Private
 */
router.post('/create', verifyToken, async (req, res) => {
  try {
    const { amount, interestRate, durationDays, privateKey } = req.body;
    
    if (!amount || !interestRate || !durationDays || !privateKey) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }
    
    const result = await contractService.createLoan(
      amount,
      interestRate,
      durationDays,
      privateKey
    );
    
    res.json({
      success: true,
      data: {
        loanId: result.loanId,
        transactionHash: result.receipt.transactionHash
      }
    });
  } catch (error) {
    console.error('Error creating loan:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create loan'
    });
  }
});

/**
 * @route POST /api/loans/approve/:loanId
 * @desc Approve a loan
 * @access Private (Admin)
 */
router.post('/approve/:loanId', verifyToken, isAdmin, async (req, res) => {
  try {
    const { loanId } = req.params;
    const { privateKey } = req.body;
    
    if (!privateKey) {
      return res.status(400).json({
        success: false,
        message: 'Private key is required'
      });
    }
    
    const receipt = await contractService.approveLoan(
      parseInt(loanId),
      privateKey
    );
    
    res.json({
      success: true,
      data: {
        transactionHash: receipt.transactionHash
      }
    });
  } catch (error) {
    console.error('Error approving loan:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to approve loan'
    });
  }
});

/**
 * @route POST /api/loans/repay/:loanId
 * @desc Repay a loan
 * @access Private
 */
router.post('/repay/:loanId', verifyToken, async (req, res) => {
  try {
    const { loanId } = req.params;
    const { privateKey } = req.body;
    
    if (!privateKey) {
      return res.status(400).json({
        success: false,
        message: 'Private key is required'
      });
    }
    
    const receipt = await contractService.repayLoan(
      parseInt(loanId),
      privateKey
    );
    
    res.json({
      success: true,
      data: {
        transactionHash: receipt.transactionHash
      }
    });
  } catch (error) {
    console.error('Error repaying loan:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to repay loan'
    });
  }
});

module.exports = router;

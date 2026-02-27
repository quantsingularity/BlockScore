/**
 * Authentication routes for BlockScore API
 */
const express = require("express");
const router = express.Router();
const authService = require("../services/authService");
const { verifyToken, isAdmin } = require("../middleware/auth");

/**
 * @route POST /api/auth/register
 * @desc Register a new user
 * @access Public
 */
router.post("/register", async (req, res) => {
  try {
    const { username, password, role } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: "Username and password are required",
      });
    }

    // Only admins can create provider accounts
    if (role === "admin" || role === "provider") {
      return res.status(403).json({
        success: false,
        message: "Cannot create admin or provider accounts directly",
      });
    }

    const user = authService.registerUser(username, password, "user");

    res.status(201).json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error("Error registering user:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to register user",
    });
  }
});

/**
 * @route POST /api/auth/login
 * @desc Authenticate user and get token
 * @access Public
 */
router.post("/login", async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: "Username and password are required",
      });
    }

    const authResult = authService.authenticateUser(username, password);

    res.json(authResult);
  } catch (error) {
    console.error("Error authenticating user:", error);
    res.status(401).json({
      success: false,
      message: error.message || "Authentication failed",
    });
  }
});

/**
 * @route POST /api/auth/wallet
 * @desc Update user's wallet address
 * @access Private
 */
router.post("/wallet", verifyToken, async (req, res) => {
  try {
    const { walletAddress } = req.body;
    const { username } = req.user;

    if (!walletAddress) {
      return res.status(400).json({
        success: false,
        message: "Wallet address is required",
      });
    }

    const updatedUser = authService.updateWalletAddress(
      username,
      walletAddress,
    );

    res.json({
      success: true,
      data: updatedUser,
    });
  } catch (error) {
    console.error("Error updating wallet address:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to update wallet address",
    });
  }
});

/**
 * @route POST /api/auth/provider
 * @desc Register a new credit provider
 * @access Private (Admin)
 */
router.post("/provider", verifyToken, isAdmin, async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: "Username and password are required",
      });
    }

    const user = authService.registerUser(username, password, "provider");

    res.status(201).json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error("Error registering provider:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to register provider",
    });
  }
});

module.exports = router;

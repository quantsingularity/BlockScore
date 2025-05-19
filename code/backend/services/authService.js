/**
 * User authentication service for BlockScore API
 */
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const config = require('../config');

// In-memory user store (would be replaced with database in production)
const users = {};

class AuthService {
  /**
   * Register a new user
   * @param {string} username - Username
   * @param {string} password - Password
   * @param {string} role - User role (user, provider, admin)
   * @returns {Object} - User object (without password)
   */
  registerUser(username, password, role = 'user') {
    if (users[username]) {
      throw new Error('Username already exists');
    }

    const salt = crypto.randomBytes(16).toString('hex');
    const hash = crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');

    const user = {
      username,
      salt,
      hash,
      role,
      createdAt: new Date(),
      walletAddress: null
    };

    users[username] = user;

    return {
      username: user.username,
      role: user.role,
      createdAt: user.createdAt,
      walletAddress: user.walletAddress
    };
  }

  /**
   * Authenticate a user
   * @param {string} username - Username
   * @param {string} password - Password
   * @returns {Object} - Authentication result with token
   */
  authenticateUser(username, password) {
    const user = users[username];
    if (!user) {
      throw new Error('User not found');
    }

    const hash = crypto.pbkdf2Sync(password, user.salt, 1000, 64, 'sha512').toString('hex');
    if (hash !== user.hash) {
      throw new Error('Invalid password');
    }

    const token = jwt.sign(
      { 
        username: user.username, 
        role: user.role,
        walletAddress: user.walletAddress
      },
      config.api.jwtSecret,
      { expiresIn: config.api.jwtExpiration }
    );

    return {
      success: true,
      message: 'Authentication successful',
      token,
      user: {
        username: user.username,
        role: user.role,
        walletAddress: user.walletAddress
      }
    };
  }

  /**
   * Update user's wallet address
   * @param {string} username - Username
   * @param {string} walletAddress - Ethereum wallet address
   * @returns {Object} - Updated user object
   */
  updateWalletAddress(username, walletAddress) {
    const user = users[username];
    if (!user) {
      throw new Error('User not found');
    }

    user.walletAddress = walletAddress;

    return {
      username: user.username,
      role: user.role,
      walletAddress: user.walletAddress
    };
  }

  /**
   * Initialize with default admin user
   */
  init() {
    // Create default admin if not exists
    if (!users['admin']) {
      this.registerUser('admin', 'admin123', 'admin');
      console.log('Default admin user created');
    }
  }
}

module.exports = new AuthService();

/**
 * Authentication middleware for BlockScore API
 */
const jwt = require('jsonwebtoken');
const config = require('../config');

/**
 * Middleware to verify JWT token
 */
const verifyToken = (req, res, next) => {
  const token = req.headers['x-access-token'] || req.headers['authorization'];
  
  if (!token) {
    return res.status(403).json({ 
      success: false, 
      message: 'No token provided' 
    });
  }
  
  // Remove Bearer prefix if present
  const tokenString = token.startsWith('Bearer ') ? token.slice(7) : token;
  
  try {
    const decoded = jwt.verify(tokenString, config.api.jwtSecret);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
};

/**
 * Middleware to check if user is an admin
 */
const isAdmin = (req, res, next) => {
  if (!req.user || !req.user.role || req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Admin access required'
    });
  }
  next();
};

/**
 * Middleware to check if user is a credit provider
 */
const isCreditProvider = (req, res, next) => {
  if (!req.user || !req.user.role || 
      (req.user.role !== 'admin' && req.user.role !== 'provider')) {
    return res.status(403).json({
      success: false,
      message: 'Credit provider access required'
    });
  }
  next();
};

module.exports = {
  verifyToken,
  isAdmin,
  isCreditProvider
};

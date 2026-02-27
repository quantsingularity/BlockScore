/**
 * API Configuration
 * Central configuration for all API-related settings
 */

export const API_CONFIG = {
  BASE_URL: process.env.API_BASE_URL || "http://localhost:3000",
  TIMEOUT: parseInt(process.env.API_TIMEOUT || "30000", 10),
  ENDPOINTS: {
    // Auth endpoints
    AUTH: {
      LOGIN: "/api/auth/login",
      REGISTER: "/api/auth/register",
      WALLET: "/api/auth/wallet",
    },
    // Credit endpoints
    CREDIT: {
      SCORE: "/api/credit/score",
      HISTORY: "/api/credit/history",
      CALCULATE: "/api/credit/calculate-score",
    },
    // Loan endpoints
    LOANS: {
      GET_BY_ID: "/api/loans",
      GET_BY_BORROWER: "/api/loans/borrower",
      CREATE: "/api/loans/create",
      APPROVE: "/api/loans/approve",
      REPAY: "/api/loans/repay",
    },
    // Health check
    HEALTH: "/health",
  },
};

export default API_CONFIG;

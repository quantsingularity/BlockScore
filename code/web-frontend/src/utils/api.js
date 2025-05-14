// API service for making backend requests
import axios from 'axios';

// Create axios instance with default config
const api = axios.create({
  baseURL: process.env.NODE_ENV === 'production'
    ? '/api'
    : 'http://localhost:5000/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Credit score API calls
export const getCreditScore = async (walletAddress) => {
  try {
    const response = await api.post('/calculate-score', { walletAddress });
    return response.data;
  } catch (error) {
    console.error('Error fetching credit score:', error);
    throw error;
  }
};

// Loan calculation API calls
export const calculateLoan = async (walletAddress, amount, rate) => {
  try {
    const response = await api.post('/calculate-loan', {
      walletAddress,
      amount,
      rate
    });
    return response.data;
  } catch (error) {
    console.error('Error calculating loan:', error);
    throw error;
  }
};

// Health check
export const checkApiHealth = async () => {
  try {
    const response = await api.get('/health');
    return response.data;
  } catch (error) {
    console.error('API health check failed:', error);
    throw error;
  }
};

export default api;

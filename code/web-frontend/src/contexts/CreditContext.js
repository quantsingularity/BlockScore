import React, { createContext, useState, useContext, useEffect } from 'react';
import { getCreditScore } from '../utils/api';
import { useAuth } from './AuthContext';
import { useWeb3 } from './Web3Context';

// Create context
const CreditContext = createContext();

// Provider component
export const CreditProvider = ({ children }) => {
  const { user } = useAuth();
  const { accounts } = useWeb3();

  const [creditData, setCreditData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchCreditScore = async (walletAddress) => {
    try {
      setLoading(true);
      setError(null);

      // Use provided wallet address or get from context
      const address = walletAddress || accounts[0] || user?.address;

      if (!address) {
        throw new Error('No wallet address available');
      }

      const data = await getCreditScore(address);
      setCreditData(data);
      return data;
    } catch (err) {
      console.error('Error fetching credit score:', err);
      setError('Failed to load credit score data. Please try again later.');

      // For demo purposes, set mock data if API fails
      const mockData = {
        address: walletAddress || accounts[0] || user?.address || '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        score: 720,
        features: {
          total_loans: 5,
          total_amount: 15000,
          repaid_ratio: 0.8,
          avg_loan_amount: 3000
        },
        history: [
          { timestamp: Date.now() - 7776000000, amount: 1000, repaid: true },
          { timestamp: Date.now() - 5184000000, amount: 2000, repaid: true },
          { timestamp: Date.now() - 2592000000, amount: 3000, repaid: true },
          { timestamp: Date.now() - 1296000000, amount: 4000, repaid: true },
          { timestamp: Date.now() - 604800000, amount: 5000, repaid: false }
        ]
      };

      setCreditData(mockData);
      return mockData;
    } finally {
      setLoading(false);
    }
  };

  // Fetch credit score on component mount or when wallet/user changes
  useEffect(() => {
    const walletAddress = accounts[0] || user?.address;
    if (walletAddress) {
      fetchCreditScore(walletAddress);
    }
  }, [accounts, user]);

  return (
    <CreditContext.Provider
      value={{
        creditData,
        loading,
        error,
        fetchCreditScore
      }}
    >
      {children}
    </CreditContext.Provider>
  );
};

// Custom hook to use the credit context
export const useCredit = () => useContext(CreditContext);

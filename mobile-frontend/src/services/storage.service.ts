/**
 * Storage Service
 * Handles secure storage of user data, tokens, and preferences
 */

import AsyncStorage from '@react-native-async-storage/async-storage';

// Storage keys
const STORAGE_KEYS = {
  TOKEN: '@BlockScore:token',
  USER: '@BlockScore:user',
  WALLET_ADDRESS: '@BlockScore:walletAddress',
};

/**
 * Save auth token
 */
export const saveToken = async (token: string): Promise<void> => {
  try {
    await AsyncStorage.setItem(STORAGE_KEYS.TOKEN, token);
  } catch (error) {
    console.error('Error saving token:', error);
    throw error;
  }
};

/**
 * Get auth token
 */
export const getToken = async (): Promise<string | null> => {
  try {
    return await AsyncStorage.getItem(STORAGE_KEYS.TOKEN);
  } catch (error) {
    console.error('Error getting token:', error);
    return null;
  }
};

/**
 * Clear auth token
 */
export const clearToken = async (): Promise<void> => {
  try {
    await AsyncStorage.removeItem(STORAGE_KEYS.TOKEN);
  } catch (error) {
    console.error('Error clearing token:', error);
    throw error;
  }
};

/**
 * Save user data
 */
export const saveUser = async (user: any): Promise<void> => {
  try {
    await AsyncStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(user));
  } catch (error) {
    console.error('Error saving user:', error);
    throw error;
  }
};

/**
 * Get user data
 */
export const getUser = async (): Promise<any | null> => {
  try {
    const userStr = await AsyncStorage.getItem(STORAGE_KEYS.USER);
    return userStr ? JSON.parse(userStr) : null;
  } catch (error) {
    console.error('Error getting user:', error);
    return null;
  }
};

/**
 * Clear user data
 */
export const clearUser = async (): Promise<void> => {
  try {
    await AsyncStorage.removeItem(STORAGE_KEYS.USER);
  } catch (error) {
    console.error('Error clearing user:', error);
    throw error;
  }
};

/**
 * Save wallet address
 */
export const saveWalletAddress = async (address: string): Promise<void> => {
  try {
    await AsyncStorage.setItem(STORAGE_KEYS.WALLET_ADDRESS, address);
  } catch (error) {
    console.error('Error saving wallet address:', error);
    throw error;
  }
};

/**
 * Get wallet address
 */
export const getWalletAddress = async (): Promise<string | null> => {
  try {
    return await AsyncStorage.getItem(STORAGE_KEYS.WALLET_ADDRESS);
  } catch (error) {
    console.error('Error getting wallet address:', error);
    return null;
  }
};

/**
 * Clear all storage
 */
export const clearAll = async (): Promise<void> => {
  try {
    await AsyncStorage.multiRemove([
      STORAGE_KEYS.TOKEN,
      STORAGE_KEYS.USER,
      STORAGE_KEYS.WALLET_ADDRESS,
    ]);
  } catch (error) {
    console.error('Error clearing storage:', error);
    throw error;
  }
};

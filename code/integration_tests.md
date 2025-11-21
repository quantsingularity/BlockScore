# BlockScore Integration Tests

This file contains tests to verify the integration between frontend and backend components.

## API Endpoints to Test

1. `/api/health` - Health check endpoint
2. `/api/calculate-score` - Credit score calculation endpoint
3. `/api/calculate-loan` - Loan eligibility calculation endpoint

## Frontend-Backend Integration

- Verify that the frontend can successfully connect to the backend API
- Ensure proper error handling when API calls fail
- Check that data is correctly passed between components

## Test Cases

### Health Check

- Should return status "ok" when backend is running

### Credit Score Calculation

- Should return a valid credit score for a given wallet address
- Should include credit history and features in the response
- Should handle invalid wallet addresses gracefully

### Loan Calculation

- Should calculate monthly payments correctly based on amount and rate
- Should determine approval probability based on credit score
- Should handle edge cases (very large loans, very high interest rates)

## Mock Data

For testing purposes, we can use the following mock wallet addresses:

- `0x742d35Cc6634C0532925a3b844Bc454e4438f44e` - Good credit score
- `0x123456789abcdef123456789abcdef123456789a` - Poor credit score
- `0x0000000000000000000000000000000000000000` - No credit history

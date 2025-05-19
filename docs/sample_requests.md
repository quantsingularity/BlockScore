# Sample Requests for BlockScore API

This document provides sample requests for the BlockScore API to help you get started quickly.

## Authentication Requests

### Register a new user

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

### Update wallet address

```bash
curl -X POST http://localhost:3000/api/auth/wallet \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "walletAddress": "0x123456789abcdef..."
  }'
```

## Credit Operations

### Get credit score

```bash
curl -X GET http://localhost:3000/api/credit/score/0x123456789abcdef...
```

### Get credit history

```bash
curl -X GET http://localhost:3000/api/credit/history/0x123456789abcdef...
```

### Add credit record (requires provider authorization)

```bash
curl -X POST http://localhost:3000/api/credit/record \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "userAddress": "0x123456789abcdef...",
    "amount": 10000,
    "recordType": "loan",
    "scoreImpact": 5,
    "privateKey": "abcdef123456..."
  }'
```

### Mark record as repaid (requires provider authorization)

```bash
curl -X POST http://localhost:3000/api/credit/record/repaid \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "userAddress": "0x123456789abcdef...",
    "recordIndex": 0,
    "privateKey": "abcdef123456..."
  }'
```

### Calculate credit score using AI model

```bash
curl -X POST http://localhost:3000/api/credit/calculate-score \
  -H "Content-Type: application/json" \
  -d '{
    "walletAddress": "0x123456789abcdef..."
  }'
```

## Loan Operations

### Get loan details

```bash
curl -X GET http://localhost:3000/api/loans/1
```

### Get borrower loans

```bash
curl -X GET http://localhost:3000/api/loans/borrower/0x123456789abcdef...
```

### Create loan

```bash
curl -X POST http://localhost:3000/api/loans/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "amount": 20000,
    "interestRate": 500,
    "durationDays": 30,
    "privateKey": "abcdef123456..."
  }'
```

### Approve loan (requires admin)

```bash
curl -X POST http://localhost:3000/api/loans/approve/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "privateKey": "abcdef123456..."
  }'
```

### Repay loan

```bash
curl -X POST http://localhost:3000/api/loans/repay/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "privateKey": "abcdef123456..."
  }'
```

## Python Model API Requests

### Health check

```bash
curl -X GET http://localhost:5000/health
```

### Predict credit score

```bash
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "creditHistory": [
      {
        "timestamp": 1621500000,
        "amount": 5000,
        "repaid": true,
        "repaymentTimestamp": 1623500000,
        "provider": "0x123...",
        "recordType": "loan",
        "scoreImpact": 5
      }
    ]
  }'
```

### Batch predict credit scores

```bash
curl -X POST http://localhost:5000/batch-predict \
  -H "Content-Type: application/json" \
  -d '{
    "batch": [
      {
        "userId": "user1",
        "creditHistory": [
          {
            "timestamp": 1621500000,
            "amount": 5000,
            "repaid": true,
            "repaymentTimestamp": 1623500000,
            "provider": "0x123...",
            "recordType": "loan",
            "scoreImpact": 5
          }
        ]
      },
      {
        "userId": "user2",
        "creditHistory": []
      }
    ]
  }'
```

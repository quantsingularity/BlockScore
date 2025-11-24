# API Documentation

## Base URL

```
Development: http://localhost:3000/api/v1
Production: https://api.blockscore.com/v1
```

## Authentication

All API requests require authentication using JWT tokens or Web3 wallet signatures.

### Headers

```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

## Endpoints

### User Management

#### Register User

```http
POST /users/register
```

**Request Body:**

```json
{
    "walletAddress": "0x...",
    "email": "user@example.com",
    "signature": "0x..."
}
```

**Response:**

```json
{
    "userId": "user_123",
    "token": "jwt_token",
    "message": "User registered successfully"
}
```

#### Get User Profile

```http
GET /users/profile
```

**Response:**

```json
{
    "userId": "user_123",
    "walletAddress": "0x...",
    "creditScore": 750,
    "lastUpdated": "2024-03-15T12:00:00Z"
}
```

### Credit Score

#### Get Credit Score

```http
GET /credit-score/{userId}
```

**Response:**

```json
{
    "userId": "user_123",
    "score": 750,
    "factors": [
        {
            "factor": "payment_history",
            "impact": "high",
            "score": 85
        }
    ],
    "lastUpdated": "2024-03-15T12:00:00Z"
}
```

#### Update Credit Data

```http
POST /credit-score/update
```

**Request Body:**

```json
{
    "userId": "user_123",
    "transactionData": {
        "type": "payment",
        "amount": 1000,
        "timestamp": "2024-03-15T12:00:00Z"
    }
}
```

### Loan Management

#### Submit Loan Application

```http
POST /loans/apply
```

**Request Body:**

```json
{
    "userId": "user_123",
    "amount": 5000,
    "term": 12,
    "purpose": "business"
}
```

#### Get Loan Status

```http
GET /loans/{loanId}
```

**Response:**

```json
{
    "loanId": "loan_456",
    "status": "approved",
    "amount": 5000,
    "term": 12,
    "apr": 5.5
}
```

### Transaction History

#### Get Transaction History

```http
GET /transactions/{userId}
```

**Query Parameters:**

- `startDate` (optional): Filter transactions from this date
- `endDate` (optional): Filter transactions until this date
- `type` (optional): Transaction type filter

**Response:**

```json
{
    "transactions": [
        {
            "id": "tx_789",
            "type": "payment",
            "amount": 1000,
            "timestamp": "2024-03-15T12:00:00Z",
            "status": "confirmed"
        }
    ],
    "pagination": {
        "total": 50,
        "page": 1,
        "limit": 10
    }
}
```

## Error Handling

### Error Response Format

```json
{
    "error": {
        "code": "ERROR_CODE",
        "message": "Human readable error message",
        "details": {}
    }
}
```

### Common Error Codes

- `AUTH_001`: Authentication failed
- `AUTH_002`: Invalid signature
- `USER_001`: User not found
- `LOAN_001`: Invalid loan application
- `SCORE_001`: Unable to calculate credit score

## Rate Limiting

- 100 requests per minute per IP
- 1000 requests per hour per user

## Webhook Notifications

### Credit Score Updates

```http
POST /webhook/credit-score
```

**Payload:**

```json
{
    "userId": "user_123",
    "event": "score_updated",
    "newScore": 750,
    "timestamp": "2024-03-15T12:00:00Z"
}
```

## SDK Examples

### JavaScript/TypeScript

```typescript
import { BlockScoreAPI } from '@blockscore/sdk';

const api = new BlockScoreAPI({
    apiKey: 'your_api_key',
    environment: 'production',
});

// Get user's credit score
const score = await api.creditScore.get('user_123');
```

### Python

```python
from blockscore import BlockScoreAPI

api = BlockScoreAPI(
    api_key='your_api_key',
    environment='production'
)

# Get user's credit score
score = api.credit_score.get('user_123')
```

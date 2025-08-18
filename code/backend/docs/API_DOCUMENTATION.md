# BlockScore Backend API Documentation

## Overview

The BlockScore Backend API provides comprehensive financial services including credit scoring, loan management, compliance monitoring, and blockchain integration. This RESTful API is designed to meet financial industry standards with enterprise-grade security, scalability, and compliance features.

## Base URL

```
Production: https://api.blockscore.com/v1
Development: http://localhost:5000/api
```

## Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

### Authentication Flow

1. **Register** or **Login** to obtain access and refresh tokens
2. **Include access token** in subsequent API requests
3. **Refresh token** when access token expires
4. **Logout** to invalidate tokens

## API Endpoints

### Authentication Endpoints

#### POST /auth/register
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123!",
  "first_name": "John",
  "last_name": "Doe",
  "date_of_birth": "1990-01-01",
  "phone_number": "+1234567890",
  "address_line1": "123 Main Street",
  "city": "New York",
  "state": "NY",
  "postal_code": "10001",
  "country": "US"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "user_id": "uuid-string",
  "message": "User registered successfully",
  "verification_required": true
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Invalid email format"],
    "password": ["Password must be at least 8 characters"]
  }
}
```

#### POST /auth/login
Authenticate user and obtain tokens.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123!",
  "mfa_token": "123456"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "access_token": "jwt_access_token",
  "refresh_token": "jwt_refresh_token",
  "expires_in": 3600,
  "user": {
    "id": "uuid-string",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "mfa_enabled": false
  }
}
```

#### POST /auth/refresh
Refresh access token using refresh token.

**Request Body:**
```json
{
  "refresh_token": "jwt_refresh_token"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "access_token": "new_jwt_access_token",
  "refresh_token": "new_jwt_refresh_token",
  "expires_in": 3600
}
```

#### POST /auth/logout
Logout and invalidate tokens.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

#### POST /auth/password/change
Change user password.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewPassword123!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

#### POST /auth/password/reset-request
Request password reset.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password reset email sent"
}
```

#### POST /auth/password/reset
Reset password using reset token.

**Request Body:**
```json
{
  "reset_token": "reset_token_string",
  "new_password": "NewPassword123!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

#### POST /auth/mfa/enable
Enable multi-factor authentication.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "secret": "mfa_secret_key",
  "qr_code": "data:image/png;base64,..."
}
```

#### POST /auth/mfa/verify
Verify MFA token.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "mfa_token": "123456"
}
```

**Response (200 OK):**
```json
{
  "valid": true,
  "message": "MFA token verified"
}
```

#### POST /auth/mfa/disable
Disable multi-factor authentication.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "mfa_token": "123456"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "MFA disabled successfully"
}
```

### Credit Scoring Endpoints

#### GET /credit/score
Get current credit score for authenticated user.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "score": 750,
  "score_range": "excellent",
  "calculated_at": "2024-01-15T10:30:00Z",
  "version": "v2.0",
  "factors_positive": [
    "payment_history",
    "credit_utilization",
    "credit_age"
  ],
  "factors_negative": [
    "new_credit_inquiries"
  ],
  "next_update": "2024-02-15T10:30:00Z"
}
```

**Error Response (404 Not Found):**
```json
{
  "error": "Credit score not found",
  "message": "No credit score available for this user"
}
```

#### POST /credit/calculate
Calculate or recalculate credit score.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body (Optional):**
```json
{
  "wallet_address": "0x1234567890123456789012345678901234567890",
  "force_recalculation": true
}
```

**Response (200 OK):**
```json
{
  "score": 725,
  "score_change": 15,
  "factors": [
    {
      "factor": "payment_history",
      "impact": "positive",
      "weight": 0.35,
      "description": "Consistent on-time payments"
    }
  ],
  "version": "v2.0",
  "ai_confidence": 0.87,
  "blockchain_transaction": {
    "transaction_id": "uuid-string",
    "transaction_hash": "0xabcdef...",
    "status": "submitted"
  }
}
```

#### GET /credit/history
Get credit score history.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `limit` (optional): Number of records to return (default: 10, max: 100)
- `start_date` (optional): Start date for history (ISO 8601 format)
- `end_date` (optional): End date for history (ISO 8601 format)

**Response (200 OK):**
```json
[
  {
    "score": 750,
    "calculated_at": "2024-01-15T10:30:00Z",
    "version": "v2.0",
    "score_change": 10
  },
  {
    "score": 740,
    "calculated_at": "2024-01-01T10:30:00Z",
    "version": "v2.0",
    "score_change": -5
  }
]
```

#### POST /credit/events
Add credit event (payment, new account, etc.).

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "event_type": "payment_made",
  "amount": 500.00,
  "description": "Monthly credit card payment",
  "event_date": "2024-01-15T10:30:00Z",
  "account_type": "credit_card"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "event_id": "uuid-string",
  "message": "Credit event added successfully",
  "impact_score": 5
}
```

#### GET /credit/factors
Get detailed credit factors analysis.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "positive_factors": [
    {
      "factor": "payment_history",
      "weight": 0.35,
      "score": 95,
      "description": "Excellent payment history",
      "recommendations": [
        "Continue making on-time payments"
      ]
    }
  ],
  "negative_factors": [
    {
      "factor": "credit_utilization",
      "weight": 0.30,
      "score": 60,
      "description": "High credit utilization",
      "recommendations": [
        "Reduce credit card balances",
        "Consider increasing credit limits"
      ]
    }
  ]
}
```

#### GET /credit/recommendations
Get personalized credit improvement recommendations.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
[
  {
    "title": "Reduce Credit Utilization",
    "description": "Lower your credit card balances to improve your score",
    "priority": "high",
    "estimated_impact": "+25 points",
    "timeframe": "1-2 months",
    "actions": [
      "Pay down credit card balances",
      "Consider balance transfer options",
      "Request credit limit increases"
    ]
  }
]
```

#### POST /credit/simulate
Simulate impact of potential credit events.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "event_type": "payment_made",
  "amount": 1000.00,
  "scenario": "monthly_payment"
}
```

**Response (200 OK):**
```json
{
  "current_score": 720,
  "projected_score": 735,
  "score_change": 15,
  "confidence": 0.82,
  "timeframe": "1-3 months"
}
```

#### GET /credit/report
Generate comprehensive credit report.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "user_info": {
    "name": "John Doe",
    "report_date": "2024-01-15T10:30:00Z"
  },
  "current_score": {
    "score": 750,
    "range": "excellent",
    "calculated_at": "2024-01-15T10:30:00Z"
  },
  "score_history": [...],
  "credit_factors": {...},
  "recent_activity": [...],
  "recommendations": [...],
  "trends": {
    "trend_direction": "improving",
    "trend_strength": "moderate",
    "score_change_6m": 45
  }
}
```

### Loan Management Endpoints

#### POST /loans/apply
Submit loan application.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "loan_type": "personal",
  "requested_amount": 25000.00,
  "requested_term_months": 60,
  "requested_rate": 12.5,
  "purpose": "debt_consolidation",
  "employment_status": "employed",
  "annual_income": 85000.00,
  "monthly_expenses": 3500.00,
  "collateral_type": "none",
  "additional_info": "Stable employment for 5 years"
}
```

**Response (201 Created):**
```json
{
  "application_id": "uuid-string",
  "status": "submitted",
  "reference_number": "LA-2024-001234",
  "submitted_at": "2024-01-15T10:30:00Z",
  "estimated_decision_time": "2-3 business days"
}
```

#### GET /loans/applications
Get user's loan applications.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `status` (optional): Filter by status (pending, approved, rejected, etc.)
- `limit` (optional): Number of records to return
- `offset` (optional): Pagination offset

**Response (200 OK):**
```json
[
  {
    "id": "uuid-string",
    "reference_number": "LA-2024-001234",
    "loan_type": "personal",
    "requested_amount": 25000.00,
    "status": "under_review",
    "submitted_at": "2024-01-15T10:30:00Z",
    "last_updated": "2024-01-16T09:15:00Z"
  }
]
```

#### GET /loans/applications/{application_id}
Get specific loan application details.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "id": "uuid-string",
  "reference_number": "LA-2024-001234",
  "status": "approved",
  "loan_type": "personal",
  "requested_amount": 25000.00,
  "approved_amount": 22000.00,
  "approved_rate": 13.2,
  "approved_term_months": 60,
  "monthly_payment": 495.67,
  "total_interest": 7740.20,
  "submitted_at": "2024-01-15T10:30:00Z",
  "decision_date": "2024-01-17T14:22:00Z",
  "conditions": [
    "Provide proof of income",
    "Set up automatic payments"
  ],
  "next_steps": [
    "Review and sign loan agreement",
    "Provide required documentation"
  ]
}
```

#### POST /loans/applications/{application_id}/accept
Accept approved loan offer.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "electronic_signature": true,
  "terms_accepted": true
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "loan_id": "uuid-string",
  "status": "accepted",
  "next_steps": [
    "Complete final verification",
    "Funds will be disbursed within 2 business days"
  ]
}
```

#### GET /loans/active
Get user's active loans.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
[
  {
    "id": "uuid-string",
    "reference_number": "LN-2024-001234",
    "loan_type": "personal",
    "original_amount": 22000.00,
    "current_balance": 18500.00,
    "monthly_payment": 495.67,
    "next_payment_date": "2024-02-15",
    "next_payment_amount": 495.67,
    "interest_rate": 13.2,
    "remaining_payments": 37,
    "status": "current"
  }
]
```

#### GET /loans/{loan_id}/payments
Get loan payment history.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
[
  {
    "payment_id": "uuid-string",
    "payment_date": "2024-01-15",
    "amount": 495.67,
    "principal": 312.45,
    "interest": 183.22,
    "remaining_balance": 18500.00,
    "status": "completed",
    "payment_method": "bank_transfer"
  }
]
```

#### POST /loans/{loan_id}/payments
Make loan payment.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "amount": 495.67,
  "payment_method": "bank_transfer",
  "payment_date": "2024-01-15"
}
```

**Response (201 Created):**
```json
{
  "payment_id": "uuid-string",
  "status": "processing",
  "confirmation_number": "PAY-2024-567890",
  "estimated_completion": "2024-01-17T10:00:00Z"
}
```

### Compliance Endpoints

#### POST /compliance/kyc
Perform KYC (Know Your Customer) assessment.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body (Optional):**
```json
{
  "kyc_level": "enhanced"
}
```

**Response (200 OK):**
```json
{
  "compliance_record_id": "uuid-string",
  "kyc_status": "verified",
  "compliance_score": 92,
  "assessment_results": {
    "identity_verification": {
      "status": "passed",
      "score": 95
    },
    "address_verification": {
      "status": "passed",
      "score": 90
    },
    "document_verification": {
      "status": "passed",
      "score": 88
    }
  },
  "required_actions": [],
  "next_review_date": "2025-01-15T10:30:00Z"
}
```

#### POST /compliance/aml
Perform AML (Anti-Money Laundering) screening.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body (Optional):**
```json
{
  "transaction_amount": 10000.00,
  "transaction_type": "loan_disbursement",
  "counterparty": "Bank of America"
}
```

**Response (200 OK):**
```json
{
  "compliance_record_id": "uuid-string",
  "aml_status": "compliant",
  "risk_score": 15,
  "screening_results": {
    "sanctions_check": {
      "status": "clear",
      "matches": []
    },
    "pep_check": {
      "status": "clear",
      "risk_level": "low"
    },
    "transaction_monitoring": {
      "status": "normal",
      "risk_indicators": []
    }
  },
  "sar_required": false,
  "recommended_actions": []
}
```

#### GET /compliance/status
Get user's compliance status.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "kyc_status": "verified",
  "kyc_level": "enhanced",
  "aml_status": "compliant",
  "last_kyc_date": "2024-01-15T10:30:00Z",
  "last_aml_screening": "2024-01-16T14:20:00Z",
  "next_review_date": "2025-01-15T10:30:00Z",
  "compliance_score": 92,
  "risk_level": "low"
}
```

### Blockchain Endpoints

#### POST /blockchain/credit-score
Submit credit score to blockchain.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "wallet_address": "0x1234567890123456789012345678901234567890",
  "score": 750
}
```

**Response (200 OK):**
```json
{
  "transaction_id": "uuid-string",
  "transaction_hash": "0xabcdef1234567890...",
  "status": "submitted",
  "estimated_confirmation_time": 180,
  "network": "ethereum",
  "gas_estimate": {
    "gas_limit": 200000,
    "gas_price": "20 gwei",
    "estimated_cost": "0.004 ETH"
  }
}
```

#### GET /blockchain/transactions/{transaction_hash}
Get blockchain transaction status.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "transaction_hash": "0xabcdef1234567890...",
  "status": "confirmed",
  "block_number": 18500000,
  "block_hash": "0x123456789abcdef...",
  "confirmations": 12,
  "gas_used": 185000,
  "gas_price": "20000000000",
  "transaction_fee": "0.0037 ETH",
  "confirmed_at": "2024-01-15T10:35:00Z"
}
```

#### GET /blockchain/wallet/{wallet_address}/history
Get wallet transaction history.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `limit` (optional): Number of transactions to return
- `offset` (optional): Pagination offset

**Response (200 OK):**
```json
[
  {
    "transaction_hash": "0xabcdef1234567890...",
    "transaction_type": "credit_score_update",
    "status": "confirmed",
    "timestamp": "2024-01-15T10:35:00Z",
    "block_number": 18500000,
    "gas_used": 185000
  }
]
```

#### POST /blockchain/loan-agreement
Submit loan agreement to blockchain.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "loan_id": "uuid-string",
  "borrower_address": "0x1234567890123456789012345678901234567890",
  "loan_amount": 25000.00,
  "interest_rate": 12.5,
  "term_months": 60
}
```

**Response (200 OK):**
```json
{
  "transaction_id": "uuid-string",
  "transaction_hash": "0xfedcba0987654321...",
  "status": "submitted",
  "contract_address": "0x9876543210987654321098765432109876543210"
}
```

### User Profile Endpoints

#### GET /users/profile
Get user profile information.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "id": "uuid-string",
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "date_of_birth": "1990-01-01",
  "phone_number": "+1234567890",
  "address": {
    "line1": "123 Main Street",
    "line2": "Apt 4B",
    "city": "New York",
    "state": "NY",
    "postal_code": "10001",
    "country": "US"
  },
  "employment": {
    "status": "employed",
    "employer": "Tech Corp",
    "position": "Software Engineer",
    "annual_income": 85000.00
  },
  "kyc_status": "verified",
  "created_at": "2024-01-01T10:00:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

#### PUT /users/profile
Update user profile information.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "first_name": "John",
  "last_name": "Smith",
  "phone_number": "+1234567891",
  "address": {
    "line1": "456 Oak Avenue",
    "city": "Boston",
    "state": "MA",
    "postal_code": "02101",
    "country": "US"
  },
  "employment": {
    "employer": "New Tech Corp",
    "position": "Senior Software Engineer",
    "annual_income": 95000.00
  }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "updated_fields": [
    "last_name",
    "phone_number",
    "address",
    "employment"
  ]
}
```

#### GET /users/sessions
Get active user sessions.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
[
  {
    "id": "uuid-string",
    "device_info": "Chrome on Windows",
    "ip_address": "192.168.1.100",
    "location": "New York, NY",
    "created_at": "2024-01-15T10:30:00Z",
    "last_activity": "2024-01-15T14:22:00Z",
    "is_current": true
  }
]
```

#### DELETE /users/sessions/{session_id}
Revoke specific user session.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Session revoked successfully"
}
```

### Health and Monitoring Endpoints

#### GET /health
Basic health check.

**Response (200 OK):**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0"
}
```

#### GET /health/detailed
Detailed health check (requires authentication).

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "status": "healthy",
  "health_score": 95,
  "timestamp": "2024-01-15T10:30:00Z",
  "services": {
    "database": {
      "status": "healthy",
      "response_time_ms": 15,
      "connections": 5
    },
    "cache": {
      "status": "healthy",
      "hit_rate": 87.5,
      "memory_usage": "45%"
    },
    "blockchain": {
      "status": "connected",
      "network": "ethereum",
      "latest_block": 18500000
    }
  },
  "metrics": {
    "requests_per_minute": 150,
    "average_response_time": 245,
    "error_rate": 0.02
  }
}
```

## Error Handling

The API uses standard HTTP status codes and returns consistent error responses:

### Error Response Format

```json
{
  "error": "Error type",
  "message": "Human-readable error description",
  "code": "ERROR_CODE",
  "details": {
    "field": "Additional error details"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "uuid-string"
}
```

### Common HTTP Status Codes

- **200 OK**: Request successful
- **201 Created**: Resource created successfully
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication required or invalid
- **403 Forbidden**: Access denied
- **404 Not Found**: Resource not found
- **409 Conflict**: Resource already exists
- **422 Unprocessable Entity**: Validation failed
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Server error

### Error Codes

- `VALIDATION_ERROR`: Request validation failed
- `AUTHENTICATION_ERROR`: Authentication failed
- `AUTHORIZATION_ERROR`: Insufficient permissions
- `RESOURCE_NOT_FOUND`: Requested resource not found
- `DUPLICATE_RESOURCE`: Resource already exists
- `RATE_LIMIT_EXCEEDED`: Too many requests
- `SERVICE_UNAVAILABLE`: External service unavailable
- `BLOCKCHAIN_ERROR`: Blockchain operation failed
- `COMPLIANCE_ERROR`: Compliance check failed

## Rate Limiting

The API implements rate limiting to ensure fair usage:

- **Authentication endpoints**: 5 requests per minute per IP
- **Credit scoring endpoints**: 10 requests per minute per user
- **General endpoints**: 100 requests per minute per user

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642248600
```

## Pagination

List endpoints support pagination using query parameters:

- `limit`: Number of items per page (default: 20, max: 100)
- `offset`: Number of items to skip
- `page`: Page number (alternative to offset)

Pagination metadata is included in responses:

```json
{
  "data": [...],
  "pagination": {
    "total": 150,
    "limit": 20,
    "offset": 40,
    "page": 3,
    "pages": 8,
    "has_next": true,
    "has_prev": true
  }
}
```

## Webhooks

The API supports webhooks for real-time notifications:

### Webhook Events

- `credit_score.calculated`: Credit score calculated or updated
- `loan.application.submitted`: Loan application submitted
- `loan.application.approved`: Loan application approved
- `loan.application.rejected`: Loan application rejected
- `payment.completed`: Loan payment completed
- `compliance.kyc.completed`: KYC assessment completed
- `blockchain.transaction.confirmed`: Blockchain transaction confirmed

### Webhook Payload Format

```json
{
  "event": "credit_score.calculated",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "user_id": "uuid-string",
    "score": 750,
    "previous_score": 740,
    "calculated_at": "2024-01-15T10:30:00Z"
  },
  "webhook_id": "uuid-string"
}
```

## SDKs and Libraries

Official SDKs are available for popular programming languages:

- **JavaScript/Node.js**: `npm install blockscore-sdk`
- **Python**: `pip install blockscore-sdk`
- **PHP**: `composer require blockscore/sdk`
- **Java**: Maven/Gradle dependency available

## Support

For API support and questions:

- **Documentation**: https://docs.blockscore.com
- **Support Email**: api-support@blockscore.com
- **Status Page**: https://status.blockscore.com
- **GitHub Issues**: https://github.com/blockscore/api-issues


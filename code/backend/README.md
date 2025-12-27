# BlockScore Backend

Production-ready Flask backend for blockchain-based credit scoring platform.

## Features

- **Credit Scoring**: AI-powered credit score calculation with blockchain integration
- **Loan Management**: Complete loan application and approval workflow
- **User Authentication**: Secure JWT-based authentication with MFA support
- **Compliance**: KYC/AML compliance checking and audit logging
- **Blockchain Integration**: Smart contract interaction for credit scores and loans
- **API Security**: Rate limiting, audit logging, and comprehensive security features

## Requirements

- Python 3.8+
- SQLite (default) or PostgreSQL/MySQL
- Redis (optional, for caching and rate limiting)
- Ethereum node (optional, for blockchain features)

## Installation

### 1. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\\Scripts\\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and update configuration values:

- Set `SECRET_KEY` and `JWT_SECRET_KEY` to secure random strings
- Configure database URL if using PostgreSQL/MySQL
- Set blockchain provider URL if using blockchain features
- Configure Redis URL if available

### 4. Initialize Database

The database tables will be created automatically on first run. For production, consider using database migrations.

## Running the Backend

### Development Mode

```bash
python app.py
```

The server will start on `http://0.0.0.0:5000`

### Production Mode

```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

Or with better performance:

```bash
gunicorn -w 4 -b 0.0.0.0:5000 --worker-class gevent app:app
```

## API Endpoints

### Health Check

- `GET /api/health` - System health check

### Authentication

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout (requires auth)

### Credit Scoring

- `POST /api/credit/calculate-score` - Calculate credit score (requires auth)
- `GET /api/credit/history` - Get credit history (requires auth)

### Loans

- `POST /api/loans/apply` - Apply for loan (requires auth)
- `POST /api/loans/calculate` - Calculate loan terms (requires auth)

### Profile

- `GET /api/profile` - Get user profile (requires auth)

## Configuration

### Minimum Configuration (SQLite)

For quick testing with SQLite (no external services required):

```env
FLASK_ENV=development
SECRET_KEY=your-secret-key-here
JWT_SECRET_KEY=your-jwt-secret-key-here
DATABASE_URL=sqlite:///blockscore.db
```

### Full Configuration

For production with all features:

- PostgreSQL database
- Redis for caching and rate limiting
- Ethereum node for blockchain features
- SMS/Email services for notifications

See `.env.example` for all configuration options.

## Running Without External Services

The backend can run in standalone mode without:

- **Redis**: Rate limiting will be disabled gracefully
- **Blockchain**: Blockchain features will report as unavailable
- **AI Model**: Falls back to rule-based credit scoring
- **SMS/Email**: MFA features will be limited

## Testing

Run the test suite:

```bash
pytest
```

With coverage:

```bash
pytest --cov=. --cov-report=html
```

## Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Bcrypt with configurable rounds
- **Rate Limiting**: Endpoint-specific rate limits
- **MFA Support**: TOTP and SMS-based two-factor authentication
- **Audit Logging**: Comprehensive audit trail for compliance
- **Session Management**: Secure session tracking and revocation

## Database

The application uses SQLAlchemy ORM with support for:

- SQLite (default for development)
- PostgreSQL (recommended for production)
- MySQL

Tables are created automatically on first run. For production, consider implementing proper database migrations with Alembic.

## Troubleshooting

### Database Issues

If database errors occur, delete the database file and restart:

```bash
rm blockscore.db
python app.py
```

### Import Errors

Ensure all dependencies are installed:

```bash
pip install -r requirements.txt
```

### Port Already in Use

Change the port in `app.py` or use environment variable:

```bash
export FLASK_RUN_PORT=5001
python app.py
```

## Project Structure

```
backend/
├── app.py                  # Main application entry point
├── config.py               # Configuration management
├── requirements.txt        # Python dependencies
├── .env.example           # Environment template
├── core/                  # Core utilities
│   └── logging.py         # Logging configuration
├── models/                # Database models
│   ├── __init__.py
│   ├── user.py           # User and profile models
│   ├── credit.py         # Credit scoring models
│   ├── loan.py           # Loan models
│   ├── audit.py          # Audit logging models
│   └── blockchain.py     # Blockchain transaction models
├── services/              # Business logic
│   ├── auth_service.py   # Authentication service
│   ├── credit_service.py # Credit scoring service
│   ├── blockchain_service.py  # Blockchain integration
│   ├── compliance_service.py  # KYC/AML compliance
│   ├── audit_service.py  # Audit logging
│   └── mfa_service.py    # Multi-factor authentication
├── middleware/            # Middleware components
│   └── security.py       # Security middleware
├── utils/                 # Utility functions
│   ├── cache.py          # Caching utilities
│   └── background_jobs.py # Background task utilities
└── tests/                # Test suite
    ├── unit/             # Unit tests
    ├── integration/      # Integration tests
    └── conftest.py       # Test configuration
```

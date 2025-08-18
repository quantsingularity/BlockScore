# BlockScore Backend - Production-Ready Financial Services API

## Overview

BlockScore Backend is a comprehensive, production-ready financial services API built with Flask and designed to meet enterprise-grade requirements for credit scoring, loan management, compliance monitoring, and blockchain integration. This implementation follows financial industry standards with robust security, scalability, and compliance features.

## 🚀 Key Features

### Financial Services
- **Advanced Credit Scoring**: AI-powered credit assessment with blockchain integration
- **Loan Management**: Complete loan application, approval, and servicing workflow
- **Compliance Monitoring**: KYC/AML screening and regulatory compliance automation
- **Blockchain Integration**: Smart contract deployment and transaction management

### Enterprise Architecture
- **Production-Ready**: Scalable architecture with microservices design patterns
- **Security First**: Multi-factor authentication, encryption, audit trails
- **High Performance**: Redis caching, database optimization, background job processing
- **Monitoring**: Comprehensive logging, metrics, and health monitoring

### Financial Industry Standards
- **Regulatory Compliance**: SOX, PCI DSS, GDPR compliance features
- **Audit Trails**: Complete transaction and user activity logging
- **Data Security**: Encryption at rest and in transit, secure key management
- **Risk Management**: Real-time fraud detection and risk assessment

## 📋 Requirements

### System Requirements
- **Python**: 3.11+
- **Database**: PostgreSQL 14+
- **Cache**: Redis 6.2+
- **Message Queue**: Celery with Redis broker

### External Services
- **Blockchain**: Ethereum/Polygon RPC endpoint
- **Email**: SMTP service for notifications
- **Monitoring**: APM service (optional)

## 🛠 Installation

### 1. Environment Setup

```bash
# Clone repository
git clone <repository-url>
cd BlockScore/code/backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Database Setup

```bash
# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Create database
sudo -u postgres createdb blockscore_dev
sudo -u postgres createuser blockscore_user
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE blockscore_dev TO blockscore_user;"
```

### 3. Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

Required environment variables:
```env
# Application
SECRET_KEY=your_secret_key_here
JWT_SECRET_KEY=your_jwt_secret_here

# Database
DATABASE_URL=postgresql://blockscore_user:password@localhost:5432/blockscore_dev

# Redis
REDIS_URL=redis://localhost:6379/0

# Blockchain
BLOCKCHAIN_PROVIDER_URL=https://mainnet.infura.io/v3/your_project_id
BLOCKCHAIN_PRIVATE_KEY=0x_your_private_key

# Email
MAIL_SERVER=smtp.gmail.com
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
```

### 4. Database Migration

```bash
# Initialize database
export FLASK_APP=app.py
flask db init
flask db migrate -m "Initial migration"
flask db upgrade
```

## 🚀 Running the Application

### Development Mode

```bash
# Start Redis server
redis-server

# Start Celery worker (in separate terminal)
celery -A app.celery worker --loglevel=info

# Start Celery beat scheduler (in separate terminal)
celery -A app.celery beat --loglevel=info

# Start Flask application
python app.py
```

The API will be available at `http://localhost:5000`

### Production Mode

See [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) for comprehensive production deployment instructions including Docker, Kubernetes, and cloud deployment options.

## 🧪 Testing

### Running Tests

```bash
# Install test dependencies
pip install pytest pytest-cov

# Run all tests
pytest

# Run with coverage
pytest --cov=. --cov-report=html

# Run specific test categories
pytest -m unit          # Unit tests only
pytest -m integration   # Integration tests only
```

### Test Structure

```
tests/
├── conftest.py              # Test configuration and fixtures
├── unit/                    # Unit tests
│   ├── test_auth_service.py
│   └── test_credit_service.py
└── integration/             # Integration tests
    └── test_api_endpoints.py
```

## 📚 API Documentation

### Quick Start

1. **Register a user**:
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "StrongPassword123!",
    "first_name": "John",
    "last_name": "Doe"
  }'
```

2. **Login**:
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "StrongPassword123!"
  }'
```

3. **Get credit score**:
```bash
curl -X GET http://localhost:5000/api/credit/score \
  -H "Authorization: Bearer <your_jwt_token>"
```

### Complete API Reference

See [API Documentation](docs/API_DOCUMENTATION.md) for comprehensive endpoint documentation including:
- Authentication endpoints
- Credit scoring APIs
- Loan management APIs
- Compliance endpoints
- Blockchain integration APIs

## 🏗 Architecture

### Core Components

```
BlockScore Backend
├── app.py                   # Main Flask application
├── config.py               # Configuration management
├── models/                 # Database models
│   ├── user.py            # User and profile models
│   ├── credit.py          # Credit scoring models
│   ├── loan.py            # Loan management models
│   ├── audit.py           # Audit and compliance models
│   └── blockchain.py      # Blockchain integration models
├── services/              # Business logic services
│   ├── auth_service.py    # Authentication service
│   ├── credit_service.py  # Credit scoring service
│   ├── compliance_service.py # Compliance service
│   ├── audit_service.py   # Audit service
│   └── blockchain_service.py # Blockchain service
├── utils/                 # Utility modules
│   ├── cache.py          # Redis caching utilities
│   ├── database.py       # Database optimization
│   ├── monitoring.py     # Performance monitoring
│   └── background_jobs.py # Celery job management
└── tests/                # Test suite
```

### Database Schema

The application uses a comprehensive database schema designed for financial services:

- **Users & Profiles**: User management with KYC information
- **Credit Scoring**: Credit scores, history, and factors
- **Loan Management**: Applications, approvals, and servicing
- **Audit Trails**: Complete activity and compliance logging
- **Blockchain**: Transaction tracking and smart contract management

### Security Features

- **Authentication**: JWT with refresh tokens, MFA support
- **Authorization**: Role-based access control (RBAC)
- **Encryption**: AES-256 encryption for sensitive data
- **Audit Logging**: Complete user activity and system event logging
- **Rate Limiting**: API endpoint protection against abuse
- **Input Validation**: Comprehensive request validation and sanitization

## 🔧 Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SECRET_KEY` | Flask secret key | Yes |
| `JWT_SECRET_KEY` | JWT signing key | Yes |
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `REDIS_URL` | Redis connection string | Yes |
| `BLOCKCHAIN_PROVIDER_URL` | Blockchain RPC endpoint | Yes |
| `BLOCKCHAIN_PRIVATE_KEY` | Blockchain private key | Yes |
| `MAIL_SERVER` | SMTP server | No |
| `SENTRY_DSN` | Error tracking DSN | No |

### Feature Flags

```python
# Enable/disable features via environment variables
ENABLE_BLOCKCHAIN = os.getenv('ENABLE_BLOCKCHAIN', 'true').lower() == 'true'
ENABLE_MFA = os.getenv('ENABLE_MFA', 'true').lower() == 'true'
ENABLE_RATE_LIMITING = os.getenv('ENABLE_RATE_LIMITING', 'true').lower() == 'true'
```

## 📊 Monitoring

### Health Checks

- **Basic**: `GET /api/health`
- **Detailed**: `GET /api/health/detailed` (requires authentication)

### Metrics

The application exposes Prometheus metrics at `/metrics` including:
- Request count and duration
- Database connection pool status
- Cache hit rates
- Background job queue status

### Logging

Structured logging with multiple levels:
- **INFO**: General application events
- **WARNING**: Potential issues
- **ERROR**: Application errors
- **CRITICAL**: System failures

## 🚀 Deployment

### Docker Deployment

```bash
# Build image
docker build -t blockscore-backend .

# Run with docker-compose
docker-compose up -d
```

### Kubernetes Deployment

```bash
# Deploy to Kubernetes
kubectl apply -f k8s/
```

### Production Considerations

- Use environment-specific configuration files
- Set up SSL/TLS certificates
- Configure reverse proxy (Nginx)
- Set up monitoring and alerting
- Configure backup and recovery procedures

See [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) for detailed production deployment instructions.

## 🔒 Security

### Security Features

- **Authentication**: Multi-factor authentication (MFA)
- **Authorization**: Role-based access control
- **Encryption**: Data encryption at rest and in transit
- **Audit Trails**: Comprehensive logging for compliance
- **Rate Limiting**: Protection against abuse
- **Input Validation**: SQL injection and XSS prevention

### Security Best Practices

- Regular security updates
- Secure key management
- Network security configuration
- Regular security audits
- Compliance monitoring

## 🤝 Contributing

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Code Style

- Follow PEP 8 for Python code
- Use type hints where appropriate
- Write comprehensive docstrings
- Maintain test coverage above 80%

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation

- [API Documentation](docs/API_DOCUMENTATION.md)
- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)

### Getting Help

For questions and support:
1. Check the documentation
2. Search existing issues
3. Create a new issue with detailed information

### Troubleshooting

Common issues and solutions:

1. **Database connection errors**: Check PostgreSQL service and credentials
2. **Redis connection errors**: Ensure Redis server is running
3. **Blockchain connection errors**: Verify RPC endpoint and network connectivity
4. **Authentication errors**: Check JWT secret key configuration

## 🔄 Changelog

### Version 1.0.0 (Current)

**Features:**
- Complete financial services API
- Advanced credit scoring with AI
- Comprehensive loan management
- KYC/AML compliance automation
- Blockchain integration
- Enterprise security features
- Production-ready deployment

**Technical:**
- Flask-based REST API
- PostgreSQL database with optimizations
- Redis caching and session management
- Celery background job processing
- Comprehensive test suite (80%+ coverage)
- Docker and Kubernetes support
- Monitoring and observability

---

**Built with ❤️ for financial services innovation**


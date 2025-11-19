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

## 🔧 Advanced Configuration

### Database Configuration

#### Connection Pooling
```python
# config.py
SQLALCHEMY_ENGINE_OPTIONS = {
    'pool_size': 20,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
    'max_overflow': 30
}
```

#### Read Replicas
```python
# For read-heavy workloads
SQLALCHEMY_BINDS = {
    'read_replica': 'postgresql://user:pass@read-replica:5432/blockscore'
}
```

### Redis Configuration

#### Caching Strategy
```python
# Cache configuration
CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_URL': os.getenv('REDIS_URL'),
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'blockscore:'
}
```

#### Session Storage
```python
# Session configuration
SESSION_TYPE = 'redis'
SESSION_REDIS = redis.from_url(os.getenv('REDIS_URL'))
SESSION_PERMANENT = False
SESSION_USE_SIGNER = True
```

### Background Jobs Configuration

#### Celery Configuration
```python
# celery_config.py
broker_url = os.getenv('REDIS_URL')
result_backend = os.getenv('REDIS_URL')
task_serializer = 'json'
accept_content = ['json']
result_serializer = 'json'
timezone = 'UTC'
enable_utc = True

# Task routing
task_routes = {
    'app.tasks.credit_scoring': {'queue': 'credit'},
    'app.tasks.compliance_check': {'queue': 'compliance'},
    'app.tasks.blockchain_transaction': {'queue': 'blockchain'}
}
```

## 📈 Performance Optimization

### Database Optimization

#### Indexing Strategy
```sql
-- Critical indexes for performance
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_credit_scores_user_id ON credit_scores(user_id);
CREATE INDEX CONCURRENTLY idx_loan_applications_status ON loan_applications(status);
CREATE INDEX CONCURRENTLY idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX CONCURRENTLY idx_blockchain_transactions_hash ON blockchain_transactions(transaction_hash);
```

#### Query Optimization
```python
# Use query optimization techniques
from sqlalchemy.orm import joinedload, selectinload

# Eager loading to prevent N+1 queries
users = db.session.query(User).options(
    joinedload(User.profile),
    selectinload(User.credit_scores)
).all()
```

### Caching Strategy

#### Multi-level Caching
```python
# L1: Application-level caching
@lru_cache(maxsize=1000)
def get_credit_score_factors():
    return CreditScoreFactor.query.all()

# L2: Redis caching
@cache.memoize(timeout=3600)
def get_user_credit_score(user_id):
    return CreditScore.query.filter_by(user_id=user_id).first()

# L3: Database query result caching
@cache.cached(timeout=300, key_prefix='loan_rates')
def get_current_loan_rates():
    return LoanRate.query.filter_by(active=True).all()
```

### API Performance

#### Response Compression
```python
from flask_compress import Compress

compress = Compress()
compress.init_app(app)
```

#### Pagination
```python
# Efficient pagination
@app.route('/api/loans/applications')
@auth_required
def get_loan_applications():
    page = request.args.get('page', 1, type=int)
    per_page = min(request.args.get('per_page', 20, type=int), 100)

    applications = LoanApplication.query.filter_by(
        user_id=current_user.id
    ).paginate(
        page=page,
        per_page=per_page,
        error_out=False
    )

    return jsonify({
        'applications': [app.to_dict() for app in applications.items],
        'pagination': {
            'page': page,
            'pages': applications.pages,
            'per_page': per_page,
            'total': applications.total
        }
    })
```

## 🛡️ Advanced Security

### Security Headers
```python
from flask_talisman import Talisman

# Security headers configuration
csp = {
    'default-src': "'self'",
    'script-src': "'self' 'unsafe-inline'",
    'style-src': "'self' 'unsafe-inline'",
    'img-src': "'self' data: https:",
    'connect-src': "'self'",
    'font-src': "'self'",
    'object-src': "'none'",
    'media-src': "'self'",
    'frame-src': "'none'",
}

Talisman(app, content_security_policy=csp)
```

### Input Validation
```python
from marshmallow import Schema, fields, validate

class UserRegistrationSchema(Schema):
    email = fields.Email(required=True)
    password = fields.Str(
        required=True,
        validate=validate.Regexp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
            error='Password must contain at least 8 characters with uppercase, lowercase, number, and special character'
        )
    )
    first_name = fields.Str(required=True, validate=validate.Length(min=1, max=50))
    last_name = fields.Str(required=True, validate=validate.Length(min=1, max=50))
    phone = fields.Str(validate=validate.Regexp(r'^\+?1?\d{9,15}$'))
```

### Encryption Utilities
```python
from cryptography.fernet import Fernet
import base64

class EncryptionService:
    def __init__(self, key=None):
        if key is None:
            key = os.getenv('ENCRYPTION_KEY')
        self.cipher_suite = Fernet(key.encode() if isinstance(key, str) else key)

    def encrypt(self, data):
        if isinstance(data, str):
            data = data.encode()
        encrypted_data = self.cipher_suite.encrypt(data)
        return base64.urlsafe_b64encode(encrypted_data).decode()

    def decrypt(self, encrypted_data):
        encrypted_data = base64.urlsafe_b64decode(encrypted_data.encode())
        decrypted_data = self.cipher_suite.decrypt(encrypted_data)
        return decrypted_data.decode()
```

## 📊 Advanced Monitoring

### Custom Metrics
```python
from prometheus_client import Counter, Histogram, Gauge
import time

# Custom metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
ACTIVE_USERS = Gauge('active_users_total', 'Number of active users')
CREDIT_SCORES_CALCULATED = Counter('credit_scores_calculated_total', 'Total credit scores calculated')

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    request_duration = time.time() - request.start_time
    REQUEST_DURATION.observe(request_duration)
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        status=response.status_code
    ).inc()
    return response
```

### Health Check Endpoints
```python
@app.route('/api/health/detailed')
@auth_required
def detailed_health_check():
    health_status = {
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': app.config.get('VERSION', '1.0.0'),
        'checks': {}
    }

    # Database check
    try:
        db.session.execute('SELECT 1')
        health_status['checks']['database'] = {'status': 'healthy'}
    except Exception as e:
        health_status['checks']['database'] = {'status': 'unhealthy', 'error': str(e)}
        health_status['status'] = 'unhealthy'

    # Redis check
    try:
        cache.get('health_check')
        health_status['checks']['redis'] = {'status': 'healthy'}
    except Exception as e:
        health_status['checks']['redis'] = {'status': 'unhealthy', 'error': str(e)}
        health_status['status'] = 'unhealthy'

    # Celery check
    try:
        from celery import current_app
        inspect = current_app.control.inspect()
        stats = inspect.stats()
        if stats:
            health_status['checks']['celery'] = {'status': 'healthy', 'workers': len(stats)}
        else:
            health_status['checks']['celery'] = {'status': 'unhealthy', 'error': 'No workers available'}
            health_status['status'] = 'unhealthy'
    except Exception as e:
        health_status['checks']['celery'] = {'status': 'unhealthy', 'error': str(e)}
        health_status['status'] = 'unhealthy'

    return jsonify(health_status)
```

## 🔄 Background Jobs

### Task Definitions
```python
# tasks.py
from celery import Celery
from app import create_app, db
from models.credit import CreditScore
from services.compliance_service import ComplianceService

celery = Celery(__name__)

@celery.task(bind=True, max_retries=3)
def calculate_credit_score(self, user_id):
    try:
        app = create_app()
        with app.app_context():
            # Credit score calculation logic
            user = User.query.get(user_id)
            if not user:
                raise ValueError(f"User {user_id} not found")

            # Perform calculation
            score = perform_credit_calculation(user)

            # Save to database
            credit_score = CreditScore(
                user_id=user_id,
                score=score,
                calculated_at=datetime.utcnow()
            )
            db.session.add(credit_score)
            db.session.commit()

            return {'user_id': user_id, 'score': score}

    except Exception as exc:
        self.retry(countdown=60, exc=exc)

@celery.task
def perform_compliance_check(user_id):
    app = create_app()
    with app.app_context():
        compliance_service = ComplianceService()
        result = compliance_service.perform_aml_screening(user_id)
        return result

@celery.task
def send_notification_email(user_id, template, context):
    app = create_app()
    with app.app_context():
        user = User.query.get(user_id)
        if user:
            send_email(user.email, template, context)
```

### Task Scheduling
```python
# Beat schedule for periodic tasks
from celery.schedules import crontab

celery.conf.beat_schedule = {
    'daily-compliance-check': {
        'task': 'app.tasks.daily_compliance_check',
        'schedule': crontab(hour=2, minute=0),  # Run at 2 AM daily
    },
    'weekly-credit-score-update': {
        'task': 'app.tasks.update_credit_scores',
        'schedule': crontab(hour=3, minute=0, day_of_week=1),  # Run Monday at 3 AM
    },
    'monthly-audit-report': {
        'task': 'app.tasks.generate_audit_report',
        'schedule': crontab(hour=1, minute=0, day_of_month=1),  # First day of month at 1 AM
    },
}
```

## 🧪 Advanced Testing

### Test Configuration
```python
# conftest.py
import pytest
from app import create_app, db
from models.user import User

@pytest.fixture(scope='session')
def app():
    app = create_app('testing')
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()

@pytest.fixture
def client(app):
    return app.test_client()

@pytest.fixture
def auth_headers(app):
    with app.app_context():
        user = User(email='test@example.com')
        user.set_password('password123')
        db.session.add(user)
        db.session.commit()

        token = user.generate_auth_token()
        return {'Authorization': f'Bearer {token}'}

@pytest.fixture
def mock_blockchain_service():
    with patch('services.blockchain_service.BlockchainService') as mock:
        yield mock
```

### Integration Tests
```python
# test_integration.py
def test_complete_loan_application_flow(client, auth_headers):
    # Step 1: Submit loan application
    loan_data = {
        'amount': 50000,
        'purpose': 'home_improvement',
        'term_months': 60
    }

    response = client.post('/api/loans/apply',
                          json=loan_data,
                          headers=auth_headers)
    assert response.status_code == 201
    application_id = response.json['application_id']

    # Step 2: Check application status
    response = client.get(f'/api/loans/applications/{application_id}',
                         headers=auth_headers)
    assert response.status_code == 200
    assert response.json['status'] == 'submitted'

    # Step 3: Simulate approval process
    # This would typically be done by an admin or automated process
    response = client.put(f'/api/admin/loans/{application_id}/approve',
                         headers=auth_headers)
    assert response.status_code == 200

    # Step 4: Verify final status
    response = client.get(f'/api/loans/applications/{application_id}',
                         headers=auth_headers)
    assert response.status_code == 200
    assert response.json['status'] == 'approved'
```

### Performance Tests
```python
# test_performance.py
import time
import concurrent.futures

def test_api_response_time(client, auth_headers):
    start_time = time.time()
    response = client.get('/api/user/profile', headers=auth_headers)
    end_time = time.time()

    assert response.status_code == 200
    assert (end_time - start_time) < 0.5  # Should respond within 500ms

def test_concurrent_requests(client, auth_headers):
    def make_request():
        return client.get('/api/user/profile', headers=auth_headers)

    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(make_request) for _ in range(50)]
        results = [future.result() for future in concurrent.futures.as_completed(futures)]

    # All requests should succeed
    assert all(result.status_code == 200 for result in results)
```

## 📋 Compliance & Audit

### Audit Trail Implementation
```python
# audit_service.py
class AuditService:
    @staticmethod
    def log_event(user_id, event_type, event_data, ip_address=None, user_agent=None):
        audit_log = AuditLog(
            user_id=user_id,
            event_type=event_type,
            event_data=event_data,
            ip_address=ip_address,
            user_agent=user_agent,
            timestamp=datetime.utcnow()
        )
        db.session.add(audit_log)
        db.session.commit()

    @staticmethod
    def get_user_audit_trail(user_id, start_date=None, end_date=None):
        query = AuditLog.query.filter_by(user_id=user_id)

        if start_date:
            query = query.filter(AuditLog.timestamp >= start_date)
        if end_date:
            query = query.filter(AuditLog.timestamp <= end_date)

        return query.order_by(AuditLog.timestamp.desc()).all()
```

### Compliance Reporting
```python
# compliance_reporting.py
class ComplianceReporter:
    def generate_kyc_report(self, start_date, end_date):
        kyc_verifications = KYCVerification.query.filter(
            KYCVerification.created_at.between(start_date, end_date)
        ).all()

        report = {
            'period': {'start': start_date, 'end': end_date},
            'total_verifications': len(kyc_verifications),
            'approved': len([v for v in kyc_verifications if v.status == 'approved']),
            'rejected': len([v for v in kyc_verifications if v.status == 'rejected']),
            'pending': len([v for v in kyc_verifications if v.status == 'pending']),
            'approval_rate': 0
        }

        if report['total_verifications'] > 0:
            report['approval_rate'] = report['approved'] / report['total_verifications']

        return report

    def generate_transaction_monitoring_report(self, start_date, end_date):
        transactions = Transaction.query.filter(
            Transaction.created_at.between(start_date, end_date)
        ).all()

        suspicious_transactions = [t for t in transactions if t.risk_score > 0.7]

        return {
            'period': {'start': start_date, 'end': end_date},
            'total_transactions': len(transactions),
            'suspicious_transactions': len(suspicious_transactions),
            'total_volume': sum(t.amount for t in transactions),
            'suspicious_volume': sum(t.amount for t in suspicious_transactions),
            'alert_rate': len(suspicious_transactions) / len(transactions) if transactions else 0
        }
```

## 🚀 Production Deployment

### Docker Configuration
```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
RUN chown -R app:app /app
USER app

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/api/health || exit 1

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--timeout", "120", "app:app"]
```

### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/blockscore
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - ./logs:/app/logs

  db:
    image: postgres:14
    environment:
      - POSTGRES_DB=blockscore
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  celery:
    build: .
    command: celery -A app.celery worker --loglevel=info
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/blockscore
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis

  celery-beat:
    build: .
    command: celery -A app.celery beat --loglevel=info
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/blockscore
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis

volumes:
  postgres_data:
  redis_data:
```

### Kubernetes Deployment
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blockscore-backend
  labels:
    app: blockscore-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: blockscore-backend
  template:
    metadata:
      labels:
        app: blockscore-backend
    spec:
      containers:
      - name: backend
        image: blockscore-backend:latest
        ports:
        - containerPort: 5000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: blockscore-secrets
              key: database-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: blockscore-secrets
              key: redis-url
        livenessProbe:
          httpGet:
            path: /api/health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: blockscore-backend-service
spec:
  selector:
    app: blockscore-backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
  type: LoadBalancer
```

This comprehensive documentation provides everything needed to understand, deploy, and maintain the BlockScore backend system in a production environment.

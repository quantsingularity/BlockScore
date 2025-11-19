"""
Pytest configuration and shared fixtures for BlockScore Backend tests
"""

import os
# Import application components
import sys
import tempfile
from datetime import datetime, timezone
from unittest.mock import Mock

import pytest
import redis

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import create_app
from models import db as _db
from models.audit import AuditLog
from models.credit import CreditScore
from models.loan import LoanApplication
from models.user import User, UserProfile
from services.auth_service import AuthenticationService
from services.blockchain_service import BlockchainService
from services.compliance_service import ComplianceService
from services.credit_service import CreditScoringService
from utils.cache import CacheManager
from utils.monitoring import PerformanceMonitor


@pytest.fixture(scope="session")
def app():
    """Create application for testing"""
    # Create temporary database file
    db_fd, db_path = tempfile.mkstemp()

    config = {
        "TESTING": True,
        "SQLALCHEMY_DATABASE_URI": f"sqlite:///{db_path}",
        "SQLALCHEMY_TRACK_MODIFICATIONS": False,
        "SECRET_KEY": "test-secret-key",
        "JWT_SECRET_KEY": "test-jwt-secret",
        "REDIS_URL": "redis://localhost:6379/15",  # Use test database
        "WTF_CSRF_ENABLED": False,
        "BCRYPT_LOG_ROUNDS": 4,  # Faster for testing
    }

    app = create_app(config)

    with app.app_context():
        _db.create_all()
        yield app
        _db.drop_all()

    os.close(db_fd)
    os.unlink(db_path)


@pytest.fixture(scope="function")
def db(app):
    """Create database for testing"""
    with app.app_context():
        _db.create_all()
        yield _db
        _db.session.rollback()
        _db.drop_all()


@pytest.fixture(scope="function")
def client(app):
    """Create test client"""
    return app.test_client()


@pytest.fixture(scope="function")
def runner(app):
    """Create test CLI runner"""
    return app.test_cli_runner()


@pytest.fixture
def mock_redis():
    """Mock Redis client"""
    mock_client = Mock(spec=redis.Redis)
    mock_client.ping.return_value = True
    mock_client.get.return_value = None
    mock_client.set.return_value = True
    mock_client.delete.return_value = 1
    mock_client.exists.return_value = False
    mock_client.expire.return_value = True
    mock_client.ttl.return_value = 3600
    mock_client.keys.return_value = []
    mock_client.mget.return_value = []
    mock_client.incr.return_value = 1
    mock_client.decr.return_value = 0
    return mock_client


@pytest.fixture
def cache_manager(mock_redis):
    """Create cache manager with mock Redis"""
    return CacheManager(redis_client=mock_redis)


@pytest.fixture
def performance_monitor():
    """Create performance monitor"""
    return PerformanceMonitor(retention_hours=1)


@pytest.fixture
def sample_user_data():
    """Sample user data for testing"""
    return {
        "email": "test@example.com",
        "password": "TestPassword123!",
        "first_name": "John",
        "last_name": "Doe",
        "date_of_birth": "1990-01-01",
        "phone_number": "+1234567890",
        "address_line1": "123 Test Street",
        "city": "Test City",
        "state": "TS",
        "postal_code": "12345",
        "country": "US",
    }


@pytest.fixture
def sample_user(db, sample_user_data):
    """Create sample user in database"""
    user = User(
        email=sample_user_data["email"],
        password_hash="hashed_password",
        is_active=True,
        email_verified=True,
    )

    profile = UserProfile(
        user=user,
        first_name=sample_user_data["first_name"],
        last_name=sample_user_data["last_name"],
        date_of_birth=datetime.strptime(
            sample_user_data["date_of_birth"], "%Y-%m-%d"
        ).date(),
        phone_number=sample_user_data["phone_number"],
        address_line1=sample_user_data["address_line1"],
        city=sample_user_data["city"],
        state=sample_user_data["state"],
        postal_code=sample_user_data["postal_code"],
        country=sample_user_data["country"],
    )

    db.session.add(user)
    db.session.add(profile)
    db.session.commit()

    return user


@pytest.fixture
def sample_credit_score(db, sample_user):
    """Create sample credit score"""
    credit_score = CreditScore(
        user_id=sample_user.id,
        score=750,
        score_version="v2.0",
        factors_positive=["payment_history", "credit_utilization"],
        factors_negative=["credit_age"],
        calculated_at=datetime.now(timezone.utc),
    )

    db.session.add(credit_score)
    db.session.commit()

    return credit_score


@pytest.fixture
def sample_loan_application(db, sample_user):
    """Create sample loan application"""
    loan_app = LoanApplication(
        user_id=sample_user.id,
        loan_type="personal",
        requested_amount=10000.00,
        requested_term_months=36,
        requested_rate=12.5,
        purpose="debt_consolidation",
        employment_status="employed",
        annual_income=75000.00,
        monthly_expenses=3000.00,
    )

    db.session.add(loan_app)
    db.session.commit()

    return loan_app


@pytest.fixture
def auth_service(db):
    """Create authentication service"""
    return AuthenticationService(db)


@pytest.fixture
def credit_service(db, mock_redis):
    """Create credit scoring service"""
    cache_manager = CacheManager(redis_client=mock_redis)
    return CreditScoringService(db, cache_manager)


@pytest.fixture
def compliance_service(db):
    """Create compliance service"""
    return ComplianceService(db)


@pytest.fixture
def mock_blockchain_config():
    """Mock blockchain configuration"""
    return {
        "BLOCKCHAIN_PROVIDER_URL": "http://localhost:8545",
        "BLOCKCHAIN_FROM_ADDRESS": "0x1234567890123456789012345678901234567890",
        "BLOCKCHAIN_PRIVATE_KEY": "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
        "CREDIT_SCORE_CONTRACT_ADDRESS": "0x1111111111111111111111111111111111111111",
        "LOAN_AGREEMENT_CONTRACT_ADDRESS": "0x2222222222222222222222222222222222222222",
        "IDENTITY_REGISTRY_CONTRACT_ADDRESS": "0x3333333333333333333333333333333333333333",
        "PAYMENT_PROCESSOR_CONTRACT_ADDRESS": "0x4444444444444444444444444444444444444444",
    }


@pytest.fixture
def blockchain_service(mock_blockchain_config):
    """Create blockchain service with mock configuration"""
    service = BlockchainService(mock_blockchain_config)
    # Mock Web3 connection
    service.web3 = Mock()
    service.is_connected_flag = True
    return service


# Utility functions for tests
def create_test_audit_log(db, user_id, event_type="user_login", severity="info"):
    """Create test audit log entry"""
    audit_log = AuditLog(
        user_id=user_id,
        event_type=event_type,
        severity=severity,
        description=f"Test {event_type} event",
        ip_address="127.0.0.1",
        user_agent="Test Agent",
        additional_data={"test": True},
    )

    db.session.add(audit_log)
    db.session.commit()

    return audit_log


# Pytest configuration
def pytest_configure(config):
    """Configure pytest"""
    config.addinivalue_line("markers", "unit: mark test as a unit test")
    config.addinivalue_line("markers", "integration: mark test as an integration test")
    config.addinivalue_line("markers", "slow: mark test as slow running")
    config.addinivalue_line(
        "markers", "external: mark test as requiring external services"
    )

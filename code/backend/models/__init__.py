"""
Database models package for BlockScore Backend
"""

from flask_marshmallow import Marshmallow
from flask_sqlalchemy import SQLAlchemy

# Initialize extensions
db = SQLAlchemy()
ma = Marshmallow()

from .audit import AuditLog, ComplianceRecord
from .blockchain import BlockchainTransaction, SmartContract
from .credit import CreditFactor, CreditHistory, CreditScore
from .loan import Loan, LoanApplication, LoanPayment

# Import all models to ensure they are registered
from .user import User, UserProfile, UserSession

__all__ = [
    "db",
    "ma",
    "User",
    "UserProfile",
    "UserSession",
    "CreditScore",
    "CreditHistory",
    "CreditFactor",
    "Loan",
    "LoanApplication",
    "LoanPayment",
    "AuditLog",
    "ComplianceRecord",
    "BlockchainTransaction",
    "SmartContract",
]

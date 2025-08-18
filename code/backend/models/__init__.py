"""
Database models package for BlockScore Backend
"""
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow

# Initialize extensions
db = SQLAlchemy()
ma = Marshmallow()

# Import all models to ensure they are registered
from .user import User, UserProfile, UserSession
from .credit import CreditScore, CreditHistory, CreditFactor
from .loan import Loan, LoanApplication, LoanPayment
from .audit import AuditLog, ComplianceRecord
from .blockchain import BlockchainTransaction, SmartContract

__all__ = [
    'db', 'ma',
    'User', 'UserProfile', 'UserSession',
    'CreditScore', 'CreditHistory', 'CreditFactor',
    'Loan', 'LoanApplication', 'LoanPayment',
    'AuditLog', 'ComplianceRecord',
    'BlockchainTransaction', 'SmartContract'
]


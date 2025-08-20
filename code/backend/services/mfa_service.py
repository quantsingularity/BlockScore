"""
Multi-Factor Authentication (MFA) Service for Financial Applications
Implements TOTP, SMS, and backup codes for enhanced security
"""
import os
import secrets
import qrcode
import io
import base64
import hashlib
import hmac
import time
from datetime import datetime, timezone, timedelta
from typing import Dict, List, Optional, Any, Tuple
import pyotp
import requests
from PIL import Image

from flask import current_app
from sqlalchemy import and_
from sqlalchemy.orm import Session

from models import db
from models.user import User, UserProfile
from models.audit import AuditLog, AuditEventType, AuditSeverity
from services.audit_service import AuditService


class MFAMethod:
    """MFA method enumeration"""
    TOTP = "totp"
    SMS = "sms"
    EMAIL = "email"
    BACKUP_CODES = "backup_codes"
    HARDWARE_TOKEN = "hardware_token"


class MFAService:
    """Multi-Factor Authentication service for enhanced security"""
    
    def __init__(self, db_session: Session):
        self.db = db_session
        self.audit_service = AuditService(db_session)
        
        # MFA configuration
        self.totp_issuer = "BlockScore"
        self.totp_window = 1  # Allow 1 time step tolerance
        self.backup_codes_count = 10
        self.sms_code_length = 6
        self.sms_code_expiry = 300  # 5 minutes
        self.max_failed_attempts = 3
        self.lockout_duration = 900  # 15 minutes
        
        # External service configuration
        self.sms_provider_url = os.environ.get('SMS_PROVIDER_URL')
        self.sms_api_key = os.environ.get('SMS_API_KEY')
        self.email_service_url = os.environ.get('EMAIL_SERVICE_URL')
        self.email_api_key = os.environ.get('EMAIL_API_KEY')
    
    def setup_totp(self, user_id: int) -> Dict[str, Any]:
        """Set up TOTP (Time-based One-Time Password) for user"""
        try:
            user = User.query.get(user_id)
            if not user:
                raise ValueError("User not found")
            
            # Generate secret key
            secret = pyotp.random_base32()
            
            # Create TOTP object
            totp = pyotp.TOTP(secret)
            
            # Generate provisioning URI for QR code
            provisioning_uri = totp.provisioning_uri(
                name=user.email,
                issuer_name=self.totp_issuer
            )
            
            # Generate QR code
            qr_code_data = self._generate_qr_code(provisioning_uri)
            
            # Store secret in user profile (encrypted)
            if not user.profile:
                user.profile = UserProfile(user_id=user_id)
                self.db.add(user.profile)
            
            # Store encrypted TOTP secret
            user.profile.totp_secret = self._encrypt_secret(secret)
            user.profile.mfa_enabled = False  # Will be enabled after verification
            user.profile.mfa_methods = user.profile.mfa_methods or []
            
            self.db.commit()
            
            # Create audit log
            self.audit_service.log_event(
                event_type=AuditEventType.MFA_SETUP,
                event_description="TOTP setup initiated",
                user_id=user_id,
                event_data={
                    'mfa_method': MFAMethod.TOTP,
                    'setup_stage': 'initiated'
                }
            )
            
            return {
                'success': True,
                'secret': secret,  # Return for manual entry
                'qr_code': qr_code_data,
                'provisioning_uri': provisioning_uri,
                'backup_codes': None  # Will be generated after verification
            }
            
        except Exception as e:
            current_app.logger.error(f"TOTP setup error for user {user_id}: {e}")
            raise
    
    def verify_totp_setup(self, user_id: int, verification_code: str) -> Dict[str, Any]:
        """Verify TOTP setup and enable MFA"""
        try:
            user = User.query.get(user_id)
            if not user or not user.profile or not user.profile.totp_secret:
                raise ValueError("TOTP not set up for user")
            
            # Decrypt secret
            secret = self._decrypt_secret(user.profile.totp_secret)
            
            # Verify code
            totp = pyotp.TOTP(secret)
            if not totp.verify(verification_code, valid_window=self.totp_window):
                # Log failed verification
                self.audit_service.log_event(
                    event_type=AuditEventType.MFA_VERIFICATION,
                    event_description="TOTP setup verification failed",
                    severity=AuditSeverity.MEDIUM,
                    user_id=user_id,
                    event_data={
                        'mfa_method': MFAMethod.TOTP,
                        'verification_result': 'failed'
                    }
                )
                
                return {
                    'success': False,
                    'error': 'Invalid verification code'
                }
            
            # Enable MFA and add TOTP method
            user.profile.mfa_enabled = True
            if MFAMethod.TOTP not in user.profile.mfa_methods:
                user.profile.mfa_methods.append(MFAMethod.TOTP)
            
            # Generate backup codes
            backup_codes = self._generate_backup_codes(user_id)
            
            self.db.commit()
            
            # Create audit log
            self.audit_service.log_event(
                event_type=AuditEventType.MFA_SETUP,
                event_description="TOTP setup completed successfully",
                user_id=user_id,
                event_data={
                    'mfa_method': MFAMethod.TOTP,
                    'setup_stage': 'completed'
                }
            )
            
            return {
                'success': True,
                'mfa_enabled': True,
                'backup_codes': backup_codes,
                'message': 'TOTP authentication enabled successfully'
            }
            
        except Exception as e:
            current_app.logger.error(f"TOTP verification error for user {user_id}: {e}")
            raise
    
    def setup_sms_mfa(self, user_id: int, phone_number: str) -> Dict[str, Any]:
        """Set up SMS-based MFA"""
        try:
            user = User.query.get(user_id)
            if not user:
                raise ValueError("User not found")
            
            # Validate phone number format
            if not self._validate_phone_number(phone_number):
                return {
                    'success': False,
                    'error': 'Invalid phone number format'
                }
            
            # Generate verification code
            verification_code = self._generate_sms_code()
            
            # Store phone number and verification code temporarily
            if not user.profile:
                user.profile = UserProfile(user_id=user_id)
                self.db.add(user.profile)
            
            # Store encrypted phone number and verification code
            user.profile.phone_number = self._encrypt_secret(phone_number)
            user.profile.sms_verification_code = self._encrypt_secret(verification_code)
            user.profile.sms_code_expires_at = datetime.now(timezone.utc) + timedelta(seconds=self.sms_code_expiry)
            
            self.db.commit()
            
            # Send SMS
            sms_sent = self._send_sms(phone_number, f"Your BlockScore verification code is: {verification_code}")
            
            if not sms_sent:
                return {
                    'success': False,
                    'error': 'Failed to send SMS verification code'
                }
            
            # Create audit log
            self.audit_service.log_event(
                event_type=AuditEventType.MFA_SETUP,
                event_description="SMS MFA setup initiated",
                user_id=user_id,
                event_data={
                    'mfa_method': MFAMethod.SMS,
                    'phone_number_masked': self._mask_phone_number(phone_number)
                }
            )
            
            return {
                'success': True,
                'message': 'Verification code sent to your phone',
                'phone_number_masked': self._mask_phone_number(phone_number)
            }
            
        except Exception as e:
            current_app.logger.error(f"SMS MFA setup error for user {user_id}: {e}")
            raise
    
    def verify_sms_setup(self, user_id: int, verification_code: str) -> Dict[str, Any]:
        """Verify SMS setup and enable SMS MFA"""
        try:
            user = User.query.get(user_id)
            if not user or not user.profile:
                raise ValueError("User or profile not found")
            
            # Check if verification code exists and is not expired
            if not user.profile.sms_verification_code or not user.profile.sms_code_expires_at:
                return {
                    'success': False,
                    'error': 'No pending SMS verification'
                }
            
            if datetime.now(timezone.utc) > user.profile.sms_code_expires_at:
                return {
                    'success': False,
                    'error': 'Verification code expired'
                }
            
            # Decrypt and verify code
            stored_code = self._decrypt_secret(user.profile.sms_verification_code)
            if verification_code != stored_code:
                # Log failed verification
                self.audit_service.log_event(
                    event_type=AuditEventType.MFA_VERIFICATION,
                    event_description="SMS setup verification failed",
                    severity=AuditSeverity.MEDIUM,
                    user_id=user_id,
                    event_data={
                        'mfa_method': MFAMethod.SMS,
                        'verification_result': 'failed'
                    }
                )
                
                return {
                    'success': False,
                    'error': 'Invalid verification code'
                }
            
            # Enable SMS MFA
            user.profile.mfa_enabled = True
            if MFAMethod.SMS not in (user.profile.mfa_methods or []):
                user.profile.mfa_methods = (user.profile.mfa_methods or []) + [MFAMethod.SMS]
            
            # Clear temporary verification data
            user.profile.sms_verification_code = None
            user.profile.sms_code_expires_at = None
            
            self.db.commit()
            
            # Create audit log
            self.audit_service.log_event(
                event_type=AuditEventType.MFA_SETUP,
                event_description="SMS MFA setup completed successfully",
                user_id=user_id,
                event_data={
                    'mfa_method': MFAMethod.SMS,
                    'setup_stage': 'completed'
                }
            )
            
            return {
                'success': True,
                'mfa_enabled': True,
                'message': 'SMS authentication enabled successfully'
            }
            
        except Exception as e:
            current_app.logger.error(f"SMS verification error for user {user_id}: {e}")
            raise
    
    def verify_mfa(self, user_id: int, method: str, code: str, 
                   backup_code: Optional[str] = None) -> Dict[str, Any]:
        """Verify MFA code during authentication"""
        try:
            user = User.query.get(user_id)
            if not user or not user.profile:
                raise ValueError("User or profile not found")
            
            if not user.profile.mfa_enabled:
                return {
                    'success': False,
                    'error': 'MFA not enabled for user'
                }
            
            # Check for account lockout
            if self._is_mfa_locked(user_id):
                return {
                    'success': False,
                    'error': 'Account temporarily locked due to failed MFA attempts'
                }
            
            verification_result = False
            
            # Try backup code first if provided
            if backup_code:
                verification_result = self._verify_backup_code(user_id, backup_code)
                method = MFAMethod.BACKUP_CODES
            elif method == MFAMethod.TOTP:
                verification_result = self._verify_totp_code(user_id, code)
            elif method == MFAMethod.SMS:
                verification_result = self._verify_sms_code(user_id, code)
            else:
                return {
                    'success': False,
                    'error': 'Unsupported MFA method'
                }
            
            if verification_result:
                # Reset failed attempts
                self._reset_mfa_failed_attempts(user_id)
                
                # Create audit log
                self.audit_service.log_event(
                    event_type=AuditEventType.MFA_VERIFICATION,
                    event_description=f"MFA verification successful using {method}",
                    user_id=user_id,
                    event_data={
                        'mfa_method': method,
                        'verification_result': 'success'
                    }
                )
                
                return {
                    'success': True,
                    'method_used': method,
                    'message': 'MFA verification successful'
                }
            else:
                # Increment failed attempts
                self._increment_mfa_failed_attempts(user_id)
                
                # Create audit log
                self.audit_service.log_event(
                    event_type=AuditEventType.MFA_VERIFICATION,
                    event_description=f"MFA verification failed using {method}",
                    severity=AuditSeverity.MEDIUM,
                    user_id=user_id,
                    event_data={
                        'mfa_method': method,
                        'verification_result': 'failed'
                    }
                )
                
                return {
                    'success': False,
                    'error': 'Invalid MFA code'
                }
                
        except Exception as e:
            current_app.logger.error(f"MFA verification error for user {user_id}: {e}")
            raise
    
    def send_sms_code(self, user_id: int) -> Dict[str, Any]:
        """Send SMS verification code for authentication"""
        try:
            user = User.query.get(user_id)
            if not user or not user.profile:
                raise ValueError("User or profile not found")
            
            if MFAMethod.SMS not in (user.profile.mfa_methods or []):
                return {
                    'success': False,
                    'error': 'SMS MFA not enabled for user'
                }
            
            # Check rate limiting
            if self._is_sms_rate_limited(user_id):
                return {
                    'success': False,
                    'error': 'SMS rate limit exceeded. Please try again later.'
                }
            
            # Generate and send code
            verification_code = self._generate_sms_code()
            phone_number = self._decrypt_secret(user.profile.phone_number)
            
            # Store verification code
            user.profile.sms_verification_code = self._encrypt_secret(verification_code)
            user.profile.sms_code_expires_at = datetime.now(timezone.utc) + timedelta(seconds=self.sms_code_expiry)
            
            self.db.commit()
            
            # Send SMS
            sms_sent = self._send_sms(phone_number, f"Your BlockScore login code is: {verification_code}")
            
            if not sms_sent:
                return {
                    'success': False,
                    'error': 'Failed to send SMS code'
                }
            
            # Update rate limiting
            self._update_sms_rate_limit(user_id)
            
            return {
                'success': True,
                'message': 'SMS code sent successfully',
                'expires_in': self.sms_code_expiry
            }
            
        except Exception as e:
            current_app.logger.error(f"SMS code sending error for user {user_id}: {e}")
            raise
    
    def disable_mfa(self, user_id: int, method: Optional[str] = None) -> Dict[str, Any]:
        """Disable MFA for user (specific method or all)"""
        try:
            user = User.query.get(user_id)
            if not user or not user.profile:
                raise ValueError("User or profile not found")
            
            if method:
                # Disable specific method
                if user.profile.mfa_methods and method in user.profile.mfa_methods:
                    user.profile.mfa_methods.remove(method)
                    
                    # Clear method-specific data
                    if method == MFAMethod.TOTP:
                        user.profile.totp_secret = None
                    elif method == MFAMethod.SMS:
                        user.profile.phone_number = None
                        user.profile.sms_verification_code = None
                        user.profile.sms_code_expires_at = None
                    
                    # If no methods left, disable MFA entirely
                    if not user.profile.mfa_methods:
                        user.profile.mfa_enabled = False
                        user.profile.backup_codes = None
                
            else:
                # Disable all MFA
                user.profile.mfa_enabled = False
                user.profile.mfa_methods = []
                user.profile.totp_secret = None
                user.profile.phone_number = None
                user.profile.sms_verification_code = None
                user.profile.sms_code_expires_at = None
                user.profile.backup_codes = None
            
            self.db.commit()
            
            # Create audit log
            self.audit_service.log_event(
                event_type=AuditEventType.MFA_DISABLED,
                event_description=f"MFA disabled: {method or 'all methods'}",
                severity=AuditSeverity.MEDIUM,
                user_id=user_id,
                event_data={
                    'disabled_method': method or 'all',
                    'remaining_methods': user.profile.mfa_methods or []
                }
            )
            
            return {
                'success': True,
                'message': f'MFA {method or "completely"} disabled successfully',
                'mfa_enabled': user.profile.mfa_enabled,
                'active_methods': user.profile.mfa_methods or []
            }
            
        except Exception as e:
            current_app.logger.error(f"MFA disable error for user {user_id}: {e}")
            raise
    
    def get_mfa_status(self, user_id: int) -> Dict[str, Any]:
        """Get MFA status and available methods for user"""
        try:
            user = User.query.get(user_id)
            if not user or not user.profile:
                return {
                    'mfa_enabled': False,
                    'available_methods': [],
                    'backup_codes_remaining': 0
                }
            
            # Count remaining backup codes
            backup_codes_remaining = 0
            if user.profile.backup_codes:
                backup_codes = self._decrypt_secret(user.profile.backup_codes)
                backup_codes_list = backup_codes.split(',') if backup_codes else []
                backup_codes_remaining = len([code for code in backup_codes_list if code.strip()])
            
            return {
                'mfa_enabled': user.profile.mfa_enabled or False,
                'available_methods': user.profile.mfa_methods or [],
                'backup_codes_remaining': backup_codes_remaining,
                'phone_number_masked': self._mask_phone_number(
                    self._decrypt_secret(user.profile.phone_number)
                ) if user.profile.phone_number else None
            }
            
        except Exception as e:
            current_app.logger.error(f"MFA status error for user {user_id}: {e}")
            return {
                'mfa_enabled': False,
                'available_methods': [],
                'backup_codes_remaining': 0
            }
    
    def regenerate_backup_codes(self, user_id: int) -> Dict[str, Any]:
        """Regenerate backup codes for user"""
        try:
            user = User.query.get(user_id)
            if not user or not user.profile or not user.profile.mfa_enabled:
                raise ValueError("MFA not enabled for user")
            
            # Generate new backup codes
            backup_codes = self._generate_backup_codes(user_id)
            
            # Create audit log
            self.audit_service.log_event(
                event_type=AuditEventType.MFA_BACKUP_CODES_REGENERATED,
                event_description="Backup codes regenerated",
                user_id=user_id,
                event_data={
                    'codes_count': len(backup_codes)
                }
            )
            
            return {
                'success': True,
                'backup_codes': backup_codes,
                'message': 'New backup codes generated successfully'
            }
            
        except Exception as e:
            current_app.logger.error(f"Backup codes regeneration error for user {user_id}: {e}")
            raise
    
    def _generate_qr_code(self, data: str) -> str:
        """Generate QR code as base64 encoded image"""
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(data)
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Convert to base64
        buffer = io.BytesIO()
        img.save(buffer, format='PNG')
        buffer.seek(0)
        
        return base64.b64encode(buffer.getvalue()).decode()
    
    def _encrypt_secret(self, secret: str) -> str:
        """Encrypt sensitive data"""
        # In production, use proper encryption with a key management system
        key = os.environ.get('MFA_ENCRYPTION_KEY', 'default_key_change_in_production')
        return base64.b64encode(
            hmac.new(key.encode(), secret.encode(), hashlib.sha256).digest()
        ).decode() + ':' + base64.b64encode(secret.encode()).decode()
    
    def _decrypt_secret(self, encrypted_secret: str) -> str:
        """Decrypt sensitive data"""
        try:
            parts = encrypted_secret.split(':')
            if len(parts) != 2:
                raise ValueError("Invalid encrypted data format")
            
            return base64.b64decode(parts[1]).decode()
        except Exception:
            raise ValueError("Failed to decrypt secret")
    
    def _generate_backup_codes(self, user_id: int) -> List[str]:
        """Generate backup codes for user"""
        codes = []
        for _ in range(self.backup_codes_count):
            code = ''.join([str(secrets.randbelow(10)) for _ in range(8)])
            codes.append(f"{code[:4]}-{code[4:]}")
        
        # Store encrypted backup codes
        user = User.query.get(user_id)
        user.profile.backup_codes = self._encrypt_secret(','.join(codes))
        self.db.commit()
        
        return codes
    
    def _generate_sms_code(self) -> str:
        """Generate SMS verification code"""
        return ''.join([str(secrets.randbelow(10)) for _ in range(self.sms_code_length)])
    
    def _validate_phone_number(self, phone_number: str) -> bool:
        """Validate phone number format"""
        # Basic validation - in production, use a proper phone number validation library
        import re
        pattern = r'^\+?1?[2-9]\d{2}[2-9]\d{2}\d{4}$'
        return bool(re.match(pattern, phone_number.replace('-', '').replace(' ', '')))
    
    def _mask_phone_number(self, phone_number: str) -> str:
        """Mask phone number for display"""
        if not phone_number or len(phone_number) < 4:
            return "****"
        return f"****{phone_number[-4:]}"
    
    def _send_sms(self, phone_number: str, message: str) -> bool:
        """Send SMS message"""
        try:
            if not self.sms_provider_url or not self.sms_api_key:
                current_app.logger.warning("SMS service not configured")
                return False
            
            headers = {
                'Authorization': f'Bearer {self.sms_api_key}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'to': phone_number,
                'message': message
            }
            
            response = requests.post(
                self.sms_provider_url,
                json=payload,
                headers=headers,
                timeout=10
            )
            
            return response.status_code == 200
            
        except Exception as e:
            current_app.logger.error(f"SMS sending error: {e}")
            return False
    
    def _verify_totp_code(self, user_id: int, code: str) -> bool:
        """Verify TOTP code"""
        try:
            user = User.query.get(user_id)
            if not user.profile.totp_secret:
                return False
            
            secret = self._decrypt_secret(user.profile.totp_secret)
            totp = pyotp.TOTP(secret)
            
            return totp.verify(code, valid_window=self.totp_window)
            
        except Exception as e:
            current_app.logger.error(f"TOTP verification error: {e}")
            return False
    
    def _verify_sms_code(self, user_id: int, code: str) -> bool:
        """Verify SMS code"""
        try:
            user = User.query.get(user_id)
            if not user.profile.sms_verification_code or not user.profile.sms_code_expires_at:
                return False
            
            if datetime.now(timezone.utc) > user.profile.sms_code_expires_at:
                return False
            
            stored_code = self._decrypt_secret(user.profile.sms_verification_code)
            return code == stored_code
            
        except Exception as e:
            current_app.logger.error(f"SMS verification error: {e}")
            return False
    
    def _verify_backup_code(self, user_id: int, code: str) -> bool:
        """Verify and consume backup code"""
        try:
            user = User.query.get(user_id)
            if not user.profile.backup_codes:
                return False
            
            backup_codes = self._decrypt_secret(user.profile.backup_codes)
            codes_list = backup_codes.split(',')
            
            if code in codes_list:
                # Remove used code
                codes_list.remove(code)
                user.profile.backup_codes = self._encrypt_secret(','.join(codes_list))
                self.db.commit()
                return True
            
            return False
            
        except Exception as e:
            current_app.logger.error(f"Backup code verification error: {e}")
            return False
    
    def _is_mfa_locked(self, user_id: int) -> bool:
        """Check if user is locked due to failed MFA attempts"""
        # This would typically be stored in Redis or database
        # For now, return False (implement based on your caching strategy)
        return False
    
    def _increment_mfa_failed_attempts(self, user_id: int):
        """Increment failed MFA attempts counter"""
        # Implement based on your caching/storage strategy
        pass
    
    def _reset_mfa_failed_attempts(self, user_id: int):
        """Reset failed MFA attempts counter"""
        # Implement based on your caching/storage strategy
        pass
    
    def _is_sms_rate_limited(self, user_id: int) -> bool:
        """Check if SMS sending is rate limited for user"""
        # Implement rate limiting logic
        return False
    
    def _update_sms_rate_limit(self, user_id: int):
        """Update SMS rate limiting counter"""
        # Implement rate limiting logic
        pass


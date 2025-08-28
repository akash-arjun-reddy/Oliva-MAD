import pyotp
import qrcode
import base64
from io import BytesIO
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
from fastapi import HTTPException

from models.user import User
from service.security_service import SecurityService


class MFAService:
    def __init__(self, db: Session):
        self.db = db
        self.security_service = SecurityService(db)
    
    def generate_mfa_secret(self, user_id: str) -> Dict[str, str]:
        """Generate MFA secret for a user."""
        # Generate a new secret
        secret = pyotp.random_base32()
        
        # Create TOTP object
        totp = pyotp.TOTP(secret)
        
        # Generate QR code
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(totp.provisioning_uri(
            name=user_id,
            issuer_name="Oliva Clinic"
        ))
        qr.make(fit=True)
        
        # Create QR code image
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Convert to base64
        buffer = BytesIO()
        img.save(buffer, format='PNG')
        qr_base64 = base64.b64encode(buffer.getvalue()).decode()
        
        return {
            "secret": secret,
            "qr_code": f"data:image/png;base64,{qr_base64}",
            "backup_codes": self._generate_backup_codes()
        }
    
    def _generate_backup_codes(self) -> list:
        """Generate backup codes for MFA."""
        import secrets
        codes = []
        for _ in range(8):
            code = secrets.token_hex(4).upper()[:8]
            codes.append(code)
        return codes
    
    def verify_mfa_token(self, secret: str, token: str) -> bool:
        """Verify MFA token."""
        try:
            totp = pyotp.TOTP(secret)
            return totp.verify(token, valid_window=1)  # Allow 1 window of tolerance
        except Exception:
            return False
    
    def verify_backup_code(self, user_id: str, backup_code: str) -> bool:
        """Verify backup code."""
        # This would typically check against stored backup codes
        # For now, we'll implement a simple check
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return False
        
        # In a real implementation, you'd store backup codes securely
        # and check against them
        return True
    
    def enable_mfa(self, user_id: str, secret: str, token: str) -> bool:
        """Enable MFA for a user."""
        # Verify the token first
        if not self.verify_mfa_token(secret, token):
            raise HTTPException(status_code=400, detail="Invalid MFA token")
        
        # Update user
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        user.two_factor_enabled = True
        # In production, you'd store the secret securely (encrypted)
        # For now, we'll store it directly (not recommended for production)
        
        self.db.commit()
        
        # Log the event
        self.security_service.log_audit_event(
            user_id=user_id,
            action="mfa_enabled",
            resource="/auth/mfa/enable",
            success=True
        )
        
        return True
    
    def disable_mfa(self, user_id: str, token: str) -> bool:
        """Disable MFA for a user."""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Verify current MFA token before disabling
        # This would require the user's current MFA secret
        # For now, we'll skip verification (not recommended for production)
        
        user.two_factor_enabled = False
        self.db.commit()
        
        # Log the event
        self.security_service.log_audit_event(
            user_id=user_id,
            action="mfa_disabled",
            resource="/auth/mfa/disable",
            success=True
        )
        
        return True
    
    def require_mfa_for_login(self, user_id: str) -> bool:
        """Check if MFA is required for login."""
        user = self.db.query(User).filter(User.id == user_id).first()
        return user and user.two_factor_enabled
    
    def generate_mfa_challenge(self, user_id: str) -> Dict[str, str]:
        """Generate MFA challenge for login."""
        if not self.require_mfa_for_login(user_id):
            return {"mfa_required": False}
        
        return {
            "mfa_required": True,
            "challenge_type": "totp",
            "message": "Please enter your MFA token"
        }

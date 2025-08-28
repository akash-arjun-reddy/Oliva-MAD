from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from datetime import datetime, timedelta
from typing import Optional, Dict, Any, List
import hashlib
import secrets
import json
from jose import jwt, JWTError
from fastapi import HTTPException, Request

from models.auth_models import RefreshToken, EnhancedUserSession, AuditLog, RateLimitLog, SessionStatus
from models.user import User
from config.settings import settings


class SecurityService:
    def __init__(self, db: Session):
        self.db = db
        self.REFRESH_TOKEN_EXPIRE_DAYS = 30
        self.ACCESS_TOKEN_EXPIRE_MINUTES = 15  # Shorter for security
        self.SESSION_EXPIRE_DAYS = 7
        
    def _hash_token(self, token: str) -> str:
        """Hash token for secure storage."""
        return hashlib.sha256(token.encode()).hexdigest()
    
    def _generate_refresh_token(self) -> str:
        """Generate a secure refresh token."""
        return secrets.token_urlsafe(64)
    
    def _create_access_token(self, user_id: str, expires_minutes: int = None) -> str:
        """Create a short-lived access token."""
        if expires_minutes is None:
            expires_minutes = self.ACCESS_TOKEN_EXPIRE_MINUTES
            
        payload = {
            "sub": user_id,
            "type": "access",
            "exp": datetime.utcnow() + timedelta(minutes=expires_minutes),
            "iat": datetime.utcnow()
        }
        return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    
    def create_refresh_token(self, user_id: int, device_info: str = None, 
                           ip_address: str = None, user_agent: str = None) -> Dict[str, str]:
        """Create refresh token and store it securely."""
        # Generate tokens
        refresh_token = self._generate_refresh_token()
        access_token = self._create_access_token(user_id)
        
        # Hash refresh token for storage
        token_hash = self._hash_token(refresh_token)
        
        # Store refresh token
        db_refresh_token = RefreshToken(
            user_id=user_id,
            token_hash=token_hash,
            expires_at=datetime.utcnow() + timedelta(days=self.REFRESH_TOKEN_EXPIRE_DAYS),
            device_info=device_info,
            ip_address=ip_address,
            user_agent=user_agent
        )
        
        self.db.add(db_refresh_token)
        self.db.commit()
        self.db.refresh(db_refresh_token)
        
        # Create session
        session = EnhancedUserSession(
            user_id=user_id,
            session_id=secrets.token_urlsafe(32),
            refresh_token_id=db_refresh_token.id,
            expires_at=datetime.utcnow() + timedelta(days=self.SESSION_EXPIRE_DAYS),
            device_info=device_info,
            ip_address=ip_address,
            user_agent=user_agent
        )
        
        self.db.add(session)
        self.db.commit()
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "expires_in": self.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "session_id": session.session_id
        }
    
    def refresh_access_token(self, refresh_token: str, user_id: int = None) -> Dict[str, str]:
        """Refresh access token using refresh token."""
        token_hash = self._hash_token(refresh_token)
        
        # Find refresh token
        db_refresh_token = self.db.query(RefreshToken).filter(
            and_(
                RefreshToken.token_hash == token_hash,
                RefreshToken.expires_at > datetime.utcnow(),
                RefreshToken.revoked_at.is_(None)
            )
        ).first()
        
        if not db_refresh_token:
            raise HTTPException(status_code=401, detail="Invalid refresh token")
        
        # Verify user if provided
        if user_id and db_refresh_token.user_id != user_id:
            raise HTTPException(status_code=401, detail="Token mismatch")
        
        # Create new access token
        access_token = self._create_access_token(db_refresh_token.user_id)
        
        # Update session activity
        session = self.db.query(EnhancedUserSession).filter(
            EnhancedUserSession.refresh_token_id == db_refresh_token.id
        ).first()
        
        if session:
            session.last_activity = datetime.utcnow()
            self.db.commit()
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "expires_in": self.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        }
    
    def revoke_refresh_token(self, refresh_token: str, user_id: int) -> bool:
        """Revoke a refresh token."""
        token_hash = self._hash_token(refresh_token)
        
        db_refresh_token = self.db.query(RefreshToken).filter(
            and_(
                RefreshToken.token_hash == token_hash,
                RefreshToken.user_id == user_id
            )
        ).first()
        
        if db_refresh_token:
            db_refresh_token.revoked_at = datetime.utcnow()
            
            # Revoke associated session
            session = self.db.query(EnhancedUserSession).filter(
                EnhancedUserSession.refresh_token_id == db_refresh_token.id
            ).first()
            
            if session:
                session.status = SessionStatus.REVOKED
            
            self.db.commit()
            return True
        
        return False
    
    def revoke_all_user_sessions(self, user_id: int) -> int:
        """Revoke all sessions for a user."""
        # Revoke all refresh tokens
        refresh_tokens = self.db.query(RefreshToken).filter(
            and_(
                RefreshToken.user_id == user_id,
                RefreshToken.revoked_at.is_(None)
            )
        ).all()
        
        for token in refresh_tokens:
            token.revoked_at = datetime.utcnow()
        
        # Revoke all sessions
        sessions = self.db.query(EnhancedUserSession).filter(
            and_(
                EnhancedUserSession.user_id == user_id,
                EnhancedUserSession.status == SessionStatus.ACTIVE
            )
        ).all()
        
        for session in sessions:
            session.status = SessionStatus.REVOKED
        
        self.db.commit()
        return len(refresh_tokens)
    
    def get_user_sessions(self, user_id: int) -> List[Dict[str, Any]]:
        """Get all active sessions for a user."""
        sessions = self.db.query(EnhancedUserSession).filter(
            and_(
                EnhancedUserSession.user_id == user_id,
                EnhancedUserSession.status == SessionStatus.ACTIVE,
                EnhancedUserSession.expires_at > datetime.utcnow()
            )
        ).all()
        
        return [
            {
                "session_id": session.session_id,
                "created_at": session.created_at,
                "last_activity": session.last_activity,
                "expires_at": session.expires_at,
                "device_info": session.device_info,
                "ip_address": session.ip_address,
                "user_agent": session.user_agent
            }
            for session in sessions
        ]
    
    def check_rate_limit(self, identifier: str, action: str, max_attempts: int = 5, 
                        window_minutes: int = 15) -> bool:
        """Check if request is within rate limits."""
        window_start = datetime.utcnow() - timedelta(minutes=window_minutes)
        
        # Get rate limit record
        rate_limit = self.db.query(RateLimitLog).filter(
            and_(
                RateLimitLog.identifier == identifier,
                RateLimitLog.action == action
            )
        ).first()
        
        if not rate_limit:
            # First attempt
            rate_limit = RateLimitLog(
                identifier=identifier,
                action=action,
                attempts=1
            )
            self.db.add(rate_limit)
            self.db.commit()
            return True
        
        # Check if blocked
        if rate_limit.blocked_until and rate_limit.blocked_until > datetime.utcnow():
            return False
        
        # Reset if window has passed
        if rate_limit.first_attempt < window_start:
            rate_limit.attempts = 1
            rate_limit.first_attempt = datetime.utcnow()
            rate_limit.blocked_until = None
        else:
            rate_limit.attempts += 1
            rate_limit.last_attempt = datetime.utcnow()
            
            # Block if too many attempts
            if rate_limit.attempts > max_attempts:
                rate_limit.blocked_until = datetime.utcnow() + timedelta(minutes=window_minutes)
        
        self.db.commit()
        return rate_limit.attempts <= max_attempts
    
    def log_audit_event(self, user_id: int = None, action: str = None, resource: str = None,
                       ip_address: str = None, user_agent: str = None, success: bool = True,
                       error_message: str = None, metadata: Dict[str, Any] = None):
        """Log security audit event."""
        audit_log = AuditLog(
            user_id=user_id,
            action=action,
            resource=resource,
            ip_address=ip_address,
            user_agent=user_agent,
            success=success,
            error_message=error_message,
            audit_data=json.dumps(metadata) if metadata else None
        )
        
        self.db.add(audit_log)
        self.db.commit()
    
    def get_audit_logs(self, user_id: int = None, action: str = None, 
                      limit: int = 100) -> List[Dict[str, Any]]:
        """Get audit logs with optional filtering."""
        query = self.db.query(AuditLog)
        
        if user_id:
            query = query.filter(AuditLog.user_id == user_id)
        
        if action:
            query = query.filter(AuditLog.action == action)
        
        logs = query.order_by(AuditLog.created_at.desc()).limit(limit).all()
        
        return [
            {
                "id": log.id,
                "user_id": log.user_id,
                "action": log.action,
                "resource": log.resource,
                "ip_address": log.ip_address,
                "success": log.success,
                "error_message": log.error_message,
                "metadata": json.loads(log.audit_data) if log.audit_data else None,
                "created_at": log.created_at
            }
            for log in logs
        ]
    
    def cleanup_expired_tokens(self) -> int:
        """Clean up expired tokens and sessions."""
        now = datetime.utcnow()
        
        # Clean expired refresh tokens
        expired_tokens = self.db.query(RefreshToken).filter(
            RefreshToken.expires_at < now
        ).all()
        
        for token in expired_tokens:
            token.revoked_at = now
        
        # Clean expired sessions
        expired_sessions = self.db.query(EnhancedUserSession).filter(
            EnhancedUserSession.expires_at < now
        ).all()
        
        for session in expired_sessions:
            session.status = SessionStatus.EXPIRED
        
        self.db.commit()
        return len(expired_tokens) + len(expired_sessions)

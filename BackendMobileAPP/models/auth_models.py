from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
from database.base import Base
import enum


class TokenType(str, enum.Enum):
    ACCESS = "access"
    REFRESH = "refresh"


class SessionStatus(str, enum.Enum):
    ACTIVE = "active"
    EXPIRED = "expired"
    REVOKED = "revoked"


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"
    
    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    token_hash = Column(String(255), nullable=False, unique=True, index=True)
    expires_at = Column(DateTime, nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    revoked_at = Column(DateTime, nullable=True)
    device_info = Column(Text, nullable=True)  # Store device fingerprint
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(Text, nullable=True)
    
    # Relationship
    user = relationship("User", back_populates="refresh_tokens")


class EnhancedUserSession(Base):
    __tablename__ = "enhanced_user_sessions"
    
    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    session_id = Column(String(255), nullable=False, unique=True, index=True)
    refresh_token_id = Column(Integer, ForeignKey("refresh_tokens.id"), nullable=True)
    status = Column(Enum(SessionStatus), default=SessionStatus.ACTIVE, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_activity = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime, nullable=False, index=True)
    device_info = Column(Text, nullable=True)
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(Text, nullable=True)
    
    # Relationships
    user = relationship("User")
    refresh_token = relationship("RefreshToken")


class AuditLog(Base):
    __tablename__ = "audit_logs"
    
    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    action = Column(String(100), nullable=False, index=True)  # login, logout, password_change, etc.
    resource = Column(String(100), nullable=True)  # endpoint or resource accessed
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(Text, nullable=True)
    success = Column(Boolean, default=True, index=True)
    error_message = Column(Text, nullable=True)
    audit_data = Column(Text, nullable=True)  # JSON string for additional data
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    
    # Relationship
    user = relationship("User", back_populates="audit_logs")


class RateLimitLog(Base):
    __tablename__ = "rate_limit_logs"
    
    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    identifier = Column(String(255), nullable=False, index=True)  # IP, user_id, or email
    action = Column(String(100), nullable=False, index=True)  # login, register, etc.
    attempts = Column(Integer, default=1)
    first_attempt = Column(DateTime, default=datetime.utcnow)
    last_attempt = Column(DateTime, default=datetime.utcnow)
    blocked_until = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)




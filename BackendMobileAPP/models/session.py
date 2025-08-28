from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timedelta
from database.base import Base

class UserSession(Base):
    __tablename__ = "user_sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    session_token = Column(String(500), nullable=False, unique=True)
    device_info = Column(String(200))
    ip_address = Column(String(45))
    user_agent = Column(String(500))
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_activity = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime, nullable=False)
    
    # Relationship
    user = relationship("User", back_populates="sessions")

class SessionLog(Base):
    __tablename__ = "session_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    action = Column(String(50), nullable=False)  # login, logout, token_refresh, session_expired
    session_token = Column(String(500), nullable=True)
    ip_address = Column(String(45))
    user_agent = Column(String(500))
    success = Column(Boolean, default=True)
    error_message = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationship
    user = relationship("User", back_populates="session_logs")

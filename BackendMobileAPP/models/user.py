import logging
from database.base import Base
from sqlalchemy.orm import relationship

logger = logging.getLogger(__name__)

from sqlalchemy import Column, Integer, String, Boolean, Date, DateTime
from datetime import datetime


class User(Base):
    __tablename__ = "users"
    __table_args__ = {'extend_existing': True}
    
    # Basic user info
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=True)
    gender = Column(String, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    contact_number = Column(String, nullable=True)
    profile_image_url = Column(String, nullable=True)
    guest_code = Column(String, unique=True, nullable=True)
    guest_id = Column(String, unique=True, nullable=True)

    # Address
    address_line1 = Column(String, nullable=True)
    address_line2 = Column(String, nullable=True)
    city = Column(String, nullable=True)
    state = Column(String, nullable=True)
    postal_code = Column(String, nullable=True)
    country = Column(String, nullable=True)

    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    created_by = Column(Integer, nullable=True)  # user ID who created
    updated_by = Column(Integer, nullable=True)

    # Security
    last_login = Column(DateTime, nullable=True)
    last_password_change = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True)
    is_customer = Column(Boolean, default=False)
    is_locked = Column(Boolean, default=False)
    failed_login_attempts = Column(Integer, default=0)
    two_factor_enabled = Column(Boolean, default=True)

    # Role/Permissions
    role = Column(String, nullable=True)
    
    # Relationships - using string references to avoid circular imports
    sessions = relationship("UserSession", back_populates="user", lazy="dynamic")
    session_logs = relationship("SessionLog", back_populates="user", lazy="dynamic")
    enhanced_sessions = relationship("EnhancedUserSession", back_populates="user", lazy="dynamic")
    refresh_tokens = relationship("RefreshToken", back_populates="user", lazy="dynamic")
    audit_logs = relationship("AuditLog", back_populates="user", lazy="dynamic")
    roles = relationship("Role", secondary="user_roles", back_populates="users", lazy="dynamic")
    user_permissions = relationship("UserPermission", foreign_keys="UserPermission.user_id", lazy="dynamic")


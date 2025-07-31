from sqlalchemy import Column, Integer, String, DateTime, Boolean
from datetime import datetime

from database.base import Base


class LoginLog(Base):
    __tablename__ = "login_logs"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, index=True)
    request_id = Column(String(36), index=True, nullable=False)  # UUID string
    username = Column(String(255), index=True, nullable=False)
    ip_address = Column(String(100), nullable=True)
    success = Column(Boolean, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow, nullable=False)
    error_message = Column(String(255), nullable=True)

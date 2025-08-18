from sqlalchemy import Column, Integer, String, DateTime, Boolean
from datetime import datetime, timedelta
from database.base import Base

class OTP(Base):
    __tablename__ = "otps"

    id = Column(Integer, primary_key=True, index=True)
    contact_number = Column(String, nullable=False, index=True)
    otp_code = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    is_used = Column(Boolean, default=False, nullable=False)

    def __init__(self, contact_number, otp_code, expires_in_minutes=5):
        self.contact_number = contact_number
        self.otp_code = otp_code
        self.created_at = datetime.utcnow()
        self.expires_at = self.created_at + timedelta(minutes=expires_in_minutes)
        self.is_used = False 
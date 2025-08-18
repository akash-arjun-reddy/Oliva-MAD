from sqlalchemy import Column, String, DateTime, Text, Integer
from sqlalchemy.sql import func
from database.connection import Base

class Meeting(Base):
    __tablename__ = "meetings"
    
    id = Column(Integer, primary_key=True, index=True)
    meeting_id = Column(String(255), unique=True, index=True, nullable=False)
    meeting_link = Column(Text, nullable=False)
    customer_name = Column(String(255), nullable=False)
    doctor_name = Column(String(255), nullable=False)
    slot_time = Column(String(255), nullable=False)
    customer_email = Column(String(255), nullable=True)
    doctor_email = Column(String(255), nullable=True)
    status = Column(String(50), default="active")  # active, completed, cancelled
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

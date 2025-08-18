from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func
from app.database.connection import Base, DB_SCHEMA

class Patient(Base):
    """Patient model for database"""
    __tablename__ = "patients"
    __table_args__ = {"schema": DB_SCHEMA}
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, index=True)
    email = Column(String(255), nullable=False, index=True)
    phone = Column(String(20), nullable=True)
    date_of_birth = Column(DateTime, nullable=True)
    medical_history = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    def __repr__(self):
        return f"<Patient(id={self.id}, name='{self.name}', email='{self.email}')>"

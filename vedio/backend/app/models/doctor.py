from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func
from app.database.connection import Base, DB_SCHEMA

class Doctor(Base):
    """Doctor model for database"""
    __tablename__ = "doctors"
    __table_args__ = {"schema": DB_SCHEMA}
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, index=True)
    email = Column(String(255), nullable=False, unique=True, index=True)
    specialty = Column(String(100), nullable=False)
    photo_url = Column(String(500), nullable=True)
    rating = Column(Integer, default=0)  # Rating out of 5
    experience_years = Column(Integer, default=0)
    bio = Column(Text, nullable=True)
    is_active = Column(Integer, default=1)  # 1 for active, 0 for inactive
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    def __repr__(self):
        return f"<Doctor(id={self.id}, name='{self.name}', specialty='{self.specialty}')>"

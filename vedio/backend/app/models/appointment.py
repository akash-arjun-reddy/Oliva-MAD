from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database.connection import Base, DB_SCHEMA

class Appointment(Base):
    """Appointment model for database"""
    __tablename__ = "appointments"
    __table_args__ = {"schema": DB_SCHEMA}
    
    id = Column(Integer, primary_key=True, index=True)
    doctor_id = Column(Integer, ForeignKey(f"{DB_SCHEMA}.doctors.id"), nullable=False, index=True)
    patient_id = Column(Integer, ForeignKey(f"{DB_SCHEMA}.patients.id"), nullable=False, index=True)
    date = Column(DateTime, nullable=False, index=True)
    time_slot = Column(String(10), nullable=False)  # Format: "HH:MM"
    meeting_link = Column(String(500), nullable=False)
    passcode = Column(String(20), nullable=False)
    concern = Column(String(200), nullable=True)
    status = Column(String(20), default="scheduled")  # scheduled, completed, cancelled, rescheduled
    doctor_email_sent = Column(Boolean, default=False)
    patient_email_sent = Column(Boolean, default=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    doctor = relationship("Doctor", backref="appointments")
    patient = relationship("Patient", backref="appointments")
    
    def __repr__(self):
        return f"<Appointment(id={self.id}, doctor_id={self.doctor_id}, patient_id={self.patient_id}, date='{self.date}', time_slot='{self.time_slot}')>"

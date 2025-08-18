from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import List, Optional
from app.models.patient import Patient

class PatientRepository:
    """Repository for patient database operations"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def create(self, name: str, email: str, phone: str = None, date_of_birth = None, medical_history: str = None) -> Patient:
        """Create a new patient"""
        patient = Patient(
            name=name,
            email=email,
            phone=phone,
            date_of_birth=date_of_birth,
            medical_history=medical_history
        )
        self.db.add(patient)
        self.db.commit()
        self.db.refresh(patient)
        return patient
    
    def get_by_id(self, patient_id: int) -> Optional[Patient]:
        """Get patient by ID"""
        return self.db.query(Patient).filter(Patient.id == patient_id).first()
    
    def get_by_email(self, email: str) -> Optional[Patient]:
        """Get patient by email"""
        return self.db.query(Patient).filter(Patient.email == email).first()
    
    def get_or_create_by_email(self, name: str, email: str) -> Patient:
        """Get existing patient by email or create new one"""
        patient = self.get_by_email(email)
        if patient:
            # Update name if different
            if patient.name != name:
                patient.name = name
                self.db.commit()
            return patient
        else:
            return self.create(name, email)
    
    def get_all(self, skip: int = 0, limit: int = 100) -> List[Patient]:
        """Get all patients with pagination"""
        return self.db.query(Patient).offset(skip).limit(limit).all()
    
    def update(self, patient_id: int, **kwargs) -> Optional[Patient]:
        """Update patient information"""
        patient = self.get_by_id(patient_id)
        if not patient:
            return None
        
        for field, value in kwargs.items():
            if hasattr(patient, field):
                setattr(patient, field, value)
        
        self.db.commit()
        self.db.refresh(patient)
        return patient
    
    def delete(self, patient_id: int) -> bool:
        """Delete patient"""
        patient = self.get_by_id(patient_id)
        if not patient:
            return False
        
        self.db.delete(patient)
        self.db.commit()
        return True
    
    def search(self, query: str, skip: int = 0, limit: int = 100) -> List[Patient]:
        """Search patients by name or email"""
        search_term = f"%{query}%"
        return self.db.query(Patient).filter(
            or_(
                Patient.name.ilike(search_term),
                Patient.email.ilike(search_term)
            )
        ).offset(skip).limit(limit).all()
    
    def count(self) -> int:
        """Count total patients"""
        return self.db.query(Patient).count()

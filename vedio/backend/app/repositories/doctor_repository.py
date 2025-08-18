from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import List, Optional
from app.models.doctor import Doctor
from app.dto.doctor_dto import DoctorCreateDTO, DoctorUpdateDTO

class DoctorRepository:
    """Repository for doctor database operations"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def create(self, doctor_data: DoctorCreateDTO) -> Doctor:
        """Create a new doctor"""
        doctor = Doctor(
            name=doctor_data.name,
            email=doctor_data.email,
            specialty=doctor_data.specialty,
            photo_url=doctor_data.photo_url,
            rating=doctor_data.rating or 5,
            experience_years=doctor_data.experience_years or 0,
            bio=doctor_data.bio
        )
        self.db.add(doctor)
        self.db.commit()
        self.db.refresh(doctor)
        return doctor
    
    def get_by_id(self, doctor_id: int) -> Optional[Doctor]:
        """Get doctor by ID"""
        return self.db.query(Doctor).filter(Doctor.id == doctor_id).first()
    
    def get_by_email(self, email: str) -> Optional[Doctor]:
        """Get doctor by email"""
        return self.db.query(Doctor).filter(Doctor.email == email).first()
    
    def get_all(self, skip: int = 0, limit: int = 100, active_only: bool = True) -> List[Doctor]:
        """Get all doctors with pagination"""
        query = self.db.query(Doctor)
        if active_only:
            query = query.filter(Doctor.is_active == 1)
        return query.offset(skip).limit(limit).all()
    
    def update(self, doctor_id: int, doctor_data: DoctorUpdateDTO) -> Optional[Doctor]:
        """Update doctor information"""
        doctor = self.get_by_id(doctor_id)
        if not doctor:
            return None
        
        update_data = doctor_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(doctor, field, value)
        
        self.db.commit()
        self.db.refresh(doctor)
        return doctor
    
    def delete(self, doctor_id: int) -> bool:
        """Soft delete doctor (set as inactive)"""
        doctor = self.get_by_id(doctor_id)
        if not doctor:
            return False
        
        doctor.is_active = 0
        self.db.commit()
        return True
    
    def search(self, query: str, skip: int = 0, limit: int = 100) -> List[Doctor]:
        """Search doctors by name or specialty"""
        search_term = f"%{query}%"
        return self.db.query(Doctor).filter(
            and_(
                Doctor.is_active == 1,
                or_(
                    Doctor.name.ilike(search_term),
                    Doctor.specialty.ilike(search_term)
                )
            )
        ).offset(skip).limit(limit).all()
    
    def get_by_specialty(self, specialty: str, skip: int = 0, limit: int = 100) -> List[Doctor]:
        """Get doctors by specialty"""
        return self.db.query(Doctor).filter(
            and_(
                Doctor.specialty == specialty,
                Doctor.is_active == 1
            )
        ).offset(skip).limit(limit).all()
    
    def count(self, active_only: bool = True) -> int:
        """Count total doctors"""
        query = self.db.query(Doctor)
        if active_only:
            query = query.filter(Doctor.is_active == 1)
        return query.count()

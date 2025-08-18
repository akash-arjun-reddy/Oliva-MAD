from typing import List, Optional
from sqlalchemy.orm import Session
from app.repositories.doctor_repository import DoctorRepository
from app.dto.doctor_dto import (
    DoctorCreateDTO, 
    DoctorUpdateDTO, 
    DoctorResponseDTO,
    DoctorListResponseDTO
)

class DoctorService:
    """Service for doctor business logic"""
    
    def __init__(self, db: Session):
        self.db = db
        self.doctor_repo = DoctorRepository(db)
    
    def create_doctor(self, doctor_data: DoctorCreateDTO) -> DoctorResponseDTO:
        """Create a new doctor"""
        # Check if email already exists
        existing_doctor = self.doctor_repo.get_by_email(doctor_data.email)
        if existing_doctor:
            raise ValueError(f"Doctor with email {doctor_data.email} already exists")
        
        doctor = self.doctor_repo.create(doctor_data)
        return self._doctor_to_response_dto(doctor)
    
    def get_doctor(self, doctor_id: int) -> Optional[DoctorResponseDTO]:
        """Get doctor by ID"""
        doctor = self.doctor_repo.get_by_id(doctor_id)
        if not doctor:
            return None
        
        return self._doctor_to_response_dto(doctor)
    
    def get_all_doctors(self, skip: int = 0, limit: int = 100, active_only: bool = True) -> DoctorListResponseDTO:
        """Get all doctors with pagination"""
        doctors = self.doctor_repo.get_all(skip, limit, active_only)
        total = self.doctor_repo.count(active_only)
        
        doctor_dtos = [self._doctor_to_response_dto(doctor) for doctor in doctors]
        
        return DoctorListResponseDTO(
            doctors=doctor_dtos,
            total=total,
            page=skip // limit + 1,
            size=limit
        )
    
    def update_doctor(self, doctor_id: int, doctor_data: DoctorUpdateDTO) -> Optional[DoctorResponseDTO]:
        """Update doctor information"""
        # If email is being updated, check if it already exists
        if doctor_data.email:
            existing_doctor = self.doctor_repo.get_by_email(doctor_data.email)
            if existing_doctor and existing_doctor.id != doctor_id:
                raise ValueError(f"Doctor with email {doctor_data.email} already exists")
        
        doctor = self.doctor_repo.update(doctor_id, doctor_data)
        if not doctor:
            return None
        
        return self._doctor_to_response_dto(doctor)
    
    def delete_doctor(self, doctor_id: int) -> bool:
        """Soft delete doctor (set as inactive)"""
        return self.doctor_repo.delete(doctor_id)
    
    def search_doctors(self, query: str, skip: int = 0, limit: int = 100) -> DoctorListResponseDTO:
        """Search doctors by name or specialty"""
        doctors = self.doctor_repo.search(query, skip, limit)
        total = len(doctors)  # For search, we get all results and count
        
        doctor_dtos = [self._doctor_to_response_dto(doctor) for doctor in doctors]
        
        return DoctorListResponseDTO(
            doctors=doctor_dtos,
            total=total,
            page=skip // limit + 1,
            size=limit
        )
    
    def get_doctors_by_specialty(self, specialty: str, skip: int = 0, limit: int = 100) -> DoctorListResponseDTO:
        """Get doctors by specialty"""
        doctors = self.doctor_repo.get_by_specialty(specialty, skip, limit)
        total = len(doctors)  # For specialty filter, we get all results and count
        
        doctor_dtos = [self._doctor_to_response_dto(doctor) for doctor in doctors]
        
        return DoctorListResponseDTO(
            doctors=doctor_dtos,
            total=total,
            page=skip // limit + 1,
            size=limit
        )
    
    def get_active_doctors(self) -> List[DoctorResponseDTO]:
        """Get all active doctors"""
        doctors = self.doctor_repo.get_all(active_only=True)
        return [self._doctor_to_response_dto(doctor) for doctor in doctors]
    
    def _doctor_to_response_dto(self, doctor) -> DoctorResponseDTO:
        """Convert doctor model to response DTO"""
        return DoctorResponseDTO(
            id=doctor.id,
            name=doctor.name,
            email=doctor.email,
            specialty=doctor.specialty,
            photo_url=doctor.photo_url,
            rating=doctor.rating,
            experience_years=doctor.experience_years,
            bio=doctor.bio,
            is_active=bool(doctor.is_active),
            created_at=doctor.created_at,
            updated_at=doctor.updated_at
        )

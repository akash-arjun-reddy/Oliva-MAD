from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class DoctorCreateDTO(BaseModel):
    """DTO for creating a new doctor"""
    name: str = Field(..., min_length=2, max_length=100, description="Doctor's full name")
    email: str = Field(..., description="Doctor's email address")
    specialty: str = Field(..., min_length=2, max_length=100, description="Doctor's specialty")
    photo_url: Optional[str] = Field(None, description="URL to doctor's photo")
    rating: Optional[int] = Field(5, ge=0, le=5, description="Doctor's rating (0-5)")
    experience_years: Optional[int] = Field(0, ge=0, description="Years of experience")
    bio: Optional[str] = Field(None, description="Doctor's bio")

class DoctorUpdateDTO(BaseModel):
    """DTO for updating a doctor"""
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    email: Optional[str] = Field(None)
    specialty: Optional[str] = Field(None, min_length=2, max_length=100)
    photo_url: Optional[str] = Field(None)
    rating: Optional[int] = Field(None, ge=0, le=5)
    experience_years: Optional[int] = Field(None, ge=0)
    bio: Optional[str] = Field(None)
    is_active: Optional[bool] = Field(None)

class DoctorResponseDTO(BaseModel):
    """DTO for doctor response"""
    id: int = Field(..., description="Doctor's ID")
    name: str = Field(..., description="Doctor's full name")
    email: str = Field(..., description="Doctor's email address")
    specialty: str = Field(..., description="Doctor's specialty")
    photo_url: Optional[str] = Field(None, description="URL to doctor's photo")
    rating: int = Field(..., description="Doctor's rating (0-5)")
    experience_years: int = Field(..., description="Years of experience")
    bio: Optional[str] = Field(None, description="Doctor's bio")
    is_active: bool = Field(..., description="Whether doctor is active")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: Optional[datetime] = Field(None, description="Last update timestamp")
    
    class Config:
        from_attributes = True

class DoctorListResponseDTO(BaseModel):
    """DTO for list of doctors response"""
    doctors: List[DoctorResponseDTO] = Field(..., description="List of doctors")
    total: int = Field(..., description="Total number of doctors")
    page: int = Field(..., description="Current page number")
    size: int = Field(..., description="Page size")

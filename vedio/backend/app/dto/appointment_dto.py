from pydantic import BaseModel
from typing import List, Optional
from datetime import date, datetime

class AppointmentCreateDTO(BaseModel):
    doctor_id: int
    patient_name: str
    patient_email: str
    concern: str
    appointment_date: str
    time_slot: str

class AppointmentUpdateDTO(BaseModel):
    doctor_id: Optional[int] = None
    patient_name: Optional[str] = None
    patient_email: Optional[str] = None
    concern: Optional[str] = None
    appointment_date: Optional[str] = None
    time_slot: Optional[str] = None
    status: Optional[str] = None

class AppointmentResponseDTO(BaseModel):
    id: int
    doctor_id: int
    doctor_name: str
    patient_id: int
    patient_name: str
    patient_email: str
    concern: str
    appointment_date: str
    time_slot: str
    meeting_link: str
    passcode: str
    created_at: datetime

class DoctorAvailabilityDTO(BaseModel):
    doctor_id: int
    appointment_date: str
    available_slots: List[str]
    booked_slots: List[str]

class TimeSlotDTO(BaseModel):
    time: str
    available: bool

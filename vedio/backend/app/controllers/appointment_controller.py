from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database.connection import get_db
from app.services.appointment_service import AppointmentService
from app.dto.appointment_dto import AppointmentCreateDTO, AppointmentResponseDTO, DoctorAvailabilityDTO

router = APIRouter(prefix="/api/v1/appointments", tags=["appointments"])

@router.post("/", response_model=AppointmentResponseDTO)
async def create_appointment(
    appointment: AppointmentCreateDTO,
    db: Session = Depends(get_db)
):
    """Create a new appointment"""
    try:
        appointment_service = AppointmentService(db)
        result = appointment_service.create_appointment(appointment)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/doctor/{doctor_id}/availability", response_model=DoctorAvailabilityDTO)
async def get_doctor_availability(
    doctor_id: int,
    appointment_date: str,
    db: Session = Depends(get_db)
):
    """Get available time slots for a doctor on a specific date"""
    try:
        appointment_service = AppointmentService(db)
        availability = appointment_service.get_doctor_availability(doctor_id, appointment_date)
        return availability
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/booked-slots")
async def get_booked_slots(db: Session = Depends(get_db)):
    """Get all booked slots for frontend"""
    try:
        appointment_service = AppointmentService(db)
        booked_slots = appointment_service.get_all_booked_slots()
        return {"booked_slots": booked_slots}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
import logging
import traceback

from database.session import get_db, get_zenoti_db
from dto.appointment_schema import (
    AppointmentResponseDTO, AppointmentCreateDTO, AppointmentShortOut, WalkinAppointmentOut
)
from models.user import User
from repository.appointment_repo import WalkinAppointmentRepository
from security.jwt import get_current_user
from service.appointment_service import AppointmentService
from utils.email_utils import send_appointment_details_email

router = APIRouter(prefix="/appointments", tags=["Appointments"])
access_logger = logging.getLogger("uvicorn.access")

# 1. Doctor Slot Availability
@router.get("/doctors/{doctor_id}/slots")
def available_slots(
        doctor_id: int,
        date: str,
        db: Session = Depends(get_db)
):
    try:
        date_obj = datetime.strptime(date, "%Y-%m-%d").date()
        slots = AppointmentService.get_available_slots(db, doctor_id, date_obj)
        return [
            {"start_time": s[0].strftime("%H:%M"), "end_time": s[1].strftime("%H:%M")}
            for s in slots
        ]
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Error fetching available slots")


# 2. Book Appointment
@router.post("/", response_model=AppointmentResponseDTO)
def create_appointment(
        data: AppointmentCreateDTO,
        background_tasks: BackgroundTasks,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    try:
        appointment_response = AppointmentService.book_appointment(
            db=db,
            patient_id=current_user.id,
            data=data
        )

        # Trigger appointment email in background (if needed)
        patient_email = current_user.email
        doctor_email = getattr(data, 'doctor_email', None)

        if patient_email and doctor_email:
            background_tasks.add_task(
                send_appointment_details_email,
                patient_email,
                doctor_email,
                appointment_response['data']  # assuming `Appointment` ORM model
            )

        return appointment_response['data']  # returning the DTO only

    except Exception as e:
        traceback.print_exc()

        if str(e) == "Slot already booked":
            raise HTTPException(status_code=409, detail="Slot already booked")

        raise HTTPException(status_code=500, detail="Error booking appointment")


# 3. Appointment History (Zenoti DB)
@router.get("/history/{guest_id}", response_model=List[AppointmentShortOut])
async def get_appointment_history(
        guest_id: str,
        db: Session = Depends(get_zenoti_db),
        current_user: User = Depends(get_current_user)
):
    try:
        if current_user.guest_id != guest_id:
            raise HTTPException(status_code=403, detail="Unauthorized access to guest history")

        records = AppointmentService.get_by_guest_id(guest_id, db)
        if not records:
            raise HTTPException(status_code=404, detail="No appointments found")

        access_logger.info("✅ %d appointment(s) returned for guest_id: %s", len(records), guest_id)
        return records

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Error retrieving appointment history")


# 4. Walk-in Appointment History
@router.get("/walkin-history/{appointment_id}", response_model=List[WalkinAppointmentOut])
async def get_walkin_history(
        appointment_id: str,
        db: Session = Depends(get_zenoti_db),
        current_user: User = Depends(get_current_user)
):
    try:
        records = WalkinAppointmentRepository.get_by_appointment_id_if_authorized(
            appointment_id=appointment_id,
            guest_id=current_user.guest_id,
            db=db
        )

        if not records:
            raise HTTPException(status_code=404, detail="Walk-in not found or unauthorized")

        return records

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Error retrieving walk-in appointment history")

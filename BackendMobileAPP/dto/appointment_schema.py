from typing import Optional
import datetime
from uuid import UUID
from pydantic import BaseModel, Field
from constants.status_codes import REVERSE_STATUS_MAP


# ----------------------------
# Short Appointment History DTO (Zenoti)
# ----------------------------
class AppointmentShortOut(BaseModel):
    appointment_id: str
    invoice_id: Optional[str]
    service_name: Optional[str]
    service_id: Optional[str]
    status: Optional[int]
    guest_id: Optional[str]
    form_id: Optional[str]
    center_id: Optional[str]
    creation_date_utc: Optional[str]

    class Config:
        from_attributes = True


# ----------------------------
# Walk-in Appointment DTO
# ----------------------------
class WalkinAppointmentOut(BaseModel):
    appointment_id: UUID
    mobilenumber: Optional[int]
    date1: Optional[datetime.date]
    status: Optional[str]
    therapistnameval: Optional[str]
    centernamelist: Optional[str]

    # Doctor recommendations
    olivadoctorrecommendations1: Optional[str]
    olivadoctorrecommendations2: Optional[str]
    olivadoctorrecommendations3: Optional[str]
    olivadoctorrecommendations4: Optional[str]
    olivadoctorrecommendations5: Optional[str]
    olivadoctorrecommendations6: Optional[str]
    olivadoctorrecommendations7: Optional[str]
    olivadoctorrecommendations8: Optional[str]

    # Other fields
    is_active: Optional[bool]
    dq_check_remark: Optional[str]
    is_convert: Optional[bool]
    is_recommended: Optional[bool]
    recommendations: Optional[str]
    crt_name: Optional[str]
    inserted_date_time: Optional[datetime.datetime]

    class Config:
        from_attributes = True


# ----------------------------
# Create Appointment DTO
# ----------------------------
class AppointmentCreateDTO(BaseModel):
    doctor_id: int = Field(..., example=46)
    date: datetime.date = Field(..., example="2025-07-01")
    start_time: datetime.time = Field(..., example="10:00:00")
    end_time: datetime.time = Field(..., example="10:15:00")


# ----------------------------
# Appointment Response DTO
# ----------------------------
from datetime import date, time

class AppointmentResponseDTO(BaseModel):
    id: int
    appointment_id: str
    doctor_id: int
    patient_id: int
    date: date
    start_time: time
    end_time: time
    video_call_link: Optional[str]
    status: str

    class Config:
        orm_mode = True

    @classmethod
    def from_orm(cls, obj):
        return cls(
            id=obj.id,
            appointment_id=obj.appointment_id,
            doctor_id=obj.doctor_id,
            patient_id=obj.patient_id,
            date=obj.date,
            start_time=obj.start_time,
            end_time=obj.end_time,
            video_call_link=obj.video_call_link,
            status=REVERSE_STATUS_MAP.get(obj.status, "Unknown")
        )

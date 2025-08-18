from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class CreateMeetingRequest(BaseModel):
    customer_name: str
    doctor_name: str
    slot_time: str
    customer_email: Optional[str] = None
    doctor_email: Optional[str] = None

class MeetingResponse(BaseModel):
    meeting_id: str
    meeting_link: str
    customer_name: str
    doctor_name: str
    slot_time: str
    customer_email: Optional[str] = None
    doctor_email: Optional[str] = None
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class EmailResponse(BaseModel):
    meeting_id: str
    meeting_link: str
    emails_sent: List[str]
    message: str

class ErrorResponse(BaseModel):
    detail: str
    error_code: Optional[str] = None

class MeetingListResponse(BaseModel):
    meetings: List[MeetingResponse]
    total: int

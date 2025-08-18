from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class MeetingRequest(BaseModel):
    """Request model for meeting creation"""
    customer_name: str = Field(..., description="Customer's full name")
    doctor_name: str = Field(..., description="Doctor's full name")
    slot_time: str = Field(..., description="Meeting date in yyyy:mm:dd format")
    customer_email: Optional[str] = Field(None, description="Customer's email address")
    doctor_email: Optional[str] = Field(None, description="Doctor's email address")

class MeetingResponse(BaseModel):
    """Response model for meeting creation"""
    meeting_link: str = Field(..., description="Generated Jitsi Meet link")
    meeting_id: str = Field(..., description="Unique meeting identifier")
    customer_name: str = Field(..., description="Customer's full name")
    doctor_name: str = Field(..., description="Doctor's full name")
    slot_time: str = Field(..., description="Meeting date")
    created_at: datetime = Field(default_factory=datetime.now, description="Creation timestamp")

class EmailResponse(BaseModel):
    """Response model for email sending"""
    meeting_link: str = Field(..., description="Generated Jitsi Meet link")
    meeting_id: str = Field(..., description="Unique meeting identifier")
    emails_sent: list[str] = Field(..., description="List of email sending status")
    message: str = Field(..., description="Response message") 
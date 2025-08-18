from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime

class CreateMeetingRequestDTO(BaseModel):
    """DTO for creating a new meeting"""
    customer_name: str = Field(
        ..., 
        min_length=1, 
        max_length=100,
        description="Customer's full name",
        example="John Doe"
    )
    doctor_name: str = Field(
        ..., 
        min_length=1, 
        max_length=100,
        description="Doctor's full name",
        example="Dr. Sarah Smith"
    )
    slot_time: str = Field(
        ..., 
        description="Meeting date in yyyy:mm:dd format",
        example="2024:01:15"
    )
    customer_email: Optional[str] = Field(
        None,
        description="Customer's email address for meeting invitation",
        example="customer@example.com"
    )
    doctor_email: Optional[str] = Field(
        None,
        description="Doctor's email address for meeting invitation",
        example="doctor@example.com"
    )

    @validator('customer_name', 'doctor_name')
    def validate_names(cls, v):
        """Validate that names are not empty and contain only valid characters"""
        if not v or not v.strip():
            raise ValueError('Name cannot be empty')
        if len(v.strip()) < 2:
            raise ValueError('Name must be at least 2 characters long')
        return v.strip()

    @validator('slot_time')
    def validate_slot_time(cls, v):
        """Validate slot time format"""
        try:
            datetime.strptime(v, "%Y:%m:%d")
            return v
        except ValueError:
            raise ValueError('Slot time must be in yyyy:mm:dd format (e.g., 2024:01:15)')

    @validator('customer_email', 'doctor_email')
    def validate_email(cls, v):
        """Validate email format if provided"""
        if v is not None:
            import re
            email_regex = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            if not email_regex.match(v):
                raise ValueError('Invalid email format')
        return v

class MeetingResponseDTO(BaseModel):
    """DTO for meeting response"""
    meeting_link: str = Field(
        ...,
        description="Generated Jitsi Meet link",
        example="https://meet.jit.si/John_Doe_Dr_Sarah_Smith_20240115_143022_abc123#config.prejoinPageEnabled=false&config.disableDeepLinking=true"
    )
    meeting_id: str = Field(
        ...,
        description="Unique meeting identifier",
        example="John_Doe_Dr_Sarah_Smith_20240115_143022_abc123"
    )
    customer_name: str = Field(
        ...,
        description="Customer's full name",
        example="John Doe"
    )
    doctor_name: str = Field(
        ...,
        description="Doctor's full name",
        example="Dr. Sarah Smith"
    )
    slot_time: str = Field(
        ...,
        description="Meeting date",
        example="2024:01:15"
    )
    created_at: datetime = Field(
        default_factory=datetime.now,
        description="Creation timestamp"
    )

class EmailResponseDTO(BaseModel):
    """DTO for email sending response"""
    meeting_link: str = Field(
        ...,
        description="Generated Jitsi Meet link"
    )
    meeting_id: str = Field(
        ...,
        description="Unique meeting identifier"
    )
    emails_sent: list[str] = Field(
        ...,
        description="List of email sending status messages",
        example=[
            "Customer email sent to customer@example.com",
            "Doctor email sent to doctor@example.com"
        ]
    )
    message: str = Field(
        ...,
        description="Response message",
        example="Jitsi Meet link generated and emails sent"
    )

class MeetingSummaryDTO(BaseModel):
    """DTO for meeting summary information"""
    meeting_id: str = Field(..., description="Unique meeting identifier")
    customer_name: str = Field(..., description="Customer's name")
    doctor_name: str = Field(..., description="Doctor's name")
    slot_time: str = Field(..., description="Meeting date")
    created_at: datetime = Field(..., description="Creation timestamp")
    has_emails: bool = Field(..., description="Whether emails were sent")

class ErrorResponseDTO(BaseModel):
    """DTO for error responses"""
    error: str = Field(..., description="Error message")
    detail: Optional[str] = Field(None, description="Detailed error information")
    timestamp: datetime = Field(default_factory=datetime.now, description="Error timestamp") 
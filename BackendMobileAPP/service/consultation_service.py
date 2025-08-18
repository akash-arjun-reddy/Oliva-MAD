import secrets
import string
from datetime import datetime
from typing import Optional, List
from config.settings import settings
from service.consultation_email_service import ConsultationEmailService
from repository.meeting_repository import MeetingRepository
from dto.meeting_schema import CreateMeetingRequest, MeetingResponse, EmailResponse

class ConsultationService:
    """Service for handling consultation-related operations"""
    
    def __init__(self, repository: MeetingRepository):
        """Initialize service with repository dependency injection"""
        self.repository = repository
    
    @staticmethod
    def sanitize_name(name: str) -> str:
        """Sanitize name for use in meeting ID"""
        # Remove special characters and replace spaces with underscores
        import re
        sanitized = re.sub(r'[^a-zA-Z0-9\s]', '', name)
        sanitized = re.sub(r'\s+', '_', sanitized.strip())
        return sanitized.lower()
    
    @staticmethod
    def validate_meeting_request(customer_name: str, doctor_name: str, slot_time: str) -> tuple[bool, str]:
        """Validate meeting request data"""
        if not customer_name or not customer_name.strip():
            return False, "Customer name is required"
        
        if not doctor_name or not doctor_name.strip():
            return False, "Doctor name is required"
        
        if not slot_time or not slot_time.strip():
            return False, "Slot time is required"
        
        return True, ""
    
    @staticmethod
    def generate_meeting_id(customer_name: str, doctor_name: str) -> str:
        """Generate a unique meeting ID with timestamp and random string"""
        customer_clean = ConsultationService.sanitize_name(customer_name)
        doctor_clean = ConsultationService.sanitize_name(doctor_name)
        
        # Add timestamp for uniqueness
        timestamp = datetime.now().strftime("%Y%m%d_%H%M")
        
        # Add random string for additional uniqueness
        random_suffix = ''.join(secrets.choice(string.ascii_lowercase + string.digits) for _ in range(6))
        
        return f"{customer_clean}_{doctor_clean}_{timestamp}_{random_suffix}"
    
    @staticmethod
    def create_meeting_link(meeting_id: str) -> str:
        """Create Jitsi Meet link with configuration parameters"""
        return f"{settings.JITSI_BASE_URL}/{meeting_id}#{settings.JITSI_CONFIG_PARAMS}"
    
    async def generate_meeting(self, request: CreateMeetingRequest) -> MeetingResponse:
        """Generate a new meeting with Jitsi Meet link and store it"""
        # Validate request
        is_valid, error_message = ConsultationService.validate_meeting_request(
            request.customer_name, 
            request.doctor_name, 
            request.slot_time
        )
        
        if not is_valid:
            raise ValueError(error_message)
        
        # Generate meeting ID and link
        meeting_id = ConsultationService.generate_meeting_id(request.customer_name, request.doctor_name)
        meeting_link = ConsultationService.create_meeting_link(meeting_id)
        
        # Get doctor email from settings if not provided
        doctor_email = request.doctor_email
        if not doctor_email and request.doctor_name in settings.DOCTOR_EMAILS:
            doctor_email = settings.DOCTOR_EMAILS[request.doctor_name]
        
        # Create meeting data
        meeting_data = {
            "meeting_id": meeting_id,
            "meeting_link": meeting_link,
            "customer_name": request.customer_name,
            "doctor_name": request.doctor_name,
            "slot_time": request.slot_time,
            "customer_email": request.customer_email,
            "doctor_email": doctor_email,
            "status": "active"
        }
        
        # Store meeting in repository
        meeting = await self.repository.create_meeting(meeting_data)
        
        # Convert to response format
        return MeetingResponse(
            meeting_id=meeting.meeting_id,
            meeting_link=meeting.meeting_link,
            customer_name=meeting.customer_name,
            doctor_name=meeting.doctor_name,
            slot_time=meeting.slot_time,
            customer_email=meeting.customer_email,
            doctor_email=meeting.doctor_email,
            status=meeting.status,
            created_at=meeting.created_at
        )
    
    async def send_meeting_emails(self, request: CreateMeetingRequest) -> EmailResponse:
        """Generate meeting and send emails to both parties"""
        # Generate meeting first
        meeting_response = await self.generate_meeting(request)
        
        # Get doctor email from settings if not provided
        doctor_email = request.doctor_email
        if not doctor_email and request.doctor_name in settings.DOCTOR_EMAILS:
            doctor_email = settings.DOCTOR_EMAILS[request.doctor_name]
        
        # Send emails
        emails_sent = ConsultationEmailService.send_meeting_emails(
            customer_name=request.customer_name,
            doctor_name=request.doctor_name,
            slot_time=request.slot_time,
            meeting_link=meeting_response.meeting_link,
            customer_email=request.customer_email,
            doctor_email=doctor_email
        )
        
        return EmailResponse(
            meeting_id=meeting_response.meeting_id,
            meeting_link=meeting_response.meeting_link,
            emails_sent=emails_sent,
            message="Meeting created and emails sent successfully"
        )
    
    async def get_meeting_by_id(self, meeting_id: str) -> Optional[MeetingResponse]:
        """Get meeting by ID"""
        meeting = await self.repository.get_meeting_by_id(meeting_id)
        if meeting:
            return MeetingResponse(
                meeting_id=meeting.meeting_id,
                meeting_link=meeting.meeting_link,
                customer_name=meeting.customer_name,
                doctor_name=meeting.doctor_name,
                slot_time=meeting.slot_time,
                customer_email=meeting.customer_email,
                doctor_email=meeting.doctor_email,
                status=meeting.status,
                created_at=meeting.created_at
            )
        return None
    
    async def get_meetings_by_customer(self, customer_name: str) -> List[MeetingResponse]:
        """Get all meetings for a customer"""
        meetings = await self.repository.get_meetings_by_customer(customer_name)
        return [
            MeetingResponse(
                meeting_id=meeting.meeting_id,
                meeting_link=meeting.meeting_link,
                customer_name=meeting.customer_name,
                doctor_name=meeting.doctor_name,
                slot_time=meeting.slot_time,
                customer_email=meeting.customer_email,
                doctor_email=meeting.doctor_email,
                status=meeting.status,
                created_at=meeting.created_at
            )
            for meeting in meetings
        ]
    
    async def get_meetings_by_doctor(self, doctor_name: str) -> List[MeetingResponse]:
        """Get all meetings for a doctor"""
        meetings = await self.repository.get_meetings_by_doctor(doctor_name)
        return [
            MeetingResponse(
                meeting_id=meeting.meeting_id,
                meeting_link=meeting.meeting_link,
                customer_name=meeting.customer_name,
                doctor_name=meeting.doctor_name,
                slot_time=meeting.slot_time,
                customer_email=meeting.customer_email,
                doctor_email=meeting.doctor_email,
                status=meeting.status,
                created_at=meeting.created_at
            )
            for meeting in meetings
        ]
    
    async def update_meeting_status(self, meeting_id: str, status: str) -> Optional[MeetingResponse]:
        """Update meeting status"""
        meeting = await self.repository.update_meeting_status(meeting_id, status)
        if meeting:
            return MeetingResponse(
                meeting_id=meeting.meeting_id,
                meeting_link=meeting.meeting_link,
                customer_name=meeting.customer_name,
                doctor_name=meeting.doctor_name,
                slot_time=meeting.slot_time,
                customer_email=meeting.customer_email,
                doctor_email=meeting.doctor_email,
                status=meeting.status,
                created_at=meeting.created_at
            )
        return None
    
    async def delete_meeting(self, meeting_id: str) -> bool:
        """Delete a meeting by ID"""
        return await self.repository.delete_meeting(meeting_id)
    
    async def get_all_meetings(self, skip: int = 0, limit: int = 100) -> List[MeetingResponse]:
        """Get all meetings with pagination"""
        meetings = await self.repository.get_all_meetings(skip, limit)
        return [
            MeetingResponse(
                meeting_id=meeting.meeting_id,
                meeting_link=meeting.meeting_link,
                customer_name=meeting.customer_name,
                doctor_name=meeting.doctor_name,
                slot_time=meeting.slot_time,
                customer_email=meeting.customer_email,
                doctor_email=meeting.doctor_email,
                status=meeting.status,
                created_at=meeting.created_at
            )
            for meeting in meetings
        ]

import secrets
import string
from datetime import datetime
from typing import Optional, List
from app.config.settings import settings
from app.utils.validators import sanitize_name, validate_meeting_request
from app.models.meeting import MeetingRequest, MeetingResponse
from app.repositories.meeting_repository import MeetingRepository, InMemoryMeetingRepository

class MeetingService:
    """Service for handling meeting-related operations"""
    
    def __init__(self, repository: MeetingRepository = None):
        """Initialize service with repository dependency injection"""
        self.repository = repository or InMemoryMeetingRepository()
    
    @staticmethod
    def generate_meeting_id(customer_name: str, doctor_name: str) -> str:
        """Generate a unique meeting ID with timestamp and random string"""
        customer_clean = sanitize_name(customer_name)
        doctor_clean = sanitize_name(doctor_name)
        
        # Add timestamp for uniqueness
        timestamp = datetime.now().strftime("%Y%m%d_%H%M")
        
        # Add random string for additional uniqueness
        random_suffix = ''.join(secrets.choice(string.ascii_lowercase + string.digits) for _ in range(6))
        
        return f"{customer_clean}_{doctor_clean}_{timestamp}_{random_suffix}"
    
    @staticmethod
    def create_meeting_link(meeting_id: str) -> str:
        """Create Jitsi Meet link with configuration parameters"""
        return f"{settings.JITSI_BASE_URL}/{meeting_id}#{settings.JITSI_CONFIG_PARAMS}"
    
    async def generate_meeting(self, request: MeetingRequest) -> MeetingResponse:
        """Generate a new meeting with Jitsi Meet link and store it"""
        # Validate request
        is_valid, error_message = validate_meeting_request(
            request.customer_name, 
            request.doctor_name, 
            request.slot_time
        )
        
        if not is_valid:
            raise ValueError(error_message)
        
        # Generate meeting ID and link
        meeting_id = MeetingService.generate_meeting_id(request.customer_name, request.doctor_name)
        meeting_link = MeetingService.create_meeting_link(meeting_id)
        
        # Create meeting response
        meeting_response = MeetingResponse(
            meeting_link=meeting_link,
            meeting_id=meeting_id,
            customer_name=request.customer_name,
            doctor_name=request.doctor_name,
            slot_time=request.slot_time
        )
        
        # Store meeting in repository
        await self.repository.create_meeting(meeting_response)
        
        return meeting_response
    
    async def get_meeting_by_id(self, meeting_id: str) -> Optional[MeetingResponse]:
        """Get meeting by ID"""
        return await self.repository.get_meeting_by_id(meeting_id)
    
    async def get_meetings_by_customer(self, customer_name: str) -> List[MeetingResponse]:
        """Get all meetings for a customer"""
        return await self.repository.get_meetings_by_customer(customer_name)
    
    async def get_meetings_by_doctor(self, doctor_name: str) -> List[MeetingResponse]:
        """Get all meetings for a doctor"""
        return await self.repository.get_meetings_by_doctor(doctor_name)
    
    async def delete_meeting(self, meeting_id: str) -> bool:
        """Delete a meeting by ID"""
        return await self.repository.delete_meeting(meeting_id) 
from typing import Optional
from app.dto.meeting_dto import CreateMeetingRequestDTO, MeetingResponseDTO, EmailResponseDTO
from app.models.meeting import MeetingRequest, MeetingResponse, EmailResponse

class MeetingMapper:
    """Mapper for converting between DTOs and domain models"""
    
    @staticmethod
    def dto_to_domain(dto: CreateMeetingRequestDTO) -> MeetingRequest:
        """Convert CreateMeetingRequestDTO to MeetingRequest domain model"""
        return MeetingRequest(
            customer_name=dto.customer_name,
            doctor_name=dto.doctor_name,
            slot_time=dto.slot_time,
            customer_email=dto.customer_email,
            doctor_email=dto.doctor_email
        )
    
    @staticmethod
    def domain_to_response_dto(domain: MeetingResponse) -> MeetingResponseDTO:
        """Convert MeetingResponse domain model to MeetingResponseDTO"""
        return MeetingResponseDTO(
            meeting_link=domain.meeting_link,
            meeting_id=domain.meeting_id,
            customer_name=domain.customer_name,
            doctor_name=domain.doctor_name,
            slot_time=domain.slot_time,
            created_at=domain.created_at
        )
    
    @staticmethod
    def domain_to_email_dto(domain: EmailResponse) -> EmailResponseDTO:
        """Convert EmailResponse domain model to EmailResponseDTO"""
        return EmailResponseDTO(
            meeting_link=domain.meeting_link,
            meeting_id=domain.meeting_id,
            emails_sent=domain.emails_sent,
            message=domain.message
        )
    
    @staticmethod
    def create_email_response_dto(
        meeting_link: str,
        meeting_id: str,
        emails_sent: list[str],
        message: str
    ) -> EmailResponseDTO:
        """Create EmailResponseDTO from individual components"""
        return EmailResponseDTO(
            meeting_link=meeting_link,
            meeting_id=meeting_id,
            emails_sent=emails_sent,
            message=message
        ) 
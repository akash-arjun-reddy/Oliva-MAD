from fastapi import APIRouter, HTTPException, status, Depends
from app.dto.meeting_dto import (
    CreateMeetingRequestDTO, 
    MeetingResponseDTO, 
    EmailResponseDTO,
    ErrorResponseDTO
)
from app.dto.mappers import MeetingMapper
from app.services.meeting_service import MeetingService
from app.utils.email_utils import send_email_with_fallback
from app.repositories.meeting_repository import InMemoryMeetingRepository

router = APIRouter(prefix="/api/v1", tags=["meetings"])

# Dependency injection
def get_meeting_service() -> MeetingService:
    """Dependency to get meeting service instance"""
    repository = InMemoryMeetingRepository()
    return MeetingService(repository)

@router.get("/", response_model=dict)
async def root():
    """Health check endpoint"""
    return {"message": "Jitsi Meet Link Generator API"}

@router.post(
    "/generate-link", 
    response_model=MeetingResponseDTO,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponseDTO, "description": "Bad Request"},
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def generate_meeting_link(
    request: CreateMeetingRequestDTO,
    meeting_service: MeetingService = Depends(get_meeting_service)
):
    """Generate a unique Jitsi Meet link"""
    try:
        # Convert DTO to domain model
        domain_request = MeetingMapper.dto_to_domain(request)
        
        # Generate meeting using service
        meeting_response = await meeting_service.generate_meeting(domain_request)
        
        # Convert domain model to response DTO
        return MeetingMapper.domain_to_response_dto(meeting_response)
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Internal server error: {str(e)}"
        )

@router.post(
    "/send-email", 
    response_model=EmailResponseDTO,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponseDTO, "description": "Bad Request"},
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def send_meeting_email(
    request: CreateMeetingRequestDTO,
    meeting_service: MeetingService = Depends(get_meeting_service)
):
    """Generate a meeting link and send emails to both parties"""
    try:
        # Convert DTO to domain model
        domain_request = MeetingMapper.dto_to_domain(request)
        
        # Generate meeting first
        meeting_response = await meeting_service.generate_meeting(domain_request)
        
        # Send emails using new SendGrid system
        emails_sent = []
        
        # Customer email
        customer_subject = f"Oliva Clinic - Meeting Link for {request.customer_name}"
        customer_body = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Meeting Link</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 0 auto; background: white; }}
        .header {{ background: white; padding: 20px; text-align: center; border-bottom: 2px solid #20B2AA; }}
        .logo {{ font-size: 32px; font-weight: bold; color: #20B2AA; margin-bottom: 10px; }}
        .logo-o {{ font-size: 40px; color: #20B2AA; }}
        .subtitle {{ color: #666; font-size: 14px; margin: 5px 0; }}
        .clinic-text {{ color: #20B2AA; font-size: 16px; margin-top: 10px; }}
        .doctor-section {{ background: #f8f9fa; padding: 20px; text-align: center; }}
        .doctor-image {{ width: 120px; height: 120px; border-radius: 50%; background: #20B2AA; margin: 0 auto 15px; display: flex; align-items: center; justify-content: center; color: white; font-size: 48px; }}
        .welcome-banner {{ background: #333; color: white; padding: 15px; text-align: center; }}
        .sun-emoji {{ color: #FFD700; font-size: 18px; }}
        .content {{ background: #f9f9f9; padding: 20px; }}
        .meeting-details {{ background: white; padding: 15px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #20B2AA; }}
        .button {{ display: inline-block; background: #20B2AA; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 10px 0; }}
        .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">
                <span class="logo-o">O</span>LIVA
            </div>
            <div class="subtitle">SKIN • HAIR • BODY</div>
            <div class="clinic-text">CLINIC</div>
        </div>
        
        <div class="doctor-section">
            <div class="doctor-image">👩‍⚕️</div>
            <p style="margin: 0; color: #666;">Professional Care Team</p>
        </div>
        
        <div class="welcome-banner">
            <div>" Welcome to Oliva Skin & Hair Clinic "</div>
            <div class="sun-emoji">☀️ Your Journey with Oliva Starts Today!</div>
        </div>
        
        <div class="content">
            <p>Dear {request.customer_name},</p>
            <p>Your virtual consultation meeting link has been generated!</p>
            
            <div class="meeting-details">
                <h3>📅 Meeting Details</h3>
                <p><strong>Patient:</strong> {request.customer_name}</p>
                <p><strong>Doctor:</strong> {request.doctor_name}</p>
                <p><strong>Date:</strong> {request.slot_time}</p>
                <p><strong>Meeting Link:</strong> <a href="{meeting_response.meeting_link}">{meeting_response.meeting_link}</a></p>
            </div>
            
            <h3>📋 Instructions</h3>
            <ol>
                <li>Click the meeting link 5 minutes before your appointment</li>
                <li>Allow camera and microphone access when prompted</li>
                <li>Wait for the doctor to join the call</li>
            </ol>
            
            <h3>💡 Tips for the best experience</h3>
            <ul>
                <li>Use a stable internet connection</li>
                <li>Test your camera and microphone before joining</li>
                <li>Find a quiet, well-lit location</li>
                <li>Have your medical history ready if needed</li>
            </ul>
            
            <a href="{meeting_response.meeting_link}" class="button">Join Meeting</a>
        </div>
        <div class="footer">
            <p>Best regards,<br>Oliva Skin & Hair Clinic</p>
        </div>
    </div>
</body>
</html>
"""
        
        if request.customer_email:
            if send_email_with_fallback(request.customer_email, customer_subject, customer_body):
                emails_sent.append(f"Customer email sent to {request.customer_email}")
            else:
                emails_sent.append(f"Failed to send email to customer {request.customer_email}")
        
        # Doctor email
        doctor_subject = f"Oliva Clinic - New Meeting with {request.customer_name}"
        doctor_body = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>New Meeting</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 0 auto; background: white; }}
        .header {{ background: white; padding: 20px; text-align: center; border-bottom: 2px solid #20B2AA; }}
        .logo {{ font-size: 32px; font-weight: bold; color: #20B2AA; margin-bottom: 10px; }}
        .logo-o {{ font-size: 40px; color: #20B2AA; }}
        .subtitle {{ color: #666; font-size: 14px; margin: 5px 0; }}
        .clinic-text {{ color: #20B2AA; font-size: 16px; margin-top: 10px; }}
        .doctor-section {{ background: #f8f9fa; padding: 20px; text-align: center; }}
        .doctor-image {{ width: 120px; height: 120px; border-radius: 50%; background: #20B2AA; margin: 0 auto 15px; display: flex; align-items: center; justify-content: center; color: white; font-size: 48px; }}
        .welcome-banner {{ background: #333; color: white; padding: 15px; text-align: center; }}
        .sun-emoji {{ color: #FFD700; font-size: 18px; }}
        .content {{ background: #f9f9f9; padding: 20px; }}
        .meeting-details {{ background: white; padding: 15px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #20B2AA; }}
        .button {{ display: inline-block; background: #20B2AA; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 10px 0; }}
        .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">
                <span class="logo-o">O</span>LIVA
            </div>
            <div class="subtitle">SKIN • HAIR • BODY</div>
            <div class="clinic-text">CLINIC</div>
        </div>
        
        <div class="doctor-section">
            <div class="doctor-image">👩‍⚕️</div>
            <p style="margin: 0; color: #666;">Professional Care Team</p>
        </div>
        
        <div class="welcome-banner">
            <div>" Welcome to Oliva Skin & Hair Clinic "</div>
            <div class="sun-emoji">☀️ Your Journey with Oliva Starts Today!</div>
        </div>
        
        <div class="content">
            <p>Dear {request.doctor_name},</p>
            <p>You have a new virtual consultation scheduled!</p>
            
            <div class="meeting-details">
                <h3>📅 Meeting Details</h3>
                <p><strong>Patient:</strong> {request.customer_name}</p>
                <p><strong>Doctor:</strong> {request.doctor_name}</p>
                <p><strong>Date:</strong> {request.slot_time}</p>
                <p><strong>Meeting Link:</strong> <a href="{meeting_response.meeting_link}">{meeting_response.meeting_link}</a></p>
            </div>
            
            <p><strong>Please join the meeting 5 minutes before the scheduled time.</strong></p>
            
            <a href="{meeting_response.meeting_link}" class="button">Join Meeting</a>
        </div>
        <div class="footer">
            <p>Best regards,<br>Oliva Skin & Hair Clinic</p>
        </div>
    </div>
</body>
</html>
"""
        
        if request.doctor_email:
            if send_email_with_fallback(request.doctor_email, doctor_subject, doctor_body):
                emails_sent.append(f"Doctor email sent to {request.doctor_email}")
            else:
                emails_sent.append(f"Failed to send email to doctor {request.doctor_email}")
        
        # Create response DTO
        return MeetingMapper.create_email_response_dto(
            meeting_link=meeting_response.meeting_link,
            meeting_id=meeting_response.meeting_id,
            emails_sent=emails_sent,
            message="Jitsi Meet link generated and emails sent"
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Internal server error: {str(e)}"
        )

@router.get(
    "/meetings/{meeting_id}",
    response_model=MeetingResponseDTO,
    responses={
        404: {"model": ErrorResponseDTO, "description": "Meeting not found"},
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def get_meeting(
    meeting_id: str,
    meeting_service: MeetingService = Depends(get_meeting_service)
):
    """Get meeting by ID"""
    try:
        meeting = await meeting_service.get_meeting_by_id(meeting_id)
        if not meeting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Meeting not found"
            )
        return MeetingMapper.domain_to_response_dto(meeting)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        ) 
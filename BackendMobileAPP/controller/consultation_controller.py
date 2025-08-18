from fastapi import APIRouter, HTTPException, status, Depends, Query
from typing import List, Optional
from dto.meeting_schema import (
    CreateMeetingRequest, 
    MeetingResponse, 
    EmailResponse,
    ErrorResponse,
    MeetingListResponse
)
from service.consultation_service import ConsultationService
from repository.meeting_repository import get_meeting_repository

router = APIRouter(prefix="/api/v1/consultation", tags=["consultation"])

# Dependency injection
def get_consultation_service() -> ConsultationService:
    """Dependency to get consultation service instance"""
    repository = get_meeting_repository()
    return ConsultationService(repository)

@router.get("/", response_model=dict)
async def root():
    """Health check endpoint"""
    return {"message": "Oliva Clinic Consultation API"}

@router.post(
    "/generate-meeting", 
    response_model=MeetingResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponse, "description": "Bad Request"},
        500: {"model": ErrorResponse, "description": "Internal Server Error"}
    }
)
async def generate_meeting_link(
    request: CreateMeetingRequest,
    consultation_service: ConsultationService = Depends(get_consultation_service)
):
    """Generate a unique Jitsi Meet link for consultation"""
    try:
        meeting_response = await consultation_service.generate_meeting(request)
        return meeting_response
        
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
    "/send-meeting-email", 
    response_model=EmailResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponse, "description": "Bad Request"},
        500: {"model": ErrorResponse, "description": "Internal Server Error"}
    }
)
async def send_meeting_email(
    request: CreateMeetingRequest,
    consultation_service: ConsultationService = Depends(get_consultation_service)
):
    """Generate a meeting link and send emails to both parties"""
    try:
        email_response = await consultation_service.send_meeting_emails(request)
        return email_response
        
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
    "/meeting/{meeting_id}",
    response_model=MeetingResponse,
    responses={
        404: {"model": ErrorResponse, "description": "Meeting not found"},
        500: {"model": ErrorResponse, "description": "Internal Server Error"}
    }
)
async def get_meeting(
    meeting_id: str,
    consultation_service: ConsultationService = Depends(get_consultation_service)
):
    """Get meeting details by meeting ID"""
    try:
        meeting = await consultation_service.get_meeting_by_id(meeting_id)
        if not meeting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Meeting not found"
            )
        return meeting
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get(
    "/meetings/customer/{customer_name}",
    response_model=List[MeetingResponse],
    responses={
        500: {"model": ErrorResponse, "description": "Internal Server Error"}
    }
)
async def get_meetings_by_customer(
    customer_name: str,
    consultation_service: ConsultationService = Depends(get_consultation_service)
):
    """Get all meetings for a specific customer"""
    try:
        meetings = await consultation_service.get_meetings_by_customer(customer_name)
        return meetings
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get(
    "/meetings/doctor/{doctor_name}",
    response_model=List[MeetingResponse],
    responses={
        500: {"model": ErrorResponse, "description": "Internal Server Error"}
    }
)
async def get_meetings_by_doctor(
    doctor_name: str,
    consultation_service: ConsultationService = Depends(get_consultation_service)
):
    """Get all meetings for a specific doctor"""
    try:
        meetings = await consultation_service.get_meetings_by_doctor(doctor_name)
        return meetings
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get(
    "/meetings",
    response_model=MeetingListResponse,
    responses={
        500: {"model": ErrorResponse, "description": "Internal Server Error"}
    }
)
async def get_all_meetings(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return"),
    consultation_service: ConsultationService = Depends(get_consultation_service)
):
    """Get all meetings with pagination"""
    try:
        meetings = await consultation_service.get_all_meetings(skip, limit)
        return MeetingListResponse(meetings=meetings, total=len(meetings))
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.put(
    "/meeting/{meeting_id}/status",
    response_model=MeetingResponse,
    responses={
        404: {"model": ErrorResponse, "description": "Meeting not found"},
        400: {"model": ErrorResponse, "description": "Invalid status"},
        500: {"model": ErrorResponse, "description": "Internal Server Error"}
    }
)
async def update_meeting_status(
    meeting_id: str,
    status: str,
    consultation_service: ConsultationService = Depends(get_consultation_service)
):
    """Update meeting status (active, completed, cancelled)"""
    try:
        # Validate status
        valid_statuses = ["active", "completed", "cancelled"]
        if status not in valid_statuses:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid status. Must be one of: {', '.join(valid_statuses)}"
            )
        
        meeting = await consultation_service.update_meeting_status(meeting_id, status)
        if not meeting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Meeting not found"
            )
        return meeting
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.delete(
    "/meeting/{meeting_id}",
    response_model=dict,
    responses={
        404: {"model": ErrorResponse, "description": "Meeting not found"},
        500: {"model": ErrorResponse, "description": "Internal Server Error"}
    }
)
async def delete_meeting(
    meeting_id: str,
    consultation_service: ConsultationService = Depends(get_consultation_service)
):
    """Delete a meeting by ID"""
    try:
        success = await consultation_service.delete_meeting(meeting_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Meeting not found"
            )
        return {"message": "Meeting deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get(
    "/doctors",
    response_model=dict,
    responses={
        500: {"model": ErrorResponse, "description": "Internal Server Error"}
    }
)
async def get_available_doctors():
    """Get list of available doctors for consultation"""
    try:
        from config.settings import settings
        return {
            "doctors": list(settings.DOCTOR_EMAILS.keys()),
            "total": len(settings.DOCTOR_EMAILS)
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

from fastapi import APIRouter, HTTPException, status, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database.connection import get_db
from app.dto.doctor_dto import (
    DoctorCreateDTO,
    DoctorUpdateDTO,
    DoctorResponseDTO,
    DoctorListResponseDTO
)
from app.services.doctor_service import DoctorService
from app.dto.meeting_dto import ErrorResponseDTO

router = APIRouter(prefix="/api/v1/doctors", tags=["doctors"])

def get_doctor_service(db: Session = Depends(get_db)) -> DoctorService:
    """Dependency to get doctor service instance"""
    return DoctorService(db)

@router.post(
    "/",
    response_model=DoctorResponseDTO,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponseDTO, "description": "Bad Request"},
        409: {"model": ErrorResponseDTO, "description": "Doctor email already exists"},
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def create_doctor(
    doctor_data: DoctorCreateDTO,
    doctor_service: DoctorService = Depends(get_doctor_service)
):
    """Create a new doctor"""
    try:
        return doctor_service.create_doctor(doctor_data)
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
    "/{doctor_id}",
    response_model=DoctorResponseDTO,
    responses={
        404: {"model": ErrorResponseDTO, "description": "Doctor not found"},
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def get_doctor(
    doctor_id: int,
    doctor_service: DoctorService = Depends(get_doctor_service)
):
    """Get doctor by ID"""
    try:
        doctor = doctor_service.get_doctor(doctor_id)
        if not doctor:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Doctor not found"
            )
        return doctor
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get(
    "/",
    response_model=DoctorListResponseDTO,
    responses={
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def get_doctors(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return"),
    active_only: bool = Query(True, description="Show only active doctors"),
    doctor_service: DoctorService = Depends(get_doctor_service)
):
    """Get all doctors with pagination"""
    try:
        return doctor_service.get_all_doctors(skip, limit, active_only)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.put(
    "/{doctor_id}",
    response_model=DoctorResponseDTO,
    responses={
        400: {"model": ErrorResponseDTO, "description": "Bad Request"},
        404: {"model": ErrorResponseDTO, "description": "Doctor not found"},
        409: {"model": ErrorResponseDTO, "description": "Doctor email already exists"},
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def update_doctor(
    doctor_id: int,
    doctor_data: DoctorUpdateDTO,
    doctor_service: DoctorService = Depends(get_doctor_service)
):
    """Update doctor information"""
    try:
        doctor = doctor_service.update_doctor(doctor_id, doctor_data)
        if not doctor:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Doctor not found"
            )
        return doctor
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.delete(
    "/{doctor_id}",
    responses={
        404: {"model": ErrorResponseDTO, "description": "Doctor not found"},
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def delete_doctor(
    doctor_id: int,
    doctor_service: DoctorService = Depends(get_doctor_service)
):
    """Soft delete doctor (set as inactive)"""
    try:
        success = doctor_service.delete_doctor(doctor_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Doctor not found"
            )
        return {"message": "Doctor deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get(
    "/search",
    response_model=DoctorListResponseDTO,
    responses={
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def search_doctors(
    q: str = Query(..., description="Search query for doctor name or specialty"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return"),
    doctor_service: DoctorService = Depends(get_doctor_service)
):
    """Search doctors by name or specialty"""
    try:
        return doctor_service.search_doctors(q, skip, limit)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get(
    "/specialty/{specialty}",
    response_model=DoctorListResponseDTO,
    responses={
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def get_doctors_by_specialty(
    specialty: str,
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return"),
    doctor_service: DoctorService = Depends(get_doctor_service)
):
    """Get doctors by specialty"""
    try:
        return doctor_service.get_doctors_by_specialty(specialty, skip, limit)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get(
    "/active",
    response_model=list[DoctorResponseDTO],
    responses={
        500: {"model": ErrorResponseDTO, "description": "Internal Server Error"}
    }
)
async def get_active_doctors(
    doctor_service: DoctorService = Depends(get_doctor_service)
):
    """Get all active doctors"""
    try:
        return doctor_service.get_active_doctors()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

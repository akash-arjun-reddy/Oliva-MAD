import secrets
import string
from datetime import date, datetime
from typing import List, Optional
from sqlalchemy.orm import Session
from app.repositories.appointment_repository import AppointmentRepository
from app.repositories.doctor_repository import DoctorRepository
from app.repositories.patient_repository import PatientRepository
from app.dto.appointment_dto import (
    AppointmentCreateDTO, 
    AppointmentUpdateDTO, 
    AppointmentResponseDTO,
    DoctorAvailabilityDTO,
    TimeSlotDTO
)
from app.utils.email_utils import send_appointment_details_email, send_alert_to_admin
from app.models.appointment import Appointment
import logging

logger = logging.getLogger(__name__)

class AppointmentService:
    """Service for appointment business logic"""
    
    def __init__(self, db: Session):
        self.db = db
        self.appointment_repo = AppointmentRepository(db)
        self.doctor_repo = DoctorRepository(db)
        self.patient_repo = PatientRepository(db)
    
    def create_appointment(self, appointment_data: AppointmentCreateDTO) -> AppointmentResponseDTO:
        """Create a new appointment with meeting link and passcode"""
        try:
            # Validate doctor exists
            doctor = self.doctor_repo.get_by_id(appointment_data.doctor_id)
            if not doctor:
                raise ValueError(f"Doctor with ID {appointment_data.doctor_id} not found")
            
            # Check availability
            if not self.appointment_repo.check_availability(
                appointment_data.doctor_id, 
                appointment_data.appointment_date, 
                appointment_data.time_slot
            ):
                raise ValueError(f"Time slot {appointment_data.time_slot} is not available for the selected date")
            
            # Generate unique meeting link and passcode
            meeting_link = self._generate_meeting_link(doctor.name, appointment_data.patient_name)
            passcode = self._generate_passcode()
            
            # Create appointment
            appointment = self.appointment_repo.create(appointment_data, meeting_link, passcode)
            
            # Send emails with proper error handling
            self._send_appointment_emails(appointment, doctor)
            
            return self._appointment_to_response_dto(appointment, doctor)
            
        except Exception as e:
            logger.error(f"❌ Error creating appointment: {str(e)}")
            raise e
    
    def get_appointment(self, appointment_id: int) -> Optional[AppointmentResponseDTO]:
        """Get appointment by ID"""
        appointment = self.appointment_repo.get_by_id(appointment_id)
        if not appointment:
            return None
        
        doctor = self.doctor_repo.get_by_id(appointment.doctor_id)
        return self._appointment_to_response_dto(appointment, doctor)
    
    def update_appointment(self, appointment_id: int, appointment_data: AppointmentUpdateDTO) -> Optional[AppointmentResponseDTO]:
        """Update appointment"""
        appointment = self.appointment_repo.get_by_id(appointment_id)
        if not appointment:
            return None
        
        # If date or time is being changed, check availability
        if appointment_data.appointment_date or appointment_data.time_slot:
            new_date = appointment_data.appointment_date or appointment.date.strftime("%Y-%m-%d")
            new_time = appointment_data.time_slot or appointment.time_slot
            
            if not self.appointment_repo.check_availability(
                appointment.doctor_id, new_date, new_time
            ):
                raise ValueError(f"Time slot {new_time} is not available for the selected date")
        
        updated_appointment = self.appointment_repo.update(appointment_id, appointment_data)
        if not updated_appointment:
            return None
        
        doctor = self.doctor_repo.get_by_id(updated_appointment.doctor_id)
        return self._appointment_to_response_dto(updated_appointment, doctor)
    
    def cancel_appointment(self, appointment_id: int) -> Optional[AppointmentResponseDTO]:
        """Cancel appointment"""
        appointment = self.appointment_repo.update_status(appointment_id, "cancelled")
        if not appointment:
            return None
        
        doctor = self.doctor_repo.get_by_id(appointment.doctor_id)
        return self._appointment_to_response_dto(appointment, doctor)
    
    def get_doctor_availability(self, doctor_id: int, appointment_date: str) -> DoctorAvailabilityDTO:
        """Get available time slots for a doctor on a specific date"""
        try:
            # Get available and booked slots
            available_slots = self.appointment_repo.get_available_slots(doctor_id, appointment_date)
            booked_slots = self.appointment_repo.get_booked_slots(doctor_id, appointment_date)
            
            return DoctorAvailabilityDTO(
                doctor_id=doctor_id,
                appointment_date=appointment_date,
                available_slots=available_slots,
                booked_slots=booked_slots
            )
            
        except Exception as e:
            logger.error(f"❌ Error getting doctor availability: {str(e)}")
            raise Exception(f"Error getting doctor availability: {str(e)}")

    def get_all_booked_slots(self) -> List[dict]:
        """Get all booked slots for frontend"""
        try:
            return self.appointment_repo.get_all_booked_slots()
        except Exception as e:
            logger.error(f"❌ Error getting booked slots: {str(e)}")
            raise Exception(f"Error getting booked slots: {str(e)}")
    
    def get_all_appointments(self, skip: int = 0, limit: int = 100, status: str = None) -> List[AppointmentResponseDTO]:
        """Get all appointments with pagination"""
        appointments = self.appointment_repo.get_all(skip, limit, status)
        result = []
        
        for appointment in appointments:
            doctor = self.doctor_repo.get_by_id(appointment.doctor_id)
            result.append(self._appointment_to_response_dto(appointment, doctor))
        
        return result
    
    def get_appointments_by_doctor(self, doctor_id: int, skip: int = 0, limit: int = 100) -> List[AppointmentResponseDTO]:
        """Get appointments by doctor"""
        appointments = self.appointment_repo.get_by_doctor(doctor_id, skip, limit)
        result = []
        
        for appointment in appointments:
            doctor = self.doctor_repo.get_by_id(appointment.doctor_id)
            result.append(self._appointment_to_response_dto(appointment, doctor))
        
        return result
    
    def _generate_meeting_link(self, doctor_name: str, patient_name: str) -> str:
        """Generate unique meeting link"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        random_suffix = ''.join(secrets.choice(string.ascii_lowercase + string.digits) for _ in range(6))
        
        # Clean names for URL
        clean_doctor = doctor_name.replace(' ', '_').replace('.', '').replace('Dr_', '')
        clean_patient = patient_name.replace(' ', '_')
        
        meeting_id = f"Oliva_{clean_doctor}_{clean_patient}_{timestamp}_{random_suffix}"
        return f"https://meet.jit.si/{meeting_id}"
    
    def _generate_passcode(self) -> str:
        """Generate secure passcode"""
        return ''.join(secrets.choice(string.ascii_uppercase + string.digits) for _ in range(6))
    
    def _send_appointment_emails(self, appointment, doctor):
        """Send emails to doctor and patient with proper error handling"""
        try:
            # Get patient details
            patient = self.patient_repo.get_by_id(appointment.patient_id)
            
            # Send emails using the new email utilities
            email_sent = send_appointment_details_email(
                patient_email=patient.email,
                doctor_email=doctor.email,
                appointment=appointment
            )
            
            if email_sent:
                logger.info(f"✅ Appointment emails sent successfully for appointment {appointment.id}")
                # Update email sent flags
                appointment.doctor_email_sent = True
                appointment.patient_email_sent = True
                self.db.commit()
            else:
                logger.warning(f"⚠️ Failed to send appointment emails for appointment {appointment.id}")
                # Send alert to admin
                send_alert_to_admin(
                    f"📢 Appointment booked (ID: {appointment.id}), but email failed to send"
                )
                
        except Exception as e:
            logger.error(f"❌ Failed to send appointment emails: {str(e)}")
            # Send alert to admin
            send_alert_to_admin(
                f"📢 Appointment booked (ID: {appointment.id}), but email error: {str(e)}"
            )
    
    def _appointment_to_response_dto(self, appointment, doctor) -> AppointmentResponseDTO:
        """Convert appointment model to response DTO"""
        patient = self.patient_repo.get_by_id(appointment.patient_id)
        
        return AppointmentResponseDTO(
            id=appointment.id,
            doctor_id=appointment.doctor_id,
            doctor_name=doctor.name,
            patient_id=appointment.patient_id,
            patient_name=patient.name,
            patient_email=patient.email,
            concern=appointment.concern,
            appointment_date=appointment.date.strftime("%Y-%m-%d"),
            time_slot=appointment.time_slot,
            meeting_link=appointment.meeting_link,
            passcode=appointment.passcode,
            created_at=appointment.created_at
        )

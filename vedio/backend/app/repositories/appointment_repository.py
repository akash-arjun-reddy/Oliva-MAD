from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from typing import List, Optional
from datetime import date, datetime
from app.models.appointment import Appointment
from app.models.doctor import Doctor
from app.models.patient import Patient
from app.dto.appointment_dto import AppointmentCreateDTO

class AppointmentRepository:
    """Repository for appointment database operations"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def create(self, appointment_data: AppointmentCreateDTO, meeting_link: str, passcode: str) -> Appointment:
        """Create a new appointment"""
        # Get or create patient
        patient_repo = PatientRepository(self.db)
        patient = patient_repo.get_or_create_by_email(
            appointment_data.patient_name, 
            appointment_data.patient_email
        )
        
        # Parse appointment date
        appointment_date = datetime.strptime(appointment_data.appointment_date, "%Y-%m-%d")
        
        # Create appointment
        appointment = Appointment(
            doctor_id=appointment_data.doctor_id,
            patient_id=patient.id,
            date=appointment_date,
            time_slot=appointment_data.time_slot,
            meeting_link=meeting_link,
            passcode=passcode,
            concern=appointment_data.concern,
            status="scheduled"
        )
        self.db.add(appointment)
        self.db.commit()
        self.db.refresh(appointment)
        return appointment
    
    def get_by_id(self, appointment_id: int) -> Optional[Appointment]:
        """Get appointment by ID"""
        return self.db.query(Appointment).filter(Appointment.id == appointment_id).first()
    
    def get_by_meeting_link(self, meeting_link: str) -> Optional[Appointment]:
        """Get appointment by meeting link"""
        return self.db.query(Appointment).filter(Appointment.meeting_link == meeting_link).first()
    
    def get_all(self, skip: int = 0, limit: int = 100, status: str = None) -> List[Appointment]:
        """Get all appointments with pagination"""
        query = self.db.query(Appointment)
        if status:
            query = query.filter(Appointment.status == status)
        return query.offset(skip).limit(limit).all()
    
    def get_by_doctor(self, doctor_id: int, skip: int = 0, limit: int = 100) -> List[Appointment]:
        """Get appointments by doctor"""
        return self.db.query(Appointment).filter(
            Appointment.doctor_id == doctor_id
        ).offset(skip).limit(limit).all()
    
    def get_by_patient(self, patient_id: int, skip: int = 0, limit: int = 100) -> List[Appointment]:
        """Get appointments by patient"""
        return self.db.query(Appointment).filter(
            Appointment.patient_id == patient_id
        ).offset(skip).limit(limit).all()
    
    def get_by_date_range(self, start_date: str, end_date: str, doctor_id: int = None) -> List[Appointment]:
        """Get appointments within date range"""
        query = self.db.query(Appointment).filter(
            and_(
                Appointment.date >= start_date,
                Appointment.date <= end_date
            )
        )
        if doctor_id:
            query = query.filter(Appointment.doctor_id == doctor_id)
        return query.all()
    
    def update_status(self, appointment_id: int, status: str) -> Optional[Appointment]:
        """Update appointment status"""
        appointment = self.get_by_id(appointment_id)
        if not appointment:
            return None
        
        appointment.status = status
        self.db.commit()
        self.db.refresh(appointment)
        return appointment
    
    def delete(self, appointment_id: int) -> bool:
        """Delete appointment"""
        appointment = self.get_by_id(appointment_id)
        if not appointment:
            return False
        
        self.db.delete(appointment)
        self.db.commit()
        return True
    
    def check_availability(self, doctor_id: int, appointment_date: str, time_slot: str) -> bool:
        """Check if a time slot is available for a doctor on a specific date"""
        # Parse the date string to datetime
        date_obj = datetime.strptime(appointment_date, "%Y-%m-%d")
        
        existing_appointment = self.db.query(Appointment).filter(
            and_(
                Appointment.doctor_id == doctor_id,
                Appointment.date == date_obj,
                Appointment.time_slot == time_slot,
                Appointment.status.in_(["scheduled", "confirmed"])
            )
        ).first()
        return existing_appointment is None
    
    def get_available_slots(self, doctor_id: int, appointment_date: str) -> List[str]:
        """Get available time slots for a doctor on a specific date"""
        # Parse the date string to datetime
        date_obj = datetime.strptime(appointment_date, "%Y-%m-%d")
        
        # Define all possible time slots (15-minute intervals from 8 AM to 6 PM)
        all_slots = []
        for hour in range(8, 18):  # 8 AM to 6 PM
            for minute in [0, 15, 30, 45]:
                time_str = f"{hour:02d}:{minute:02d}"
                all_slots.append(time_str)
        
        # Get booked slots for this doctor and date
        booked_slots = self.db.query(Appointment.time_slot).filter(
            and_(
                Appointment.doctor_id == doctor_id,
                Appointment.date == date_obj,
                Appointment.status.in_(["scheduled", "confirmed"])
            )
        ).all()
        
        booked_times = [slot[0] for slot in booked_slots]
        available_slots = [slot for slot in all_slots if slot not in booked_times]
        
        return available_slots
    
    def get_booked_slots(self, doctor_id: int, appointment_date: str) -> List[str]:
        """Get booked time slots for a doctor on a specific date"""
        # Parse the date string to datetime
        date_obj = datetime.strptime(appointment_date, "%Y-%m-%d")
        
        booked_slots = self.db.query(Appointment.time_slot).filter(
            and_(
                Appointment.doctor_id == doctor_id,
                Appointment.date == date_obj,
                Appointment.status.in_(["scheduled", "confirmed"])
            )
        ).all()
        
        return [slot[0] for slot in booked_slots]
    
    def get_all_booked_slots(self) -> List[dict]:
        """Get all booked slots for frontend"""
        appointments = self.db.query(Appointment).filter(
            Appointment.status.in_(["scheduled", "confirmed"])
        ).all()
        
        booked_slots = []
        for appointment in appointments:
            booked_slots.append({
                "doctor_id": appointment.doctor_id,
                "date": appointment.date.strftime("%Y-%m-%d"),
                "time_slot": appointment.time_slot
            })
        
        return booked_slots
    
    def count(self, status: str = None) -> int:
        """Count total appointments"""
        query = self.db.query(Appointment)
        if status:
            query = query.filter(Appointment.status == status)
        return query.count()
    
    def get_appointments_with_details(self, skip: int = 0, limit: int = 100) -> List[dict]:
        """Get appointments with doctor and patient details"""
        appointments = self.db.query(
            Appointment,
            Doctor.name.label('doctor_name'),
            Doctor.email.label('doctor_email'),
            Doctor.specialty.label('doctor_specialty'),
            Patient.name.label('patient_name'),
            Patient.email.label('patient_email')
        ).join(Doctor).join(Patient).offset(skip).limit(limit).all()
        
        result = []
        for appointment, doctor_name, doctor_email, doctor_specialty, patient_name, patient_email in appointments:
            result.append({
                'appointment': appointment,
                'doctor_name': doctor_name,
                'doctor_email': doctor_email,
                'doctor_specialty': doctor_specialty,
                'patient_name': patient_name,
                'patient_email': patient_email
            })
        
        return result

class PatientRepository:
    """Repository for patient database operations"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_or_create_by_email(self, name: str, email: str) -> Patient:
        """Get existing patient or create new one"""
        patient = self.db.query(Patient).filter(Patient.email == email).first()
        if not patient:
            patient = Patient(name=name, email=email)
            self.db.add(patient)
            self.db.commit()
            self.db.refresh(patient)
        return patient

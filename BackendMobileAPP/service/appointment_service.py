from datetime import datetime, time, timedelta
from sqlalchemy.orm import Session
from typing import List
import uuid
import os
import logging

from models.appointment import Appointment, AppointmentWalkin
from dto.appointment_schema import AppointmentCreateDTO, AppointmentResponseDTO
from repository.appointment_repo import WalkinAppointmentRepository
from utils.email_utils import send_appointment_details_email, send_reminder_email
from utils.ics_utils import generate_ics_file
from constants.status_codes import STATUS_MAP

# Optional admin alert
try:
    from utils.admin_alert import send_alert_to_admin
except:
    def send_alert_to_admin(msg: str):
        logging.warning(f"🔔 ADMIN ALERT: {msg}")

# Logging setup
logger = logging.getLogger("uvicorn.error")

# Singleton-safe scheduler
scheduler = None
if os.getenv("RUN_MAIN") != "true":
    from apscheduler.schedulers.background import BackgroundScheduler
    scheduler = BackgroundScheduler()
    scheduler.start()


class AppointmentService:
    @staticmethod
    def generate_time_slots(start: time, end: time, interval_minutes: int = 15) -> List[tuple]:
        slots = []
        current = datetime.combine(datetime.today(), start)
        end_dt = datetime.combine(datetime.today(), end)
        while current < end_dt:
            slot_end = current + timedelta(minutes=interval_minutes)
            slots.append((current.time(), slot_end.time()))
            current = slot_end
        return slots

    @staticmethod
    def get_available_slots(db: Session, doctor_id: int, date_: datetime.date) -> List[tuple]:
        all_slots = AppointmentService.generate_time_slots(time(10, 0), time(18, 0))
        booked = db.query(Appointment).filter_by(doctor_id=doctor_id, date=date_).all()
        booked_slots = {(a.start_time, a.end_time) for a in booked}
        return [slot for slot in all_slots if slot not in booked_slots]

    @staticmethod
    def book_appointment(db: Session, patient_id: int, data: AppointmentCreateDTO):
        existing = db.query(Appointment).filter_by(
            doctor_id=data.doctor_id,
            date=data.date,
            start_time=data.start_time,
            end_time=data.end_time
        ).first()

        if existing:
            logger.warning("❌ Slot already booked for doctor %s on %s %s–%s",
                           data.doctor_id, data.date, data.start_time, data.end_time)
            raise Exception("Slot already booked")

        appointment = Appointment(
            appointment_id=str(uuid.uuid4()),
            patient_id=patient_id,
            doctor_id=data.doctor_id,
            date=data.date,
            start_time=data.start_time,
            end_time=data.end_time,
            video_call_link=f"https://meet.jit.si/{uuid.uuid4()}",
            status=STATUS_MAP["Scheduled"]
        )

        try:
            db.add(appointment)
            db.commit()
            db.refresh(appointment)
        except Exception as db_err:
            db.rollback()
            logger.error("❌ DB Error while booking appointment: %s", str(db_err))
            raise Exception("Failed to save appointment")

        try:
            patient = db.query(Appointment.patient.property.mapper.class_).filter_by(id=patient_id).first()
            doctor = db.query(Appointment.doctor.property.mapper.class_).filter_by(id=data.doctor_id).first()

            patient_email = getattr(patient, 'email', None)
            doctor_email = getattr(doctor, 'email', None)

            if patient_email and doctor_email:
                # 1. Generate .ics file
                ics_path = generate_ics_file(appointment)

                # 2. Send email with .ics attachment
                send_appointment_details_email(patient_email, doctor_email, appointment)

                # 3. Schedule reminder
                appointment_time = datetime.combine(appointment.date, appointment.start_time)
                reminder_time = appointment_time - timedelta(minutes=10)

                if scheduler:
                    scheduler.add_job(
                        send_reminder_email,
                        'date',
                        run_date=reminder_time,
                        args=[patient_email, doctor_email, appointment]
                    )

        except Exception as post_error:
            logger.warning("⚠️ Post-processing failed: %s", str(post_error))
            try:
                send_alert_to_admin(
                    f"📢 Appointment booked (ID: {appointment.appointment_id}), but email/reminder failed: {post_error}"
                )
            except Exception as alert_err:
                logger.error("❌ Failed to notify admin: %s", str(alert_err))

        return {
            "message": "✅ Appointment booked successfully",
            "appointmentId": appointment.appointment_id,
            "videoCallLink": appointment.video_call_link,
            "note": "⚠️ Calendar invite or reminder might not have been sent due to an error.",
            "data": AppointmentResponseDTO.from_orm(appointment)
        }

    @staticmethod
    def get_by_guest_id(guest_id: str, db: Session) -> List:
        return db.query(
            Appointment.appointment_id,
            Appointment.invoice_id,
            Appointment.service_name,
            Appointment.service_id,
            Appointment.status,
            Appointment.guest_id,
            Appointment.form_id,
            Appointment.center_id,
            Appointment.creation_date_utc
        ).filter(Appointment.guest_id == guest_id).all()

    @staticmethod
    def get_walkin_by_appointment_id(appointment_id: str, db: Session) -> List[AppointmentWalkin]:
        return WalkinAppointmentRepository.get_by_appointment_id(appointment_id, db)

    @staticmethod
    def get_appointment_by_id(appointment_id: str, db: Session):
        appointment = db.query(Appointment).filter(Appointment.appointment_id == appointment_id).first()
        if not appointment:
            raise Exception("Appointment not found")
        return appointment

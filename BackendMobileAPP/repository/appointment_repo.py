from sqlalchemy.orm import Session

from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import cast

from models.appointment import Appointment


class AppointmentRepository:
    @staticmethod
    def get_appointments_by_guest_id(db: Session, guest_id: str):
        print(f"[DEBUG] Fetching appointments for guest_id: {guest_id}")

        result = (
            db.query(Appointment)
            .filter(Appointment.guest_id == guest_id)
            .order_by(Appointment.creation_date_utc.desc())
            .all()
        )
        print(f"[DEBUG] Found {len(result)} appointment(s)")
        return result


class WalkinAppointmentRepository:
    @staticmethod
    def get_by_appointment_id_if_authorized(appointment_id: str, guest_id: str, db: Session):
        return db.query(AppointmentWalkin).join(Appointment, 
            cast(AppointmentWalkin.appointment_id, UUID) == cast(Appointment.appointment_id, UUID)
        ).filter(
            AppointmentWalkin.appointment_id == appointment_id,
            Appointment.guest_id == guest_id
        ).all()

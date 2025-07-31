from sqlalchemy.orm import Session

from models.booking_model import Booking, ReservedSlot, ConfirmedBooking


class BookingRepository:
    @staticmethod
    def save_booking(db: Session, booking: Booking):
        db.add(booking)
        db.commit()
        db.refresh(booking)
        return booking

    @staticmethod
    def save_reserved_slot(db: Session, slot: ReservedSlot):
        db.add(slot)
        db.commit()
        db.refresh(slot)
        return slot
    
    
 
    @staticmethod
    def save_confirmed_booking(db: Session, booking: ConfirmedBooking):
        db.add(booking)
        db.commit()
        db.refresh(booking)
        return booking

    
    @staticmethod
    def delete_booking_by_invoice_id(db: Session, invoice_id: str):
        booking = db.query(Booking).filter(Booking.booking_id == invoice_id).first()
        if booking:
            db.delete(booking)
            db.commit()
            return True
        return False
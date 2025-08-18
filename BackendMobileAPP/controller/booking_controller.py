from fastapi import APIRouter, Depends, HTTPException,Path,Query 
from sqlalchemy.orm import Session

import httpx


from fastapi import Body
import traceback
import logging

from database.session import get_db
from dto.booking_schema import BookingResponse, BookingCreate, ReserveSlotRequest, \
    RescheduleBookingRequest
from models.user import User
from security.jwt import get_current_user
from service.booking_service import BookingService

router = APIRouter(prefix="/booking", tags=["Service Booking"])

logger = logging.getLogger("uvicorn")

@router.post("/create", response_model=BookingResponse)
async def create_service_booking(
    payload: BookingCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    try:
        booking = await BookingService.create_booking(payload, db, current_user)
        return {
        "booking_id": str(booking.booking_id),
        "status": "created", 
        "cancelled_at": None,
        "cancel_comments": None
}
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=400, detail=str(e) or "Unknown error")

@router.get("/{booking_id}/slots")
async def get_available_slots(
    booking_id: str = Path(..., description="Zenoti booking ID"),
    check_future_day_availability: bool = Query(False, description="Check availability for future days"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    try:
        logger.info(f"Fetching slots for booking_id={booking_id}, check_future_day_availability={check_future_day_availability}")
        slots = await BookingService.get_available_slots(
            booking_id=booking_id,
            check_future_day_availability=check_future_day_availability,
            db=db,
            current_user=current_user
        )
        return slots
    except Exception as e:
        logger.error(f"Error fetching slots: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch available slots")
    
@router.post("/{booking_id}/slots/reserve")
async def reserve_slot(
    booking_id: str = Path(..., description="Zenoti Booking ID"),
    payload: ReserveSlotRequest = Body(...),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    try:
        return await BookingService.reserve_slot(booking_id, payload, db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.post("/{booking_id}/slots/confirm")
async def confirm_booking(
    booking_id: str = Path(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    try:
        confirmed = await BookingService.confirm_booking(booking_id, db)
        return {"status": "confirmed", "appointment_id": confirmed.appointment_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/invoices/{invoice_id}/cancel")
async def cancel_invoice(
    invoice_id: str = Path(..., description="Invoice ID to cancel"),
    comments: str = Query(..., description="Reason for cancellation"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        logger.info(f"Request to cancel invoice_id={invoice_id} by user_id={current_user.id}, email={current_user.email}")

        result = await BookingService.cancel_invoice(invoice_id, comments, db, current_user)
        return {"status": "cancelled", "invoice_id": invoice_id, "message": result}
    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error(f"Failed to cancel invoice: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@router.post("/reschedule")
async def reschedule_service(payload: RescheduleBookingRequest, db: Session = Depends(get_db)):
    try:
        return await BookingService.reschedule_booking(payload, db)
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


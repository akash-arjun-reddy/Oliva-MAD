import httpx
import uuid
import asyncio
import logging
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException

import json
from config.settings import settings
from models.booking_model import Booking, ReservedSlot, ConfirmedBooking,RescheduleLog
from dto.booking_schema import BookingCreate, ReserveSlotRequest
from repository.booking_repo import BookingRepository




logger = logging.getLogger("uvicorn")

MAX_RETRIES = 3
RETRY_DELAY = 2  # seconds


class BookingService:
    @staticmethod
    async def create_booking(payload: BookingCreate, db: Session, current_user):
        guest_ids = [guest.id for guest in payload.guests]
        if current_user.guest_id not in guest_ids:
            raise ValueError("Unauthorized: Guest ID mismatch")

        headers = {
            "Authorization": f"apikey {settings.ZENOTI_API_KEY}",
            "accept": "application/json",
            "content-type": "application/json"
        }

        data = {
            "center_id": payload.center_id,
            "date": payload.date.isoformat(),
            "is_only_catalog_employees": str(payload.is_only_catalog_employees).lower(),
            "use_online_booking_template": str(payload.use_online_booking_template).lower(),
            "is_couple_service": str(payload.is_couple_service).lower(),
            "guests": [guest.dict() for guest in payload.guests]
        }

        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.zenoti.com/v1/bookings?is_double_booking_enabled=true",
                headers=headers,
                json=data
            )

        response.raise_for_status()
        result = response.json()

        service_item_id = None
        try:
            service_item_id = payload.guests[0].items[0].item.id
        except (IndexError, AttributeError):
            pass

        booking = Booking(
            booking_id=result.get("id"),
            guest_id=current_user.guest_id,
            center_id=payload.center_id,
            booking_date=payload.date,
            date=payload.date,
            service_item_id=service_item_id,
            is_couple_service=payload.is_couple_service,
            is_only_catalog_employees=payload.is_only_catalog_employees,
            use_online_booking_template=payload.use_online_booking_template,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )

        return BookingRepository.save_booking(db, booking)

    @staticmethod
    async def get_available_slots(booking_id: str, check_future_day_availability: bool, db: Session, current_user):
        headers = {
            "Authorization": f"apikey {settings.ZENOTI_API_KEY}",
            "accept": "application/json"
        }

        url = f"https://api.zenoti.com/v1/bookings/{booking_id}/slots"
        params = {"check_future_day_availability": str(check_future_day_availability).lower()}

        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=headers, params=params)
            response.raise_for_status()

        return response.json()

    @staticmethod
    async def reserve_slot(booking_id: str, payload: ReserveSlotRequest, db: Session):
        headers = {
            "Authorization": f"apikey {settings.ZENOTI_API_KEY}",
            "accept": "application/json",
            "content-type": "application/json"
        }

        data = {
            "slot_time": payload.slot_time.isoformat(),
            "create_invoice": str(payload.create_invoice).lower()
        }

        MAX_RETRIES = 3
        RETRY_DELAY = 2  # seconds

        for attempt in range(1, MAX_RETRIES + 1):
            try:
                async with httpx.AsyncClient() as client:
                    response = await client.post(
                        f"https://api.zenoti.com/v1/bookings/{booking_id}/slots/reserve",
                        headers=headers,
                        json=data
                    )
                response.raise_for_status()
                result = response.json()

                if result.get("Error") and "Invalid booking id" in result["Error"].get("Message", ""):
                    raise ValueError("Zenoti responded with Invalid booking ID")

                reservation = ReservedSlot(
                    reservation_id=str(uuid.uuid4()),
                    booking_id=booking_id,
                    slot_time=payload.slot_time,
                    create_invoice=payload.create_invoice,
                    response_snapshot=json.dumps(result),
                    created_at=datetime.utcnow()
                )

                return BookingRepository.save_reserved_slot(db, reservation)

            except httpx.HTTPStatusError as http_err:
                logger.warning(f"[Attempt {attempt}] Zenoti API returned {http_err.response.status_code}: {http_err.response.text}")
            except Exception as e:
                logger.warning(f"[Attempt {attempt}] Unexpected error: {str(e)}")

            if attempt == MAX_RETRIES:
                raise HTTPException(status_code=502, detail="Failed to reserve slot after retries.")
            
            await asyncio.sleep(RETRY_DELAY)

    @staticmethod
    async def confirm_booking(booking_id: str, db: Session):
        headers = {
            "Authorization": f"apikey {settings.ZENOTI_API_KEY}",
            "accept": "application/json",
            "content-type": "application/json"
        }

        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"https://api.zenoti.com/v1/bookings/{booking_id}/slots/confirm",
                headers=headers
            )

        response.raise_for_status()
        result = response.json()

        #  Defensive check
        if "invoice" not in result or not result["invoice"]:
            raise HTTPException(status_code=400, detail="400: Invoice not found in response")

        invoice = result["invoice"]
        guest = invoice.get("guest", {})
        items = invoice.get("items", [])

        if not items:
            raise HTTPException(status_code=400, detail="400: No items found in invoice")

        item = items[0]  # Only one item is expected

        confirmed = ConfirmedBooking(
            appointment_id=item.get("appointment_id"),
            booking_id=booking_id,
            guest_id=guest.get("Id"),
            guest_first_name=guest.get("FirstName"),
            guest_last_name=guest.get("LastName"),
            invoice_id=invoice.get("invoice_id"),
            item_id=item["item"].get("id"),
            item_name=item["item"].get("name"),
            item_type=str(item["item"].get("item_type")),
            item_display_name=item["item"].get("item_display_name"),
            therapist_id=item["therapist"].get("id"),
            therapist_full_name=item["therapist"].get("full_name"),
            therapist_first_name=item["therapist"].get("first_name"),
            therapist_last_name=item["therapist"].get("last_name"),
            therapist_request_type=item["therapist"].get("therapist_request_type"),
            room_id=item["room"].get("id"),
            room_name=item["room"].get("name"),
            start_time=datetime.fromisoformat(item.get("start_time")),
            end_time=datetime.fromisoformat(item.get("end_time")),
            invoice_item_id=item.get("invoice_item_id"),
            join_link=item.get("join_link"),
            created_at=datetime.utcnow()
        )

        return BookingRepository.save_confirmed_booking(db, confirmed)
    
    @staticmethod

    async def cancel_invoice(invoice_id: str, comment: str, db: Session, current_user):
        headers = {
            "Authorization": f"apikey {settings.ZENOTI_API_KEY}",
            "accept": "application/json",
            "content-type": "application/json"
        }

        url = f"https://api.zenoti.com/v1/invoices/{invoice_id}/cancel"
        payload = {"comments": comment or "Cancelled by user"}

        try:
            async with httpx.AsyncClient() as client:
                response = await client.put(url, headers=headers, json=payload)
                response.raise_for_status()
        except httpx.HTTPStatusError as http_err:
            logger.error(f"Zenoti API error: {http_err.response.text}")
            raise HTTPException(status_code=response.status_code, detail=f"Zenoti API error: {http_err.response.text}")
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
            raise HTTPException(status_code=500, detail="Internal Server Error")

        # Delete from ConfirmedBooking
        booking = db.query(ConfirmedBooking).filter(ConfirmedBooking.invoice_id == invoice_id).first()
        if booking:
            db.delete(booking)
            db.commit()

        return {
            "status": "success",
            "invoice_id": invoice_id,
            "message": "Invoice cancelled and confirmed booking removed"
        }
 
    @staticmethod
    async def reschedule_booking(payload, db):
        headers = {
            "Authorization": f"apikey {settings.ZENOTI_API_KEY}",
            "accept": "application/json",
            "content-type": "application/json"
        }

        data = {
            "center_id": payload.center_id,
            "date": str(payload.date),
            "is_only_catalog_employees": payload.is_only_catalog_employees,
            "guests": [
                {
                    "id": payload.guest_id,
                    "invoice_id": payload.invoice_id,
                    "items": [
                        {
                            "item": {"id": payload.service_id},
                            "therapist": {"id": payload.therapist_id} if payload.therapist_id else {},
                            "invoice_item_id": payload.invoice_item_id
                        }
                    ]
                }
            ]
        }

        async with httpx.AsyncClient() as client:
            response = await client.post("https://api.zenoti.com/v1/bookings", headers=headers, json=data)

        if response.status_code != 200:
            raise HTTPException(status_code=502, detail="Zenoti reschedule failed")

        result = response.json()
        new_booking_id = result.get("id")
        if not new_booking_id:
            raise HTTPException(status_code=500, detail="No booking ID returned")

        # Update existing booking
        booking = db.query(Booking).filter(Booking.booking_id == payload.invoice_id).first()
        if booking:
            booking.booking_id = new_booking_id
            booking.date = payload.date
            booking.updated_at = datetime.utcnow()

        # Insert reschedule log
        log = RescheduleLog(
            id=str(uuid.uuid4()),
            old_booking_id=payload.invoice_id,
            new_booking_id=new_booking_id,
            invoice_id=payload.invoice_id,
            invoice_item_id=payload.invoice_item_id
        )
        db.add(log)
        db.commit()

        return {"new_booking_id": new_booking_id, "message": "Booking rescheduled successfully."}

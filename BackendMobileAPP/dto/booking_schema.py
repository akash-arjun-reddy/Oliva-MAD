from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime,date


class Item(BaseModel):
    id: str

class BookingItem(BaseModel):
    item: Item

class GuestBooking(BaseModel):
    id: str
    items: List[BookingItem]

class BookingCreate(BaseModel):
    center_id: str
    date: date
    is_only_catalog_employees: bool = False
    use_online_booking_template: bool = True
    is_couple_service: bool = False
    guests: List[GuestBooking]

class BookingResponse(BaseModel):
    booking_id: str
    status: str 
    cancelled_at: Optional[datetime]
    cancel_comments: Optional[str]

class Slot(BaseModel):
    Time: str
    Warnings: Optional[List[str]] = None
    Priority: int
    Available: bool
    SalePrice: Optional[float] = None

class FutureDay(BaseModel):
    Day: str
    IsAvailable: bool
    HolidayType: Optional[str] = None

class AvailableSlotsResponse(BaseModel):
    slots: List[Slot]
    future_days: List[FutureDay]
    next_available_day: Optional[str]
    Error: Optional[dict] = None

class ReserveSlotRequest(BaseModel):
    slot_time: datetime
    create_invoice: bool = False

class ReserveSlotResponse(BaseModel):
    reservation_id: str
    status: str

class ConfirmBookingResponse(BaseModel):
    appointment_id: str
    booking_id: str
    guest_id: str
    guest_first_name: str
    guest_last_name: str
    invoice_id: str
    item_id: str
    item_name: str
    item_type: str
    item_display_name: str
    therapist_id: str
    therapist_full_name: str
    therapist_first_name: str
    therapist_last_name: str
    therapist_request_type: str
    room_id: str
    room_name: str
    start_time: datetime
    end_time: datetime
    invoice_item_id: str
    join_link: str | None = None

class RescheduleBookingRequest(BaseModel):
    center_id: str
    date: date
    is_only_catalog_employees: bool = False
    guest_id: str
    invoice_id: str
    service_id: str
    therapist_id: Optional[str]
    invoice_item_id: str
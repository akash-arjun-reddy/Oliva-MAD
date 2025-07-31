import logging
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr

logger = logging.getLogger(__name__)

# ============================
# UserCreate DTO
# ============================

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    full_name: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[datetime] = None
    contact_number: Optional[str] = None
    address_line1: Optional[str] = None
    address_line2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None

    guest_code: Optional[str] = None  # can be populated by alias "GuestCode"
    guest_id: Optional[str] = None
    role: Optional[str] = None

    class Config:
        from_attributes = True  # replaces orm_mode
        populate_by_name = True  # replaces allow_population_by_field_name


# ============================
# UserResponse DTO
# ============================

class UserResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    full_name: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[datetime] = None
    contact_number: Optional[str] = None
    address_line1: Optional[str] = None
    address_line2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    created_by: Optional[int] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    guest_code: Optional[str] = None
    guest_id: Optional[str] = None
    role: Optional[str] = None

    class Config:
        from_attributes = True  # required to use from_orm() in Pydantic v2

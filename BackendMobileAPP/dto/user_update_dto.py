from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class UserUpdateRequest(BaseModel):
    first_name: Optional[str] = Field(None, min_length=1)
    last_name: Optional[str] = Field(None, min_length=1)
    email: Optional[EmailStr]
    phone: Optional[str] = Field(None, min_length=10, max_length=15)

    class Config:
        from_attributes = True  # Replaces orm_mode in Pydantic v2

from pydantic import BaseModel, Field
from typing import Optional


class SendOTPRequest(BaseModel):
    contact_number: str = Field(..., min_length=10, max_length=15)

class VerifyOTPRequest(BaseModel):
    contact_number: str = Field(..., min_length=10, max_length=15)
    otp_code: str = Field(..., min_length=4, max_length=8)

class SignupWithPhoneRequest(BaseModel):
    contact_number: str = Field(..., min_length=10, max_length=15)
    password: str
    otp_code: str = Field(..., min_length=4, max_length=8)
    full_name: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[str] = None

class ResetPasswordWithOTPRequest(BaseModel):
    contact_number: str = Field(..., min_length=10, max_length=15)
    otp_code: str = Field(..., min_length=4, max_length=8)
    new_password: str
    confirm_password: str 


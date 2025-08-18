import os
from typing import Optional

class SMSConfig:
    """SMS configuration settings"""
    
    # SMS Provider (development, twilio, etc.)
    PROVIDER = os.getenv("SMS_PROVIDER", "development")
    
    # Twilio Configuration
    TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID")
    TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN")
    TWILIO_FROM_NUMBER = os.getenv("TWILIO_FROM_NUMBER")
    
    # OTP Configuration
    OTP_LENGTH = int(os.getenv("OTP_LENGTH", "6"))
    OTP_EXPIRY_MINUTES = int(os.getenv("OTP_EXPIRY_MINUTES", "10"))
    
    # Development Mode Settings
    DEV_MODE_ENABLED = os.getenv("DEV_MODE_ENABLED", "true").lower() == "true"
    DEV_PHONE_NUMBER = os.getenv("DEV_PHONE_NUMBER", "+1234567890")  # For testing
    
    @classmethod
    def is_twilio_configured(cls) -> bool:
        """Check if Twilio is properly configured"""
        return all([
            cls.TWILIO_ACCOUNT_SID,
            cls.TWILIO_AUTH_TOKEN,
            cls.TWILIO_FROM_NUMBER
        ])
    
    @classmethod
    def get_sms_provider(cls) -> str:
        """Get the SMS provider to use"""
        if cls.PROVIDER == "twilio" and cls.is_twilio_configured():
            return "twilio"
        else:
            return "development"
    
    @classmethod
    def get_otp_message(cls, otp: str) -> str:
        """Get formatted OTP message"""
        return f"Your OTP code is: {otp}. Valid for {cls.OTP_EXPIRY_MINUTES} minutes. Do not share this code with anyone." 
import os
import logging
from typing import Optional
from twilio.rest import Client

logger = logging.getLogger(__name__)

class SMSService:
    """SMS service with multiple providers and development mode"""
    
    def __init__(self):
        self.provider = os.getenv("SMS_PROVIDER", "development")  # development, twilio, etc.
        self.twilio_client = None
        
        if self.provider == "twilio":
            self._init_twilio()
    
    def _init_twilio(self):
        """Initialize Twilio client"""
        try:
            account_sid = os.getenv("TWILIO_ACCOUNT_SID")
            auth_token = os.getenv("TWILIO_AUTH_TOKEN")
            
            if account_sid and auth_token:
                self.twilio_client = Client(account_sid, auth_token)
                logger.info("✅ Twilio SMS client initialized")
            else:
                logger.warning("⚠️ Twilio credentials not found, falling back to development mode")
                self.provider = "development"
                
        except Exception as e:
            logger.error(f"❌ Failed to initialize Twilio: {e}")
            self.provider = "development"
    
    def send_otp(self, mobile_number: str, otp: str) -> bool:
        """Send OTP via SMS"""
        try:
            if self.provider == "twilio" and self.twilio_client:
                return self._send_twilio_sms(mobile_number, otp)
            else:
                return self._send_development_sms(mobile_number, otp)
                
        except Exception as e:
            logger.error(f"❌ SMS send error: {e}")
            return False
    
    def _send_twilio_sms(self, mobile_number: str, otp: str) -> bool:
        """Send SMS via Twilio"""
        try:
            from_number = os.getenv("TWILIO_FROM_NUMBER")
            message_body = f"Your OTP code is: {otp}. Valid for 10 minutes. Do not share this code with anyone."
            
            message = self.twilio_client.messages.create(
                body=message_body,
                from_=from_number,
                to=mobile_number
            )
            
            logger.info(f"✅ Twilio SMS sent to {mobile_number}. SID: {message.sid}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Twilio SMS failed: {e}")
            return False
    
    def _send_development_sms(self, mobile_number: str, otp: str) -> bool:
        """Development mode - try to send actual SMS"""
        try:
            # First, try to use Twilio if credentials are available
            if os.getenv("TWILIO_ACCOUNT_SID") and os.getenv("TWILIO_AUTH_TOKEN"):
                return self._send_twilio_sms(mobile_number, otp)
            
            # If no Twilio, try free SMS service
            from .free_sms_service import send_free_sms_otp
            if send_free_sms_otp(mobile_number, otp):
                return True
            
            # If all else fails, print to console
            print("=" * 50)
            print(f"🔔 DEVELOPMENT MODE - SMS OTP")
            print(f"📱 To: {mobile_number}")
            print(f"🔢 OTP: {otp}")
            print(f"⏰ Valid for: 10 minutes")
            print("=" * 50)
            print("💡 To receive actual SMS, configure SMS credentials:")
            print("   Option 1: Set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM_NUMBER")
            print("   Option 2: Set FREE_SMS_API_KEY for MSG91 (India)")
            print("=" * 50)
            
            logger.info(f"✅ Development SMS sent to {mobile_number}")
            return True
                
        except Exception as e:
            logger.error(f"❌ Development SMS failed: {e}")
            return False
    
    def _send_via_alternative_service(self, mobile_number: str, otp: str) -> bool:
        """Send SMS via alternative free service for development"""
        try:
            import requests
            
            # Using a free SMS service for development (you can replace this with your preferred service)
            # This is just an example - you might want to use a different service
            
            message = f"Your OTP code is: {otp}. Valid for 10 minutes. Do not share this code with anyone."
            
            # For now, we'll just log that we would send it
            # In a real implementation, you would use a service like:
            # - TextLocal (India)
            # - MSG91 (India)
            # - Twilio (International)
            # - Vonage (International)
            
            logger.info(f"📱 Would send SMS to {mobile_number}: {otp}")
            print(f"📱 SMS would be sent to {mobile_number}: {otp}")
            print("💡 Configure a real SMS service for production use")
            
            return True
            
        except Exception as e:
            logger.error(f"❌ Alternative SMS service failed: {e}")
            return False
    
    def send_generic_sms(self, mobile_number: str, message: str) -> bool:
        """Send generic SMS message"""
        try:
            if self.provider == "twilio" and self.twilio_client:
                return self._send_twilio_generic_sms(mobile_number, message)
            else:
                return self._send_development_generic_sms(mobile_number, message)
                
        except Exception as e:
            logger.error(f"❌ Generic SMS send error: {e}")
            return False
    
    def _send_twilio_generic_sms(self, mobile_number: str, message: str) -> bool:
        """Send generic SMS via Twilio"""
        try:
            from_number = os.getenv("TWILIO_FROM_NUMBER")
            
            sms_message = self.twilio_client.messages.create(
                body=message,
                from_=from_number,
                to=mobile_number
            )
            
            logger.info(f"✅ Twilio generic SMS sent to {mobile_number}. SID: {sms_message.sid}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Twilio generic SMS failed: {e}")
            return False
    
    def _send_development_generic_sms(self, mobile_number: str, message: str) -> bool:
        """Development mode - print generic SMS to console"""
        print("=" * 50)
        print(f"🔔 DEVELOPMENT MODE - Generic SMS")
        print(f"📱 To: {mobile_number}")
        print(f"💬 Message: {message}")
        print("=" * 50)
        
        logger.info(f"✅ Development generic SMS sent to {mobile_number}")
        return True

# Global SMS service instance
sms_service = SMSService()

def send_otp_sms(mobile_number: str, otp: str) -> bool:
    """Legacy function for backward compatibility"""
    return sms_service.send_otp(mobile_number, otp)

def send_sms(mobile_number: str, message: str) -> bool:
    """Legacy function for backward compatibility"""
    return sms_service.send_generic_sms(mobile_number, message) 
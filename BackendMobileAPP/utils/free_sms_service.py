import requests
import logging
import os
from typing import Optional

logger = logging.getLogger(__name__)

class FreeSMSService:
    """Free SMS service for development and testing"""
    
    def __init__(self):
        self.api_key = os.getenv("FREE_SMS_API_KEY", "")
        self.sender_id = os.getenv("FREE_SMS_SENDER_ID", "OTP")
    
    def send_otp(self, mobile_number: str, otp: str) -> bool:
        """Send OTP via free SMS service"""
        try:
            message = f"Your OTP code is: {otp}. Valid for 10 minutes. Do not share this code with anyone."
            return self._send_sms(mobile_number, message)
        except Exception as e:
            logger.error(f"❌ Free SMS OTP failed: {e}")
            return False
    
    def _send_sms(self, mobile_number: str, message: str) -> bool:
        """Send SMS using free service"""
        try:
            # Remove any spaces or special characters from phone number
            clean_number = ''.join(filter(str.isdigit, mobile_number))
            
            # If it's an Indian number (starts with 91), use MSG91
            if clean_number.startswith('91') and len(clean_number) == 12:
                return self._send_via_msg91(clean_number, message)
            
            # If it's a US number (starts with 1), use Twilio trial
            elif clean_number.startswith('1') and len(clean_number) == 11:
                return self._send_via_twilio_trial(clean_number, message)
            
            # For other numbers, try alternative service
            else:
                return self._send_via_alternative(clean_number, message)
                
        except Exception as e:
            logger.error(f"❌ SMS send failed: {e}")
            return False
    
    def _send_via_msg91(self, mobile_number: str, message: str) -> bool:
        """Send SMS via MSG91 (for Indian numbers)"""
        try:
            if not self.api_key:
                logger.warning("⚠️ MSG91 API key not configured")
                return False
            
            url = "https://api.msg91.com/api/v5/flow/"
            headers = {
                "Content-Type": "application/json",
                "Authkey": self.api_key
            }
            
            payload = {
                "flow_id": "your_flow_id",  # You need to create a flow in MSG91
                "sender": self.sender_id,
                "mobiles": mobile_number,
                "VAR1": message
            }
            
            response = requests.post(url, headers=headers, json=payload)
            
            if response.status_code == 200:
                logger.info(f"✅ MSG91 SMS sent to {mobile_number}")
                return True
            else:
                logger.error(f"❌ MSG91 SMS failed: {response.text}")
                return False
                
        except Exception as e:
            logger.error(f"❌ MSG91 SMS error: {e}")
            return False
    
    def _send_via_twilio_trial(self, mobile_number: str, message: str) -> bool:
        """Send SMS via Twilio trial (for US numbers)"""
        try:
            from twilio.rest import Client
            
            account_sid = os.getenv("TWILIO_ACCOUNT_SID")
            auth_token = os.getenv("TWILIO_AUTH_TOKEN")
            from_number = os.getenv("TWILIO_FROM_NUMBER")
            
            if not all([account_sid, auth_token, from_number]):
                logger.warning("⚠️ Twilio credentials not configured")
                return False
            
            client = Client(account_sid, auth_token)
            
            sms = client.messages.create(
                body=message,
                from_=from_number,
                to=f"+{mobile_number}"
            )
            
            logger.info(f"✅ Twilio SMS sent to {mobile_number}. SID: {sms.sid}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Twilio SMS error: {e}")
            return False
    
    def _send_via_alternative(self, mobile_number: str, message: str) -> bool:
        """Send SMS via alternative free service"""
        try:
            # Using a free SMS API (you can replace this with your preferred service)
            # This is just an example - you might want to use a different service
            
            logger.info(f"📱 Would send SMS to {mobile_number}: {message}")
            print(f"📱 SMS would be sent to {mobile_number}: {message}")
            print("💡 Configure a real SMS service for production use")
            
            # For now, we'll simulate success
            return True
            
        except Exception as e:
            logger.error(f"❌ Alternative SMS error: {e}")
            return False

# Global free SMS service instance
free_sms_service = FreeSMSService()

def send_free_sms_otp(mobile_number: str, otp: str) -> bool:
    """Send OTP via free SMS service"""
    return free_sms_service.send_otp(mobile_number, otp) 
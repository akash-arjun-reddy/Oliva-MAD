import os
from twilio.rest import Client
import logging

# Configure logging
logger = logging.getLogger(__name__)

# Get Twilio credentials from environment variables (more secure)
TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID", "AC46e4e42dbeb0694b7293b27fe02db2d8")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN", "8f4d78f9b30781a4c3f89faa45d3c271")
TWILIO_FROM_NUMBER = os.getenv("TWILIO_FROM_NUMBER", "+12565489490")

# Initialize Twilio client
client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)

def send_otp_sms(mobile_number: str, otp: str) -> bool:
    """
    Send OTP via SMS using Twilio
    """
    try:
        # Format the message
        message_body = f"Your OTP code is: {otp}. Valid for 10 minutes. Do not share this code with anyone."
        
        # Send SMS via Twilio
        message = client.messages.create(
            body=message_body,
            from_=TWILIO_FROM_NUMBER,
            to=mobile_number
        )
        
        logger.info(f"✅ SMS sent successfully to {mobile_number}. Message SID: {message.sid}")
        print(f"🔔 SMS OTP sent to {mobile_number}: {otp}")
        return True
        
    except Exception as e:
        logger.error(f"❌ Failed to send SMS to {mobile_number}: {str(e)}")
        print(f"❌ SMS send error: {e}")
        
        # Fallback: For development/testing, still print the OTP
        print(f"🔔 DEVELOPMENT MODE - SMS OTP for {mobile_number}: {otp}")
        print(f"📱 In production, this would be sent via Twilio SMS")
        
        return False

def send_sms(mobile_number: str, message_body: str) -> bool:
    """
    Send generic SMS message
    """
    try:
        message = client.messages.create(
            body=message_body,
            from_=TWILIO_FROM_NUMBER,
            to=mobile_number
        )
        
        logger.info(f"✅ SMS sent successfully to {mobile_number}. Message SID: {message.sid}")
        return True
        
    except Exception as e:
        logger.error(f"❌ Failed to send SMS to {mobile_number}: {str(e)}")
        return False

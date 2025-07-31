import os
from twilio.rest import Client

TWILIO_ACCOUNT_SID = "AC46e4e42dbeb0694b7293b27fe02db2d8"
TWILIO_AUTH_TOKEN = "8f4d78f9b30781a4c3f89faa45d3c271"
TWILIO_FROM_NUMBER = "+12565489490"  # Replace with your real Twilio number
client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)

def send_otp_sms(mobile_number: str, otp: str) -> bool:
    try:
        # For testing purposes, always return True and print the OTP
        print(f"🔔 SMS OTP for {mobile_number}: {otp}")
        print(f"📱 In production, this would be sent via Twilio SMS")
        
        # Uncomment the below code when you have valid Twilio credentials
        # message = client.messages.create(
        #     body=f"Your OTP code is: {otp}",
        #     from_=TWILIO_FROM_NUMBER,
        #     to=mobile_number
        # )
        # return True
        
        return True
    except Exception as e:
        print(f"Twilio SMS send error: {e}")
        return False

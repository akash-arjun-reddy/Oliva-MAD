#!/usr/bin/env python3
"""
Get the latest valid OTP for testing
"""

from database.session import get_db
from models.otp import OTP
from datetime import datetime

def get_latest_otp():
    """Get the latest valid OTP"""
    try:
        db = next(get_db())
        
        # Get the latest valid OTP for the test number
        latest_otp = db.query(OTP).filter(
            OTP.contact_number == '919676052644',
            OTP.is_used == False,
            OTP.expires_at > datetime.utcnow()
        ).order_by(OTP.created_at.desc()).first()
        
        if latest_otp:
            print(f"🔢 Latest valid OTP: {latest_otp.otp_code}")
            print(f"📱 Phone: {latest_otp.contact_number}")
            print(f"⏰ Expires: {latest_otp.expires_at}")
            print(f"✅ Valid: {latest_otp.expires_at > datetime.utcnow()}")
        else:
            print("❌ No valid OTP found")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    get_latest_otp() 
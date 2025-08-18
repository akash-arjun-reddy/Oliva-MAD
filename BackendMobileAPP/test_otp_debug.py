#!/usr/bin/env python3
"""
Debug test for OTP functionality
"""

import os
import sys
import requests
import json

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_otp_flow():
    """Test complete OTP flow"""
    print("🧪 Testing OTP Flow")
    print("=" * 50)
    
    # Test configuration
    base_url = "http://localhost:8000"
    test_phone = "+919676052644"  # Your phone number
    test_otp = "123456"
    
    print(f"📱 Test Phone: {test_phone}")
    print()
    
    # Step 1: Send OTP
    print("🔔 Step 1: Sending OTP...")
    try:
        response = requests.post(
            f"{base_url}/auth/send-otp",
            headers={"Content-Type": "application/json"},
            json={"contact_number": test_phone}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ OTP sent successfully")
        else:
            print(f"❌ Failed to send OTP: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error sending OTP: {e}")
        return False
    
    print()
    
    # Step 2: Verify OTP (you'll need to get the actual OTP from console)
    print("🔐 Step 2: Verifying OTP...")
    print("💡 Check your backend console for the actual OTP code")
    print("💡 Replace '123456' with the actual OTP from console")
    
    try:
        response = requests.post(
            f"{base_url}/auth/verify-otp",
            headers={"Content-Type": "application/json"},
            json={
                "contact_number": test_phone,
                "otp_code": test_otp  # Replace with actual OTP from console
            }
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ OTP verified successfully")
        else:
            print(f"❌ Failed to verify OTP: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error verifying OTP: {e}")
        return False
    
    print()
    print("=" * 50)
    print("🏁 OTP testing completed!")
    return True

def test_database_otps():
    """Test database OTP entries"""
    print("🗄️ Testing Database OTPs")
    print("=" * 30)
    
    try:
        from database.session import get_db
        from models.otp import OTP
        from datetime import datetime
        
        db = next(get_db())
        
        # Get all OTPs for the test number
        test_phone = "919676052644"  # Normalized number
        otps = db.query(OTP).filter(OTP.contact_number == test_phone).all()
        
        print(f"📱 Found {len(otps)} OTPs for {test_phone}:")
        for otp in otps:
            print(f"  - ID: {otp.id}")
            print(f"    Code: {otp.otp_code}")
            print(f"    Used: {otp.is_used}")
            print(f"    Created: {otp.created_at}")
            print(f"    Expires: {otp.expires_at}")
            print(f"    Valid: {otp.expires_at > datetime.utcnow()}")
            print()
        
    except Exception as e:
        print(f"❌ Error checking database: {e}")

if __name__ == "__main__":
    print("🚀 Starting OTP Debug Tests")
    print()
    
    # Test database OTPs
    test_database_otps()
    print()
    
    # Test OTP flow
    test_otp_flow() 
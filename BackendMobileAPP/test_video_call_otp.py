#!/usr/bin/env python3
"""
Test script for Video Call OTP functionality
"""

import os
import sys
import requests
import json

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_video_call_otp():
    """Test Video Call OTP functionality"""
    print("🧪 Testing Video Call OTP Functionality")
    print("=" * 50)
    
    # Test configuration
    base_url = "http://localhost:8000"
    test_phone = "+1234567890"
    test_appointment_id = "test-appointment-123"
    
    print(f"📱 Test Phone: {test_phone}")
    print(f"🏥 Test Appointment ID: {test_appointment_id}")
    print()
    
    # Step 1: Send OTP for video call
    print("🔔 Step 1: Sending OTP for video call...")
    try:
        response = requests.post(
            f"{base_url}/appointments/{test_appointment_id}/send-video-otp",
            headers={"Content-Type": "application/json"},
            json={"contact_number": test_phone}
        )
        
        if response.status_code == 200:
            print("✅ OTP sent successfully for video call")
        else:
            print(f"❌ Failed to send OTP: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error sending OTP: {e}")
        return False
    
    print()
    
    # Step 2: Verify OTP and get video call link
    print("🔐 Step 2: Verifying OTP and getting video call link...")
    try:
        # For testing, we'll use a mock OTP
        test_otp = "123456"
        
        response = requests.post(
            f"{base_url}/appointments/{test_appointment_id}/verify-video-otp",
            headers={"Content-Type": "application/json"},
            json={
                "contact_number": test_phone,
                "otp_code": test_otp
            }
        )
        
        if response.status_code == 200:
            result = response.json()
            video_call_link = result.get("video_call_link")
            print("✅ OTP verified successfully")
            print(f"🔗 Video call link: {video_call_link}")
        else:
            print(f"❌ Failed to verify OTP: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error verifying OTP: {e}")
        return False
    
    print()
    print("=" * 50)
    print("🏁 Video Call OTP testing completed!")
    return True

def test_sms_functionality():
    """Test SMS functionality"""
    print("📱 Testing SMS Functionality")
    print("=" * 30)
    
    try:
        from utils.sms_service import sms_service
        
        test_phone = "+1234567890"
        test_otp = "123456"
        
        print(f"📞 Test Phone: {test_phone}")
        print(f"🔢 Test OTP: {test_otp}")
        print()
        
        # Test OTP SMS
        success = sms_service.send_otp(test_phone, test_otp)
        
        if success:
            print("✅ SMS functionality test passed!")
        else:
            print("❌ SMS functionality test failed!")
            
    except Exception as e:
        print(f"❌ Error testing SMS: {e}")

if __name__ == "__main__":
    print("🚀 Starting Video Call OTP Tests")
    print()
    
    # Test SMS functionality first
    test_sms_functionality()
    print()
    
    # Test video call OTP functionality
    test_video_call_otp() 
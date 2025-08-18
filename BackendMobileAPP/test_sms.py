#!/usr/bin/env python3
"""
Test script for SMS functionality
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from utils.sms_service import sms_service
from config.sms_config import SMSConfig

def test_sms_functionality():
    """Test SMS functionality"""
    print("🧪 Testing SMS Functionality")
    print("=" * 50)
    
    # Test phone number
    test_phone = "+1234567890"
    test_otp = "123456"
    
    print(f"📱 Provider: {sms_service.provider}")
    print(f"📞 Test Phone: {test_phone}")
    print(f"🔢 Test OTP: {test_otp}")
    print()
    
    # Test OTP SMS
    print("🔔 Testing OTP SMS...")
    success = sms_service.send_otp(test_phone, test_otp)
    
    if success:
        print("✅ OTP SMS test passed!")
    else:
        print("❌ OTP SMS test failed!")
    
    print()
    
    # Test generic SMS
    print("💬 Testing generic SMS...")
    test_message = "This is a test message from the SMS service."
    success = sms_service.send_generic_sms(test_phone, test_message)
    
    if success:
        print("✅ Generic SMS test passed!")
    else:
        print("❌ Generic SMS test failed!")
    
    print()
    print("=" * 50)
    print("🏁 SMS testing completed!")

def test_configuration():
    """Test SMS configuration"""
    print("⚙️ Testing SMS Configuration")
    print("=" * 50)
    
    print(f"Provider: {SMSConfig.PROVIDER}")
    print(f"Twilio Configured: {SMSConfig.is_twilio_configured()}")
    print(f"OTP Length: {SMSConfig.OTP_LENGTH}")
    print(f"OTP Expiry: {SMSConfig.OTP_EXPIRY_MINUTES} minutes")
    print(f"Dev Mode: {SMSConfig.DEV_MODE_ENABLED}")
    print(f"Dev Phone: {SMSConfig.DEV_PHONE_NUMBER}")
    
    print()
    print("=" * 50)

if __name__ == "__main__":
    test_configuration()
    print()
    test_sms_functionality() 
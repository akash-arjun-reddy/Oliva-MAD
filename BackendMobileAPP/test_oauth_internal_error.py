#!/usr/bin/env python3
"""
Test to identify the exact internal error in OAuth flow.
"""

import requests
import json
import sys
import os

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_oauth_internal_error():
    """Test OAuth to identify the exact internal error."""
    
    print("🔍 Testing OAuth internal error...")
    
    # Test data that will trigger the internal error
    test_data = {
        "token": "invalid_token_for_internal_test",
        "token_type": "access_token",
        "provider": "google",
        "device_id": "test_device",
        "device_name": "Test Device",
        "device_type": "mobile"
    }
    
    try:
        print("🔍 Sending request to trigger internal error...")
        response = requests.post(
            "http://localhost:8000/auth/oauth",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"🔍 Response status: {response.status_code}")
        print(f"🔍 Response: {response.text}")
        
        if response.status_code == 500:
            print("\n🔍 ANALYSIS:")
            print("✅ The 500 error is NOT in Google OAuth validation")
            print("✅ The error is in INTERNAL processing after token validation")
            print("🔍 Check the server console for debug messages")
            print("🔍 Look for messages starting with '🔍 DEBUG:'")
            print("\n🔍 LIKELY CAUSES:")
            print("1. Token creation (_create_token method)")
            print("2. User creation/lookup in database")
            print("3. Response generation (OAuthUserResponse)")
            print("4. Database transaction issues")
            
        elif response.status_code == 401:
            print("✅ OAuth correctly rejected invalid token")
            print("🔍 This means the error was fixed!")
            
        else:
            print(f"❌ Unexpected response: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Test failed: {e}")

def test_oauth_config_again():
    """Test OAuth configuration to ensure it's working."""
    try:
        response = requests.get("http://localhost:8000/auth/oauth/test-config", timeout=5)
        if response.status_code == 200:
            print("✅ OAuth configuration confirmed working")
            return True
        else:
            print(f"❌ OAuth config failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ OAuth config test failed: {e}")
        return False

if __name__ == "__main__":
    print("🚀 OAuth Internal Error Test")
    print("=" * 50)
    
    # Test configuration
    if not test_oauth_config_again():
        print("❌ OAuth configuration is not working.")
        sys.exit(1)
    
    # Test internal error
    test_oauth_internal_error()
    
    print("\n📝 NEXT STEPS:")
    print("1. Check the server console for debug messages")
    print("2. Look for the exact error in the debug output")
    print("3. The error is likely in token creation or user management")
    print("4. We need to see the server logs to identify the exact issue")

#!/usr/bin/env python3
"""
Test OAuth endpoint with invalid token to see the exact error.
"""

import requests
import json
import sys
import os

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_oauth_with_invalid_token():
    """Test the OAuth endpoint with an invalid token to see the exact error."""
    
    # Test data with invalid token
    test_data = {
        "token": "invalid_token_12345",
        "token_type": "access_token",
        "provider": "google",
        "device_id": "test_device_123",
        "device_name": "Test Device",
        "device_type": "mobile"
    }
    
    try:
        print("🔍 Testing OAuth endpoint with invalid token...")
        print(f"🔍 Request data: {json.dumps(test_data, indent=2)}")
        
        response = requests.post(
            "http://localhost:8000/auth/oauth",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"🔍 Response status: {response.status_code}")
        print(f"🔍 Response headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            print("✅ OAuth endpoint working correctly!")
            print(f"🔍 Response: {json.dumps(response.json(), indent=2)}")
        elif response.status_code == 401:
            print("✅ OAuth endpoint correctly rejected invalid token!")
            print(f"🔍 Error response: {response.text}")
        elif response.status_code == 500:
            print("❌ OAuth endpoint returned 500 error")
            print(f"🔍 Error response: {response.text}")
            print("🔍 This indicates an internal server error, not a token validation error")
        else:
            print(f"❌ OAuth endpoint returned unexpected status {response.status_code}")
            print(f"🔍 Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

def test_oauth_with_missing_fields():
    """Test the OAuth endpoint with missing required fields."""
    
    # Test data with missing token
    test_data = {
        "token_type": "access_token",
        "provider": "google"
    }
    
    try:
        print("\n🔍 Testing OAuth endpoint with missing token...")
        print(f"🔍 Request data: {json.dumps(test_data, indent=2)}")
        
        response = requests.post(
            "http://localhost:8000/auth/oauth",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"🔍 Response status: {response.status_code}")
        
        if response.status_code == 422:
            print("✅ OAuth endpoint correctly rejected request with missing fields!")
            print(f"🔍 Validation error: {response.text}")
        else:
            print(f"❌ Unexpected response: {response.status_code}")
            print(f"🔍 Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    print("🚀 OAuth Error Testing")
    print("=" * 50)
    
    # Test with invalid token
    test_oauth_with_invalid_token()
    
    # Test with missing fields
    test_oauth_with_missing_fields()
    
    print("\n📝 Analysis:")
    print("- If you get a 401 error, the OAuth endpoint is working correctly")
    print("- If you get a 500 error, there's still an internal server error")
    print("- If you get a 422 error for missing fields, validation is working")

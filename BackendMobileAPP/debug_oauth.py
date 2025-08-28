#!/usr/bin/env python3
"""
Debug script to test OAuth endpoint and identify the exact error.
"""

import requests
import json
import sys
import os

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_oauth_endpoint():
    """Test the OAuth endpoint with a sample token."""
    
    # Test data - you'll need to replace this with a real Google access token
    test_data = {
        "token": "YOUR_GOOGLE_ACCESS_TOKEN_HERE",  # Replace with actual token
        "token_type": "access_token",
        "provider": "google",
        "device_id": "test_device_123",
        "device_name": "Test Device",
        "device_type": "mobile"
    }
    
    try:
        print("🔍 Testing OAuth endpoint...")
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
        else:
            print(f"❌ OAuth endpoint failed with status {response.status_code}")
            print(f"🔍 Error response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

def test_oauth_config():
    """Test the OAuth configuration endpoint."""
    
    try:
        print("🔍 Testing OAuth configuration...")
        
        response = requests.get(
            "http://localhost:8000/auth/oauth/test-config",
            timeout=5
        )
        
        print(f"🔍 Config response status: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ OAuth configuration is working!")
            print(f"🔍 Config: {json.dumps(response.json(), indent=2)}")
        else:
            print(f"❌ OAuth configuration failed: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Config request failed: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    print("🚀 OAuth Debug Script")
    print("=" * 50)
    
    # Test configuration first
    test_oauth_config()
    print()
    
    # Test OAuth endpoint
    test_oauth_endpoint()
    
    print("\n📝 Instructions:")
    print("1. Replace 'YOUR_GOOGLE_ACCESS_TOKEN_HERE' with a real Google access token")
    print("2. Run this script to see the exact error")
    print("3. Check the server logs for additional debug information")

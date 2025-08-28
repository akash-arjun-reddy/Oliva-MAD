#!/usr/bin/env python3
"""
Test OAuth endpoint and capture debug output.
"""

import requests
import json
import time

def test_oauth_debug():
    """Test OAuth endpoint and capture debug output."""
    
    # Test data
    test_data = {
        "token": "invalid_token_for_debug",
        "token_type": "access_token",
        "provider": "google",
        "device_id": "debug_device",
        "device_name": "Debug Device",
        "device_type": "mobile"
    }
    
    print("🔍 Testing OAuth endpoint for debug output...")
    print(f"🔍 Request data: {json.dumps(test_data, indent=2)}")
    print("🔍 Check the server logs for debug output...")
    
    try:
        response = requests.post(
            "http://localhost:8000/auth/oauth",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"🔍 Response status: {response.status_code}")
        print(f"🔍 Response: {response.text}")
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    print("🚀 OAuth Debug Test")
    print("=" * 50)
    
    # Wait a moment for server to be ready
    print("⏳ Waiting for server to be ready...")
    time.sleep(2)
    
    test_oauth_debug()
    
    print("\n📝 Check the server console output for debug messages starting with '🔍 DEBUG:'")

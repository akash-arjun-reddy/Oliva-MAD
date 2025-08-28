#!/usr/bin/env python3
"""
Step-by-step OAuth testing to identify the exact issue.
"""

import requests
import json
import sys
import os
import time

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_server_status():
    """Test if the server is running."""
    try:
        response = requests.get("http://localhost:8000/docs", timeout=5)
        if response.status_code == 200:
            print("✅ Server is running")
            return True
        else:
            print(f"❌ Server responded with status {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Server is not running: {e}")
        return False

def test_oauth_config():
    """Test OAuth configuration endpoint."""
    try:
        response = requests.get("http://localhost:8000/auth/oauth/test-config", timeout=5)
        if response.status_code == 200:
            config = response.json()
            print("✅ OAuth configuration is working")
            print(f"🔍 Google Client ID: {config.get('google_client_id', 'Not set')}")
            return True
        else:
            print(f"❌ OAuth config failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ OAuth config test failed: {e}")
        return False

def test_oauth_with_real_token():
    """Test OAuth with a real Google token (you'll need to provide one)."""
    print("\n🔍 Testing OAuth with real token...")
    print("📝 Please provide a real Google access token from your frontend app")
    print("📝 You can get this from your browser's network tab or Flutter app logs")
    
    # You can replace this with a real token for testing
    real_token = input("Enter Google access token (or press Enter to skip): ").strip()
    
    if not real_token:
        print("⏭️  Skipping real token test")
        return
    
    test_data = {
        "token": real_token,
        "token_type": "access_token",
        "provider": "google",
        "device_id": "test_device_real",
        "device_name": "Test Device",
        "device_type": "mobile"
    }
    
    try:
        print("🔍 Sending request with real token...")
        response = requests.post(
            "http://localhost:8000/auth/oauth",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=15
        )
        
        print(f"🔍 Response status: {response.status_code}")
        
        if response.status_code == 200:
            print("🎉 OAuth endpoint working correctly!")
            result = response.json()
            print(f"🔍 User email: {result.get('user', {}).get('email', 'N/A')}")
            print(f"🔍 Is new user: {result.get('is_new_user', 'N/A')}")
            print(f"🔍 Access token length: {len(result.get('tokens', {}).get('access_token', ''))}")
        elif response.status_code == 401:
            print("✅ OAuth correctly rejected invalid token")
            print(f"🔍 Error: {response.text}")
        elif response.status_code == 500:
            print("❌ OAuth returned 500 error")
            print(f"🔍 Error: {response.text}")
            print("🔍 Check server logs for debug output")
        else:
            print(f"❌ Unexpected response: {response.status_code}")
            print(f"🔍 Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

def test_oauth_with_invalid_token():
    """Test OAuth with invalid token to see error handling."""
    print("\n🔍 Testing OAuth with invalid token...")
    
    test_data = {
        "token": "invalid_token_for_testing",
        "token_type": "access_token",
        "provider": "google",
        "device_id": "test_device_invalid",
        "device_name": "Test Device",
        "device_type": "mobile"
    }
    
    try:
        response = requests.post(
            "http://localhost:8000/auth/oauth",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"🔍 Response status: {response.status_code}")
        
        if response.status_code == 401:
            print("✅ OAuth correctly rejected invalid token")
        elif response.status_code == 500:
            print("❌ OAuth returned 500 error with invalid token")
            print("🔍 This suggests the error is not in token validation")
        else:
            print(f"❌ Unexpected response: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Test failed: {e}")

def test_oauth_validation():
    """Test OAuth request validation."""
    print("\n🔍 Testing OAuth request validation...")
    
    # Test missing token
    test_data = {
        "token_type": "access_token",
        "provider": "google"
    }
    
    try:
        response = requests.post(
            "http://localhost:8000/auth/oauth",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=5
        )
        
        if response.status_code == 422:
            print("✅ Request validation working correctly")
        else:
            print(f"❌ Unexpected validation response: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Validation test failed: {e}")

if __name__ == "__main__":
    print("🚀 OAuth Step-by-Step Testing")
    print("=" * 60)
    
    # Wait for server to be ready
    print("⏳ Waiting for server to be ready...")
    time.sleep(3)
    
    # Test server status
    if not test_server_status():
        print("❌ Server is not running. Please start the server first.")
        sys.exit(1)
    
    # Test OAuth configuration
    if not test_oauth_config():
        print("❌ OAuth configuration is not working.")
        sys.exit(1)
    
    # Test validation
    test_oauth_validation()
    
    # Test with invalid token
    test_oauth_with_invalid_token()
    
    # Test with real token (if provided)
    test_oauth_with_real_token()
    
    print("\n📝 Summary:")
    print("- If you get 422 errors, validation is working")
    print("- If you get 401 errors, token validation is working")
    print("- If you get 500 errors, there's an internal server error")
    print("- Check the server console for debug messages starting with '🔍 DEBUG:'")

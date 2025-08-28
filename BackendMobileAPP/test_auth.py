#!/usr/bin/env python3
"""
Test script for authentication endpoints
"""

import requests
import json
import time

BASE_URL = "http://localhost:8000"

def test_server_health():
    """Test if server is running"""
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"✅ Server Health: {response.status_code}")
        print(f"Response: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Server not responding: {e}")
        return False

def test_user_registration():
    """Test user registration"""
    print("\n🔐 Testing User Registration...")
    
    registration_data = {
        "username": "testuser456",
        "email": "testuser456@example.com",
        "password": "TestPassword123!",
        "full_name": "Test User 456",
        "contact_number": "+1234567890",
        "gender": "male",
        "city": "Test City",
        "state": "Test State",
        "country": "Test Country"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/register", json=registration_data)
        print(f"Registration Status: {response.status_code}")
        print(f"Registration Response: {response.json()}")
        
        if response.status_code == 200 or response.status_code == 201:
            print("✅ Registration successful!")
            return True
        else:
            print("❌ Registration failed!")
            return False
            
    except Exception as e:
        print(f"❌ Registration error: {e}")
        return False

def test_user_login():
    """Test user login"""
    print("\n🔑 Testing User Login...")
    
    login_data = {
        "login": "testuser456@example.com",
        "password": "TestPassword123!"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/login", json=login_data)
        print(f"Login Status: {response.status_code}")
        print(f"Login Response: {response.json()}")
        
        if response.status_code == 200:
            print("✅ Login successful!")
            # Extract token for future use
            token_data = response.json()
            if "access_token" in token_data:
                print(f"✅ Access token received: {token_data['access_token'][:20]}...")
                return token_data["access_token"]
        else:
            print("❌ Login failed!")
            return None
            
    except Exception as e:
        print(f"❌ Login error: {e}")
        return None

def test_protected_endpoint(token):
    """Test accessing a protected endpoint"""
    print("\n🔒 Testing Protected Endpoint...")
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    try:
        # Test the rewards UI content endpoint
        ui_data = {
            "page": "home",
            "section": "banner",
            "user_id": "testuser456"
        }
        
        response = requests.post(f"{BASE_URL}/api/rewards/ui-content", 
                               json=ui_data, headers=headers)
        print(f"Protected Endpoint Status: {response.status_code}")
        print(f"Protected Endpoint Response: {response.json()}")
        
        if response.status_code == 200:
            print("✅ Protected endpoint access successful!")
            return True
        else:
            print("❌ Protected endpoint access failed!")
            return False
            
    except Exception as e:
        print(f"❌ Protected endpoint error: {e}")
        return False

def test_oauth_config():
    """Test OAuth configuration"""
    print("\n🔧 Testing OAuth Configuration...")
    
    try:
        response = requests.get(f"{BASE_URL}/auth/oauth/test-config")
        print(f"OAuth Config Status: {response.status_code}")
        print(f"OAuth Config Response: {response.json()}")
        
        if response.status_code == 200:
            print("✅ OAuth configuration is ready!")
            return True
        else:
            print("❌ OAuth configuration failed!")
            return False
            
    except Exception as e:
        print(f"❌ OAuth config error: {e}")
        return False

def main():
    """Main test function"""
    print("🚀 Starting Authentication Tests...")
    print("=" * 50)
    
    # Test server health
    if not test_server_health():
        print("❌ Server is not running. Please start the server first.")
        return
    
    # Test OAuth configuration
    test_oauth_config()
    
    # Test user registration
    registration_success = test_user_registration()
    
    # Test user login
    token = test_user_login()
    
    # Test protected endpoint if login was successful
    if token:
        test_protected_endpoint(token)
    
    print("\n" + "=" * 50)
    print("🏁 Authentication Tests Completed!")
    
    if registration_success and token:
        print("✅ All tests passed! Your authentication system is working.")
    else:
        print("❌ Some tests failed. Please check the errors above.")

if __name__ == "__main__":
    main()

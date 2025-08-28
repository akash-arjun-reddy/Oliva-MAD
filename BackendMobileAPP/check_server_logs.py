#!/usr/bin/env python3
"""
Script to help check server logs and identify the exact OAuth error.
"""

import requests
import json
import time

def trigger_oauth_error():
    """Trigger the OAuth error to see server logs."""
    
    print("🔍 Triggering OAuth error to see server logs...")
    print("📝 Check the server console/terminal for debug messages")
    print("📝 Look for messages starting with '🔍 DEBUG:'")
    
    test_data = {
        "token": "trigger_error_token",
        "token_type": "access_token",
        "provider": "google",
        "device_id": "log_test_device",
        "device_name": "Log Test Device",
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
        print(f"🔍 Response: {response.text}")
        
        if response.status_code == 500:
            print("\n🔍 SERVER LOGS ANALYSIS:")
            print("The server should have logged debug messages.")
            print("Check the terminal/console where you started the server.")
            print("Look for these debug messages:")
            print("  - '🔍 DEBUG: Google OAuth authentication started'")
            print("  - '🔍 DEBUG: Token verification failed'")
            print("  - '🔍 DEBUG: Error in _create_token'")
            print("  - '🔍 DEBUG: Error in user creation/lookup'")
            print("  - '🔍 DEBUG: Error in token creation'")
            
        return response.status_code
        
    except Exception as e:
        print(f"❌ Request failed: {e}")
        return None

if __name__ == "__main__":
    print("🚀 Server Logs Check")
    print("=" * 50)
    
    print("📝 INSTRUCTIONS:")
    print("1. Make sure your server is running in a separate terminal")
    print("2. Run this script to trigger the OAuth error")
    print("3. Check the server terminal for debug messages")
    print("4. Look for the exact error in the debug output")
    
    input("\nPress Enter to trigger the OAuth error...")
    
    status = trigger_oauth_error()
    
    if status == 500:
        print("\n🔍 TROUBLESHOOTING:")
        print("If you don't see debug messages in the server terminal:")
        print("1. Make sure the server is running with debug output")
        print("2. Check if the server is running in the correct directory")
        print("3. Restart the server to see fresh logs")
        
        print("\n🔍 COMMON FIXES:")
        print("1. Check if SECRET_KEY is properly set in .env file")
        print("2. Verify database connection is working")
        print("3. Check if all required models are imported correctly")
        print("4. Ensure JWT encoding/decoding is working")

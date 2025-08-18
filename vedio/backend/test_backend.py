#!/usr/bin/env python3
"""
Simple test script to verify backend setup
"""

import requests
import json
from datetime import date

def test_backend():
    base_url = "http://localhost:8000"
    
    print("Testing Oliva Virtual Clinic Backend...")
    print("=" * 50)
    
    # Test 1: Health check
    try:
        response = requests.get(f"{base_url}/")
        print(f"✓ Health check: {response.status_code}")
        print(f"  Response: {response.json()}")
    except Exception as e:
        print(f"✗ Health check failed: {e}")
        return
    
    # Test 2: Get active doctors
    try:
        response = requests.get(f"{base_url}/api/v1/doctors/active")
        print(f"✓ Get doctors: {response.status_code}")
        doctors = response.json()
        print(f"  Found {len(doctors)} doctors")
        for doctor in doctors:
            print(f"    - {doctor['name']} ({doctor['specialty']})")
    except Exception as e:
        print(f"✗ Get doctors failed: {e}")
    
    # Test 3: Get doctor availability
    try:
        today = date.today().isoformat()
        response = requests.get(f"{base_url}/api/v1/appointments/availability/1/{today}")
        print(f"✓ Get availability: {response.status_code}")
        availability = response.json()
        print(f"  Available slots: {len([s for s in availability['time_slots'] if s['is_available']])}")
    except Exception as e:
        print(f"✗ Get availability failed: {e}")
    
    print("\nBackend test completed!")

if __name__ == "__main__":
    test_backend()

#!/usr/bin/env python3
"""
Test individual OAuth components to identify the issue.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_imports():
    """Test if all required modules can be imported."""
    print("🔍 Testing imports...")
    
    try:
        from jose import jwt, JWTError
        print("✅ jose.jwt imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import jose.jwt: {e}")
        return False
    
    try:
        from config.settings import settings
        print("✅ settings imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import settings: {e}")
        return False
    
    try:
        from dto.google_auth_dto import OAuthTokenRequest, OAuthUserResponse, OAuthProvider, OAuthUserProfile, OAuthTokenResponse
        print("✅ DTOs imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import DTOs: {e}")
        return False
    
    try:
        from service.auth_service import AuthService
        print("✅ AuthService imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import AuthService: {e}")
        return False
    
    return True

def test_settings():
    """Test if settings are properly configured."""
    print("\n🔍 Testing settings...")
    
    try:
        from config.settings import settings
        
        print(f"🔍 SECRET_KEY: {'Set' if settings.SECRET_KEY else 'Not set'}")
        print(f"🔍 ALGORITHM: {settings.ALGORITHM}")
        print(f"🔍 GOOGLE_CLIENT_ID: {'Set' if settings.GOOGLE_CLIENT_ID else 'Not set'}")
        
        if not settings.SECRET_KEY:
            print("❌ SECRET_KEY is not set!")
            return False
        
        if not settings.GOOGLE_CLIENT_ID:
            print("❌ GOOGLE_CLIENT_ID is not set!")
            return False
        
        print("✅ Settings are properly configured")
        return True
        
    except Exception as e:
        print(f"❌ Error testing settings: {e}")
        return False

def test_token_creation():
    """Test token creation without database."""
    print("\n🔍 Testing token creation...")
    
    try:
        from jose import jwt
        from config.settings import settings
        from datetime import datetime, timedelta
        
        payload = {
            "sub": "test_user",
            "exp": datetime.utcnow() + timedelta(hours=1)
        }
        
        token = jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
        print(f"✅ Token created successfully, length: {len(token)}")
        
        # Test decoding
        decoded = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        print(f"✅ Token decoded successfully: {decoded}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error in token creation: {e}")
        return False

def test_dto_creation():
    """Test DTO creation."""
    print("\n🔍 Testing DTO creation...")
    
    try:
        from dto.google_auth_dto import OAuthTokenRequest, OAuthUserProfile, OAuthTokenResponse, OAuthUserResponse, OAuthProvider
        
        # Test OAuthTokenRequest
        token_request = OAuthTokenRequest(
            token="test_token",
            token_type="access_token",
            provider="google"
        )
        print("✅ OAuthTokenRequest created successfully")
        
        # Test OAuthUserProfile
        user_profile = OAuthUserProfile(
            provider=OAuthProvider.GOOGLE,
            provider_user_id="123",
            email="test@example.com",
            name="Test User"
        )
        print("✅ OAuthUserProfile created successfully")
        
        # Test OAuthTokenResponse
        token_response = OAuthTokenResponse(
            access_token="test_access_token",
            expires_in=3600
        )
        print("✅ OAuthTokenResponse created successfully")
        
        # Test OAuthUserResponse
        user_response = OAuthUserResponse(
            user=user_profile,
            tokens=token_response,
            is_new_user=False
        )
        print("✅ OAuthUserResponse created successfully")
        
        return True
        
    except Exception as e:
        print(f"❌ Error in DTO creation: {e}")
        return False

def test_database_connection():
    """Test database connection."""
    print("\n🔍 Testing database connection...")
    
    try:
        from database.connection import SessionLocal
        from models.user import User
        
        db = SessionLocal()
        
        # Try to query users table
        user_count = db.query(User).count()
        print(f"✅ Database connection successful, user count: {user_count}")
        
        db.close()
        return True
        
    except Exception as e:
        print(f"❌ Error in database connection: {e}")
        return False

if __name__ == "__main__":
    print("🚀 OAuth Components Test")
    print("=" * 50)
    
    tests = [
        ("Imports", test_imports),
        ("Settings", test_settings),
        ("Token Creation", test_token_creation),
        ("DTO Creation", test_dto_creation),
        ("Database Connection", test_database_connection),
    ]
    
    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ {test_name} test failed with exception: {e}")
            results.append((test_name, False))
    
    print("\n" + "=" * 50)
    print("📊 Test Results:")
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  {test_name}: {status}")
    
    all_passed = all(result for _, result in results)
    if all_passed:
        print("\n🎉 All tests passed! OAuth components are working correctly.")
    else:
        print("\n⚠️  Some tests failed. Check the errors above.")

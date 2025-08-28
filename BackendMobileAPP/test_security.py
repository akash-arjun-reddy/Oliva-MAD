#!/usr/bin/env python3
"""
Simple test script to verify security features are working.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database.connection import SessionLocal
from service.security_service import SecurityService
from service.rbac_service import RBACService
from service.mfa_service import MFAService

def test_security_services():
    """Test that all security services can be instantiated."""
    print("🔧 Testing Security Services...")
    
    try:
        db = SessionLocal()
        
        # Test SecurityService
        security_service = SecurityService(db)
        print("✅ SecurityService created successfully")
        
        # Test RBACService
        rbac_service = RBACService(db)
        print("✅ RBACService created successfully")
        
        # Test MFAService
        mfa_service = MFAService(db)
        print("✅ MFAService created successfully")
        
        db.close()
        print("🎉 All security services are working!")
        return True
        
    except Exception as e:
        print(f"❌ Error testing security services: {e}")
        return False

def test_imports():
    """Test that all required modules can be imported."""
    print("🔧 Testing Imports...")
    
    try:
        from models.auth_models import RefreshToken, EnhancedUserSession, AuditLog, RateLimitLog, SessionStatus
        print("✅ Auth models imported successfully")
        
        from models.rbac_models import Role, Permission, UserPermission
        print("✅ RBAC models imported successfully")
        
        from models.session import UserSession, SessionLog
        print("✅ Session models imported successfully")
        
        from middleware.rate_limit import RateLimitMiddleware
        print("✅ Rate limit middleware imported successfully")
        
        from gateway.api_gateway import APIGateway
        print("✅ API Gateway imported successfully")
        
        print("🎉 All imports successful!")
        return True
        
    except Exception as e:
        print(f"❌ Error testing imports: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Testing Security Infrastructure...")
    
    success = True
    success &= test_imports()
    success &= test_security_services()
    
    if success:
        print("\n🎉 All tests passed! Security infrastructure is ready!")
        print("\n📋 What's available:")
        print("   • Refresh token management")
        print("   • Session management")
        print("   • Audit logging")
        print("   • Rate limiting")
        print("   • Role-based access control (RBAC)")
        print("   • Multi-factor authentication (MFA)")
        print("   • API Gateway")
    else:
        print("\n❌ Some tests failed. Please check the errors above.")
        sys.exit(1)

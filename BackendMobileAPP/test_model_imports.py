#!/usr/bin/env python3
"""
Test script to check model import order and fix SQLAlchemy mapping issues.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_model_imports():
    """Test importing models in the correct order."""
    print("🔍 Testing model imports...")
    
    try:
        # Import base first
        from database.base import Base
        print("✅ Base imported successfully")
        
        # Import session models first (they reference User)
        from models.session import UserSession, SessionLog
        print("✅ Session models imported successfully")
        
        # Import auth models
        from models.auth_models import RefreshToken, EnhancedUserSession, AuditLog, RateLimitLog
        print("✅ Auth models imported successfully")
        
        # Import RBAC models
        from models.rbac_models import Role, Permission, UserPermission
        print("✅ RBAC models imported successfully")
        
        # Import User model last (it references all the above)
        from models.user import User
        print("✅ User model imported successfully")
        
        # Test creating a database session
        from database.connection import SessionLocal
        db = SessionLocal()
        
        # Test querying users
        user_count = db.query(User).count()
        print(f"✅ Database query successful, user count: {user_count}")
        
        db.close()
        return True
        
    except Exception as e:
        print(f"❌ Error in model imports: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("🚀 Model Import Test")
    print("=" * 50)
    
    success = test_model_imports()
    
    if success:
        print("\n🎉 All model imports successful!")
    else:
        print("\n❌ Model imports failed. Check the error above.")

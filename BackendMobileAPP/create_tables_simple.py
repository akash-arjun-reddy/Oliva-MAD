#!/usr/bin/env python3
"""
Simple script to create security tables.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from database.connection import SessionLocal
from database.base import Base
from config.settings import settings

def create_security_tables():
    """Create security tables."""
    print("🔧 Creating security tables...")
    
    # Create engine
    engine = create_engine(settings.DATABASE_URL)
    
    try:
        # Import all models to register them
        from models.session import UserSession, SessionLog
        from models.auth_models import RefreshToken, EnhancedUserSession, AuditLog, RateLimitLog
        from models.rbac_models import Role, Permission, UserPermission
        from models.user import User
        
        # Create all tables
        Base.metadata.create_all(bind=engine)
        print("✅ All tables created successfully!")
        
        # Verify tables exist
        verify_tables()
        
    except Exception as e:
        print(f"❌ Error creating tables: {e}")
        raise

def verify_tables():
    """Verify that tables were created."""
    print("🔍 Verifying table creation...")
    
    db = SessionLocal()
    try:
        # Check if tables exist
        tables_to_check = [
            "refresh_tokens",
            "enhanced_user_sessions", 
            "audit_logs",
            "rate_limit_logs",
            "roles",
            "permissions",
            "user_roles",
            "role_permissions",
            "user_permissions"
        ]
        
        for table_name in tables_to_check:
            try:
                result = db.execute(text(f"SELECT COUNT(*) FROM {table_name}"))
                count = result.scalar()
                print(f"✅ Table '{table_name}' exists with {count} records")
            except Exception as e:
                print(f"❌ Table '{table_name}' not found: {e}")
        
        print("✅ Table verification completed!")
        
    except Exception as e:
        print(f"❌ Error verifying tables: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    print("🚀 Creating Security Tables...")
    
    try:
        create_security_tables()
        print("🎉 Security tables created successfully!")
        
    except Exception as e:
        print(f"❌ Failed to create tables: {e}")
        sys.exit(1)

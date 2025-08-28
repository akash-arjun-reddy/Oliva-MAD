#!/usr/bin/env python3
"""
Database migration script to create security and RBAC tables.
Run this script to set up the new security infrastructure.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from database.connection import SessionLocal
from database.base import Base
from models.session import UserSession, SessionLog
from models.auth_models import RefreshToken, EnhancedUserSession, AuditLog, RateLimitLog
from models.rbac_models import Role, Permission, UserPermission
from models.user import User
from config.settings import settings

def create_tables():
    """Create all security and RBAC tables."""
    print("🔧 Creating security and RBAC tables...")
    
    # Create engine
    engine = create_engine(settings.DATABASE_URL)
    
    try:
        # Create all tables
        Base.metadata.create_all(bind=engine)
        print("✅ All tables created successfully!")
        
        # Initialize default roles and permissions
        initialize_default_roles()
        
    except Exception as e:
        print(f"❌ Error creating tables: {e}")
        raise

def initialize_default_roles():
    """Initialize default roles and permissions."""
    print("🔧 Initializing default roles and permissions...")
    
    db = SessionLocal()
    try:
        # Create default permissions
        permissions = [
            # User permissions
            {"name": "View Users", "resource": "user", "action": "read", "description": "Can view user information"},
            {"name": "Create Users", "resource": "user", "action": "create", "description": "Can create new users"},
            {"name": "Update Users", "resource": "user", "action": "update", "description": "Can update user information"},
            {"name": "Delete Users", "resource": "user", "action": "delete", "description": "Can delete users"},
            
            # Appointment permissions
            {"name": "View Appointments", "resource": "appointment", "action": "read", "description": "Can view appointments"},
            {"name": "Create Appointments", "resource": "appointment", "action": "create", "description": "Can create appointments"},
            {"name": "Update Appointments", "resource": "appointment", "action": "update", "description": "Can update appointments"},
            {"name": "Delete Appointments", "resource": "appointment", "action": "delete", "description": "Can delete appointments"},
            
            # Booking permissions
            {"name": "View Bookings", "resource": "booking", "action": "read", "description": "Can view bookings"},
            {"name": "Create Bookings", "resource": "booking", "action": "create", "description": "Can create bookings"},
            {"name": "Update Bookings", "resource": "booking", "action": "update", "description": "Can update bookings"},
            {"name": "Delete Bookings", "resource": "booking", "action": "delete", "description": "Can delete bookings"},
            
            # Rewards permissions
            {"name": "View Rewards", "resource": "rewards", "action": "read", "description": "Can view rewards"},
            {"name": "Manage Rewards", "resource": "rewards", "action": "manage", "description": "Can manage rewards system"},
            
            # Admin permissions
            {"name": "View Audit Logs", "resource": "audit", "action": "read", "description": "Can view audit logs"},
            {"name": "Manage Roles", "resource": "rbac", "action": "manage", "description": "Can manage roles and permissions"},
            {"name": "System Admin", "resource": "system", "action": "admin", "description": "Full system administration"},
        ]
        
        created_permissions = []
        for perm_data in permissions:
            existing = db.query(Permission).filter(
                Permission.resource == perm_data["resource"],
                Permission.action == perm_data["action"]
            ).first()
            
            if not existing:
                permission = Permission(**perm_data)
                db.add(permission)
                created_permissions.append(permission)
        
        db.commit()
        print(f"✅ Created {len(created_permissions)} permissions")
        
        # Create default roles
        roles = [
            {
                "name": "admin",
                "description": "System Administrator with full access",
                "permissions": ["system:admin", "rbac:manage", "audit:read"]
            },
            {
                "name": "manager",
                "description": "Clinic Manager with management access",
                "permissions": ["user:read", "user:update", "appointment:read", "appointment:create", 
                              "appointment:update", "booking:read", "booking:create", "booking:update"]
            },
            {
                "name": "staff",
                "description": "Clinic Staff with limited access",
                "permissions": ["appointment:read", "appointment:create", "booking:read", "booking:create"]
            },
            {
                "name": "customer",
                "description": "Customer with basic access",
                "permissions": ["appointment:read", "booking:read", "booking:create"]
            }
        ]
        
        created_roles = []
        for role_data in roles:
            existing = db.query(Role).filter(Role.name == role_data["name"]).first()
            
            if not existing:
                role = Role(name=role_data["name"], description=role_data["description"])
                db.add(role)
                db.commit()
                db.refresh(role)
                
                # Add permissions to role
                for perm_filter in role_data["permissions"]:
                    resource, action = perm_filter.split(":")
                    permission = db.query(Permission).filter(
                        Permission.resource == resource,
                        Permission.action == action
                    ).first()
                    
                    if permission:
                        role.permissions.append(permission)
                
                created_roles.append(role)
        
        db.commit()
        print(f"✅ Created {len(created_roles)} roles")
        
        print("✅ Default roles and permissions initialized successfully!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error initializing roles: {e}")
        raise
    finally:
        db.close()

def verify_tables():
    """Verify that all tables were created correctly."""
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
            result = db.execute(text(f"SELECT COUNT(*) FROM {table_name}"))
            count = result.scalar()
            print(f"✅ Table '{table_name}' exists with {count} records")
        
        print("✅ All tables verified successfully!")
        
    except Exception as e:
        print(f"❌ Error verifying tables: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    print("🚀 Starting security infrastructure setup...")
    
    try:
        create_tables()
        verify_tables()
        print("🎉 Security infrastructure setup completed successfully!")
        print("\n📋 What was created:")
        print("   • Refresh token management")
        print("   • Session management")
        print("   • Audit logging")
        print("   • Rate limiting")
        print("   • Role-based access control (RBAC)")
        print("   • Permission management")
        print("   • Default roles and permissions")
        
    except Exception as e:
        print(f"❌ Setup failed: {e}")
        sys.exit(1)

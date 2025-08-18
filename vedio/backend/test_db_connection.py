#!/usr/bin/env python3
"""
Test script to verify database connection and schema creation
"""

import os
import sys
from sqlalchemy import text
from app.database.connection import engine, create_schema_if_not_exists, DB_SCHEMA

def test_database_connection():
    """Test database connection and schema creation"""
    try:
        print("Testing database connection...")
        
        # Test basic connection
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            print("✓ Database connection successful")
        
        # Test schema creation
        create_schema_if_not_exists()
        print(f"✓ Schema '{DB_SCHEMA}' is ready")
        
        # Test if we can create tables
        with engine.connect() as connection:
            # Test creating a simple table
            connection.execute(text(f"""
                CREATE TABLE IF NOT EXISTS {DB_SCHEMA}.test_table (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(100)
                )
            """))
            connection.commit()
            print("✓ Table creation test successful")
            
            # Clean up test table
            connection.execute(text(f"DROP TABLE IF EXISTS {DB_SCHEMA}.test_table"))
            connection.commit()
            print("✓ Test table cleanup successful")
        
        print("\n🎉 Database connection and schema setup successful!")
        return True
        
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False

if __name__ == "__main__":
    success = test_database_connection()
    sys.exit(0 if success else 1)

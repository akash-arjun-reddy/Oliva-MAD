#!/usr/bin/env python3
"""
Database initialization script
"""

from sqlalchemy.orm import Session
from app.database.connection import engine, SessionLocal, create_schema_if_not_exists
from app.models.doctor import Doctor
from app.models.patient import Patient
from app.models.appointment import Appointment
from app.database.connection import Base, DB_SCHEMA
import os

def init_database():
    """Initialize database with tables and sample data"""
    print("🚀 Initializing database...")
    
    # Create schema
    create_schema_if_not_exists()
    
    # Create all tables
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created")
    
    # Insert sample data
    insert_sample_data()
    print("✅ Sample data inserted")

def insert_sample_data():
    """Insert sample doctors and other data"""
    db = SessionLocal()
    try:
        # Check if doctors already exist
        existing_doctors = db.query(Doctor).count()
        if existing_doctors > 0:
            print("📋 Doctors already exist, skipping insertion")
            return
        
        # Sample doctors
        doctors = [
            Doctor(
                name="Dr. Mythree Koyyana",
                email="mythree.koyyana@olivaclinic.com",
                specialty="Dermatologist",
                photo_url="assets/images/drone.png",
                rating=5,
                experience_years=15,
                bio="Specialized in skin conditions and cosmetic dermatology",
                is_active=1
            ),
            Doctor(
                name="Dr. Nikhil Kadarla",
                email="nikhil.kadarla@olivaclinic.com",
                specialty="Hair Specialist",
                photo_url="assets/images/drone.png",
                rating=5,
                experience_years=12,
                bio="Expert in hair restoration and scalp treatments",
                is_active=1
            ),
            Doctor(
                name="Dr. Akhila Sandana",
                email="akhila.sandana@olivaclinic.com",
                specialty="Cosmetic Surgeon",
                photo_url="assets/images/drone.png",
                rating=5,
                experience_years=18,
                bio="Specialized in cosmetic and reconstructive surgery",
                is_active=1
            ),
            Doctor(
                name="Dr. Vyshnavi Mettala",
                email="vyshnavi.mettala@olivaclinic.com",
                specialty="Aesthetician",
                photo_url="assets/images/drone.png",
                rating=5,
                experience_years=10,
                bio="Expert in aesthetic treatments and skincare",
                is_active=1
            )
        ]
        
        # Insert doctors
        for doctor in doctors:
            db.add(doctor)
        
        db.commit()
        print(f"✅ Inserted {len(doctors)} doctors")
        
        # Sample patients
        patients = [
            Patient(
                name="John Doe",
                email="john.doe@example.com",
                phone="+1234567890",
                date_of_birth="1990-01-01",
                gender="Male",
                address="123 Main St, City, State"
            ),
            Patient(
                name="Jane Smith",
                email="jane.smith@example.com",
                phone="+1234567891",
                date_of_birth="1985-05-15",
                gender="Female",
                address="456 Oak Ave, City, State"
            )
        ]
        
        # Insert patients
        for patient in patients:
            db.add(patient)
        
        db.commit()
        print(f"✅ Inserted {len(patients)} patients")
        
    except Exception as e:
        print(f"❌ Error inserting sample data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    init_database()

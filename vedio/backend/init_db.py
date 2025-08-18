from sqlalchemy.orm import Session
from app.database.connection import SessionLocal, engine, create_schema_if_not_exists
from app.models.doctor import Doctor
from app.dto.doctor_dto import DoctorCreateDTO
from app.services.doctor_service import DoctorService

def init_db():
    """Initialize database with sample data"""
    # Create schema first
    create_schema_if_not_exists()
    
    db = SessionLocal()
    try:
        # Check if doctors already exist
        existing_doctors = db.query(Doctor).count()
        if existing_doctors > 0:
            print("Database already initialized with doctors")
            return
        
        # Sample doctors data with correct names and emails
        doctors_data = [
            {
                "name": "Dr. Mythree Koyyana",
                "email": "mythree.koyyana@olivaclinic.com",
                "specialty": "Dermatologist",
                "photo_url": "assets/images/drone.png",
                "rating": 5,
                "experience_years": 15,
                "bio": "Specialized in treating various skin conditions with 15 years of experience."
            },
            {
                "name": "Dr. Nikhil Kadarla",
                "email": "nikhil.kadarla@olivaclinic.com",
                "specialty": "Hair Specialist",
                "photo_url": "assets/images/Generated Image (1).png",
                "rating": 5,
                "experience_years": 12,
                "bio": "Expert in hair loss treatment and scalp disorders with 12 years of experience."
            },
            {
                "name": "Dr. Akhila Sandana",
                "email": "akhila.sandana@olivaclinic.com",
                "specialty": "Skin Care Expert",
                "photo_url": "assets/images/Generated Image (2).png",
                "rating": 5,
                "experience_years": 10,
                "bio": "Specialized in skin rejuvenation and anti-aging treatments."
            },
            {
                "name": "Dr. Vyshnavi Mettala",
                "email": "vyshnavi.mettala@olivaclinic.com",
                "specialty": "Aesthetician",
                "photo_url": "assets/images/Generated Image (3).png",
                "rating": 5,
                "experience_years": 8,
                "bio": "Expert in facial treatments and aesthetic procedures."
            }
        ]
        
        doctor_service = DoctorService(db)
        
        for doctor_data in doctors_data:
            try:
                doctor_dto = DoctorCreateDTO(**doctor_data)
                doctor = doctor_service.create_doctor(doctor_dto)
                print(f"Created doctor: {doctor.name}")
            except Exception as e:
                print(f"Failed to create doctor {doctor_data['name']}: {str(e)}")
        
        print("Database initialization completed successfully!")
        
    except Exception as e:
        print(f"Database initialization failed: {str(e)}")
    finally:
        db.close()

if __name__ == "__main__":
    init_db()

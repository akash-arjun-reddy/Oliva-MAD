import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Load environment variables
load_dotenv()

# Database Configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+psycopg2://mobileapp:123@localhost:5432/mobileapp")
ZENOTI_DATABASE_URL = os.getenv("ZENOTI_DATABASE_URL", DATABASE_URL)

# Create SQLAlchemy engine
engine = create_engine(DATABASE_URL, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Zenoti engine (using same database for now)
zenoti_engine = create_engine(ZENOTI_DATABASE_URL, echo=False)
ZenotiSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=zenoti_engine)

# Base class for models
Base = declarative_base()

def create_tables():
    """Create all tables"""
    try:
        Base.metadata.create_all(bind=engine)
        print("Tables created successfully")
    except Exception as e:
        print(f"Error creating tables: {e}")

def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_zenoti_db():
    """Get Zenoti database session"""
    db = ZenotiSessionLocal()
    try:
        yield db
    finally:
        db.close()

# Application secrets
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30")) 
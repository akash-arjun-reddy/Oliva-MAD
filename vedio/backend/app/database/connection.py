# Database connection module
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.config.settings import settings
import os

# Database configuration
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_USER = os.getenv("DB_USER", "mobileapp")
DB_PASSWORD = os.getenv("DB_PASSWORD", "123")
DB_NAME = os.getenv("DB_NAME", "mobileapp")
DB_SCHEMA = os.getenv("DB_SCHEMA", "test")

# PostgreSQL Database URL
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=300
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def create_schema_if_not_exists():
    """Create the schema if it doesn't exist"""
    with engine.connect() as connection:
        try:
            # Create schema if it doesn't exist
            connection.execute(text(f"CREATE SCHEMA IF NOT EXISTS {DB_SCHEMA}"))
            connection.commit()
            print(f"Schema '{DB_SCHEMA}' is ready")
        except Exception as e:
            print(f"Error creating schema: {e}")

def get_db():
    """Dependency to get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close() 
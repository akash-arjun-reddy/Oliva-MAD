import os
from dotenv import load_dotenv
from logger import logger
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from config.logger_config import setup_color_logging

# Load environment variables from .env file early
load_dotenv()

# === Database Configuration ===
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")
DATABASE_URL = os.getenv("DATABASE_URL")

# Boolean flag for SQL echo, default False
DB_ECHO = os.getenv("DB_ECHO", "False").lower() in ("true", "1", "yes")

# Construct DATABASE_URL if missing
if not DATABASE_URL:
    if not (DB_USER and DB_PASSWORD and DB_NAME):
        logger.error("DB_USER, DB_PASSWORD, and DB_NAME environment variables are required if DATABASE_URL is not set.")
        raise ValueError("Missing required DB environment variables")
    DATABASE_URL = (
        f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    logger.info("DATABASE_URL constructed from individual DB settings")

logger.info(f"Database URL: {DATABASE_URL}")
logger.info(f"DB_ECHO set to {DB_ECHO}")

# Create SQLAlchemy engine for main app DB
engine = create_engine(DATABASE_URL, echo=DB_ECHO)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# === Zenoti DB Configuration ===
ZENOTI_DATABASE_URL = os.getenv("ZENOTI_DATABASE_URL")
if not ZENOTI_DATABASE_URL:
    logger.error("ZENOTI_DATABASE_URL environment variable is required.")
    raise ValueError("Missing ZENOTI_DATABASE_URL")

zenoti_engine = create_engine(ZENOTI_DATABASE_URL, echo=DB_ECHO)
ZenotiSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=zenoti_engine)

# === Setup colored logging (assuming your setup_color_logging function is solid) ===

setup_color_logging()

# === Application Secrets and Config ===
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256")  # Default to HS256 if not set

try:
    ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
except ValueError:
    logger.warning("Invalid ACCESS_TOKEN_EXPIRE_MINUTES, falling back to 30")
    ACCESS_TOKEN_EXPIRE_MINUTES = 30

logger.info(f"SECRET_KEY loaded: {'*' * 8 if SECRET_KEY else 'None'}")  # Do not print actual key
logger.info(f"ALGORITHM: {ALGORITHM}")
logger.info(f"ACCESS_TOKEN_EXPIRE_MINUTES: {ACCESS_TOKEN_EXPIRE_MINUTES}")

# === Azure Email Settings ===
AZURE_TENANT_ID = os.getenv("AZURE_TENANT_ID")
AZURE_CLIENT_ID = os.getenv("AZURE_CLIENT_ID")
AZURE_CLIENT_SECRET = os.getenv("AZURE_CLIENT_SECRET")
AZURE_SCOPE = os.getenv("AZURE_SCOPE")
AZURE_MAIL_USER = os.getenv("AZURE_MAIL_USER")

logger.info("Azure email settings loaded")
logger.info(f"AZURE_MAIL_USER: {AZURE_MAIL_USER}")

# === Zenoti API Configuration ===
ZENOTI_USERNAME = os.getenv("ZENOTI_USERNAME")
ZENOTI_PASSWORD = os.getenv("ZENOTI_PASSWORD")
ZENOTI_ACCOUNT_NAME = os.getenv("ZENOTI_ACCOUNT_NAME")
ZENOTI_APP_VERSION = os.getenv("ZENOTI_APP_VERSION")
ZENOTI_METHOD_NAME = os.getenv("ZENOTI_METHOD_NAME")
ZENOTI_API_URL = os.getenv("ZENOTI_API_URL")

logger.info("Zenoti API config loaded")
logger.info(f"ZENOTI_USERNAME: {ZENOTI_USERNAME}")
logger.info(f"ZENOTI_METHOD_NAME: {ZENOTI_METHOD_NAME}")
logger.info(f"ZENOTI_API_URL: {ZENOTI_API_URL}")

# === Custom Config ===
try:
    MAX_DATE_RANGE_DAYS = int(os.getenv("MAX_DATE_RANGE_DAYS", "7"))
except ValueError:
    logger.warning("Invalid MAX_DATE_RANGE_DAYS, falling back to 7")
    MAX_DATE_RANGE_DAYS = 7

logger.info(f"MAX_DATE_RANGE_DAYS set to {MAX_DATE_RANGE_DAYS}")

from sqlalchemy.orm import declarative_base

Base = declarative_base()


def create_tables():
    # Create all tables including the order models
    Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_zenoti_db():
    db = ZenotiSessionLocal()
    try:
        yield db
    finally:
        db.close()


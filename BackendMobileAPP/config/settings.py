import os
from typing import Optional
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    # Database settings
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql+psycopg2://mobileapp:123@localhost:5432/mobileapp")
    DB_ECHO: bool = os.getenv("DB_ECHO", "True").lower() == "true"
    
    # Database connection details
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: str = os.getenv("DB_PORT", "5432")
    DB_USER: str = os.getenv("DB_USER", "mobileapp")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "")
    DB_NAME: str = os.getenv("DB_NAME", "mobileapp")
    SCHEMA: str = os.getenv("SCHEMA", "public")
    
    # JWT settings
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-here-change-this-in-production-development-only")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    
    # Email settings
    AZURE_MAIL_USER: str = os.getenv("AZURE_MAIL_USER", "devops@olivaclinic.com")
    AZURE_MAIL_PASSWORD: str = os.getenv("AZURE_MAIL_PASSWORD", "")
    AZURE_MAIL_SERVER: str = os.getenv("AZURE_MAIL_SERVER", "smtp.office365.com")
    AZURE_MAIL_PORT: int = int(os.getenv("AZURE_MAIL_PORT", "587"))
    
    # Azure settings
    AZURE_TENANT_ID: str = os.getenv("AZURE_TENANT_ID", "")
    AZURE_CLIENT_ID: str = os.getenv("AZURE_CLIENT_ID", "")
    AZURE_CLIENT_SECRET: str = os.getenv("AZURE_CLIENT_SECRET", "")
    AZURE_SCOPE: str = os.getenv("AZURE_SCOPE", "https://graph.microsoft.com/.default")
    
    # Zenoti API settings
    ZENOTI_BASE_URL: str = os.getenv("ZENOTI_BASE_URL", "https://oliva.zenoti.com/api/v100/services/integration/collectionsapi.aspx")
    ZENOTI_API_KEY: str = os.getenv("ZENOTI_API_KEY", "")
    ZENOTI_USERNAME: str = os.getenv("ZENOTI_USERNAME", "apisetup")
    ZENOTI_PASSWORD: str = os.getenv("ZENOTI_PASSWORD", "")
    ZENOTI_METHOD_NAME: str = os.getenv("ZENOTI_METHOD_NAME", "getCollectionsReport")
    ZENOTI_ACCOUNT_NAME: str = os.getenv("ZENOTI_ACCOUNT_NAME", "oliva")
    ZENOTI_APP_VERSION: str = os.getenv("ZENOTI_APP_VERSION", "v100")
    ZENOTI_API_URL: str = os.getenv("ZENOTI_API_URL", "https://oliva.zenoti.com/api/v100/services/integration/collectionsapi.aspx")
    MAX_DATE_RANGE_DAYS: int = int(os.getenv("MAX_DATE_RANGE_DAYS", "7"))
    
    # Zenoti Database settings
    ZENOTI_DB_HOST: str = os.getenv("ZENOTI_DB_HOST", "127.0.0.1")
    ZENOTI_DB_PORT: str = os.getenv("ZENOTI_DB_PORT", "5438")
    ZENOTI_DB_USER: str = os.getenv("ZENOTI_DB_USER", "olivadev")
    ZENOTI_DB_PASSWORD: str = os.getenv("ZENOTI_DB_PASSWORD", "")
    ZENOTI_DB_NAME: str = os.getenv("ZENOTI_DB_NAME", "olivadevdb")
    ZENOTI_DB_SCHEMA: str = os.getenv("ZENOTI_DB_SCHEMA", "test")
    ZENOTI_DATABASE_URL: str = os.getenv("ZENOTI_DATABASE_URL", "postgresql+psycopg2://olivadev:One-oliva#5432@127.0.0.1:5438/olivadevdb")
    
    # SendGrid settings
    SENDGRID_API_KEY: str = os.getenv("SENDGRID_API_KEY", "")
    
    # Email Configuration (for consultation)
    SENDER_EMAIL: str = os.getenv("SENDER_EMAIL", "akash.manda@olivaclinic.com")
    SENDER_PASSWORD: str = os.getenv("SENDER_PASSWORD", "")
    SMTP_SERVER: str = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
    
    # Jitsi Configuration
    JITSI_BASE_URL: str = os.getenv("JITSI_BASE_URL", "https://meet.jit.si")
    JITSI_CONFIG_PARAMS: str = os.getenv("JITSI_CONFIG_PARAMS", "config.prejoinPageEnabled=false&config.disableDeepLinking=true")
    
    # Doctor emails for consultation
    DOCTOR_EMAILS: dict = {
        "Dr. Mythree Koyyana": "mythree.koyyana@olivaclinic.com",
        "Dr. Nikhil Kadarla": "nikhil.kadarla@olivaclinic.com", 
        "Dr. Akhila Sandana": "akhila.sandana@olivaclinic.com",
        "Dr. Vyshnavi Mettala": "vyshnavi.mettala@olivaclinic.com"
    }
    
    # Google OAuth settings
    GOOGLE_CLIENT_ID: str = os.getenv("GOOGLE_CLIENT_ID", "")
    GOOGLE_CLIENT_SECRET: str = os.getenv("GOOGLE_CLIENT_SECRET", "")
    
    # App settings
    APP_NAME: str = "Oliva Clinic Backend"
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    
    class Config:
        env_file = ".env"
        extra = "allow"  # Allow extra fields from environment variables

settings = Settings() 
import os
from dotenv import load_dotenv
from typing import List, Dict

# load_dotenv()  # Commented out to avoid encoding issues

class Settings:
    """Application settings"""
    
    # App settings
    APP_NAME: str = "Oliva Virtual Clinic"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Server settings
    HOST: str = "127.0.0.1"
    PORT: int = 8002
    
    # CORS settings
    CORS_ORIGINS: List[str] = ["*"]
    CORS_ALLOW_CREDENTIALS: bool = True
    CORS_ALLOW_METHODS: List[str] = ["*"]
    CORS_ALLOW_HEADERS: List[str] = ["*"]
    
    # Database settings
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: str = os.getenv("DB_PORT", "5432")
    DB_USER: str = os.getenv("DB_USER", "mobileapp")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "")
    DB_NAME: str = os.getenv("DB_NAME", "mobileapp")
    DB_SCHEMA: str = os.getenv("DB_SCHEMA", "test")
    
    # Email settings
    SMTP_SERVER: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SENDER_EMAIL: str = "akash.manda@olivaclinic.com"
    SENDER_PASSWORD: str = os.getenv("SENDER_PASSWORD", "")
    
    # Doctor emails
    DOCTOR_EMAILS: Dict[str, str] = {
        "Dr. Mythree Koyyana": "mythree.koyyana@olivaclinic.com",
        "Dr. Nikhil Kadarla": "nikhil.kadarla@olivaclinic.com", 
        "Dr. Akhila Sandana": "akhila.sandana@olivaclinic.com",
        "Dr. Vyshnavi Mettala": "vyshnavi.mettala@olivaclinic.com"
    }
    
    # Jitsi Meet settings - Can be customized for your server
    JITSI_BASE_URL: str = os.getenv("JITSI_BASE_URL", "https://meet.jit.si")
    JITSI_CONFIG_PARAMS: str = os.getenv("JITSI_CONFIG_PARAMS", "config.prejoinPageEnabled=false&config.disableDeepLinking=true")
    
    # Custom Jitsi Meet server settings (if you have your own server)
    CUSTOM_JITSI_SERVER: str = os.getenv("CUSTOM_JITSI_SERVER", "")
    CUSTOM_JITSI_EMAIL: str = os.getenv("CUSTOM_JITSI_EMAIL", "")
    CUSTOM_JITSI_PASSWORD: str = os.getenv("CUSTOM_JITSI_PASSWORD", "")

# Create settings instance
settings = Settings() 
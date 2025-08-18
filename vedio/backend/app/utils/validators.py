import re
from datetime import datetime
from typing import Optional

def validate_time_format(time_str: str) -> bool:
    """Validate time format yyyy:mm:dd"""
    try:
        datetime.strptime(time_str, "%Y:%m:%d")
        return True
    except ValueError:
        return False

def validate_email(email: str) -> bool:
    """Validate email format"""
    if not email:
        return False
    email_regex = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    return bool(email_regex.match(email))

def sanitize_name(name: str) -> str:
    """Sanitize name for use in URL"""
    # Remove special characters and replace spaces with underscores
    sanitized = re.sub(r'[^a-zA-Z0-9\s]', '', name)
    sanitized = re.sub(r'\s+', '_', sanitized.strip())
    return sanitized

def validate_meeting_request(customer_name: str, doctor_name: str, slot_time: str) -> tuple[bool, Optional[str]]:
    """Validate meeting request data"""
    if not customer_name.strip():
        return False, "Customer name is required"
    
    if not doctor_name.strip():
        return False, "Doctor name is required"
    
    if not validate_time_format(slot_time):
        return False, "Invalid time format. Use yyyy:mm:dd"
    
    return True, None 
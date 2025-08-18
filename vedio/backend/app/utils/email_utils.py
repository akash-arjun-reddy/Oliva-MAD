#!/usr/bin/env python3
"""
Comprehensive email utilities with SendGrid (primary) and ICS calendar invites
"""

import requests
import logging
import json
import os
from datetime import datetime, timedelta
from typing import Optional
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
import base64

logger = logging.getLogger(__name__)

# SendGrid Configuration (Primary)
SENDGRID_API_KEY = os.getenv("SENDGRID_API_KEY", "")
SENDGRID_FROM_EMAIL = "akash.manda@olivaclinic.com"  # Use proper email format
SENDGRID_TEMPLATE_ID = "d-d88671f45f0e4eaebee1a8b3ba4f1369"

# Azure Configuration (Paused)
AZURE_TENANT_ID = os.getenv("AZURE_TENANT_ID")
AZURE_CLIENT_ID = os.getenv("AZURE_CLIENT_ID")
AZURE_CLIENT_SECRET = os.getenv("AZURE_CLIENT_SECRET")
AZURE_SCOPE = os.getenv("AZURE_SCOPE", "https://graph.microsoft.com/.default")
AZURE_MAIL_USER = os.getenv("AZURE_MAIL_USER", "devops@olivaclinic.com")

# Gmail SMTP (Fallback)
GMAIL_USER = os.getenv("GMAIL_USER", "akash.manda@olivaclinic.com")
GMAIL_PASSWORD = os.getenv("GMAIL_PASSWORD")

class EmailConfig:
    """Email configuration and provider management"""
    
    def __init__(self):
        self.primary_provider = "sendgrid"  # Always use SendGrid as primary
        self.fallback_provider = "gmail"    # Gmail as fallback
        
    def get_provider_status(self):
        """Get status of all email providers"""
        return {
            "sendgrid": bool(SENDGRID_API_KEY),
            "azure": False,  # Paused
            "gmail": bool(GMAIL_PASSWORD),
            "primary": self.primary_provider,
            "fallback": self.fallback_provider
        }

# Global email config
email_config = EmailConfig()

def send_email_sendgrid(to_email: str, subject: str, body: str, attachment_path: Optional[str] = None) -> bool:
    """Send email using SendGrid API with template"""
    try:
        if not SENDGRID_API_KEY:
            logger.warning("SendGrid API key not configured")
            return False
            
        # Prepare email data with template
        email_data = {
            "personalizations": [
                {
                    "to": [{"email": to_email}],
                    "subject": subject,
                    "dynamic_template_data": {
                        "appointment_date": body.get("appointment_date", ""),
                        "time_slot": body.get("time_slot", ""),
                        "doctor_name": body.get("doctor_name", ""),
                        "patient_name": body.get("patient_name", ""),
                        "meeting_link": body.get("meeting_link", ""),
                        "passcode": body.get("passcode", ""),
                        "concern": body.get("concern", "")
                    }
                }
            ],
            "from": {"email": SENDGRID_FROM_EMAIL},
            "template_id": SENDGRID_TEMPLATE_ID
        }
        
        # Add attachment if provided (ICS file)
        if attachment_path and os.path.exists(attachment_path):
            with open(attachment_path, "rb") as f:
                attachment_content = f.read()
                attachment_encoded = base64.b64encode(attachment_content).decode()
                
                email_data["attachments"] = [
                    {
                        "content": attachment_encoded,
                        "filename": os.path.basename(attachment_path),
                        "type": "text/calendar",
                        "disposition": "attachment"
                    }
                ]
        
        # Send via SendGrid API
        headers = {
            "Authorization": f"Bearer {SENDGRID_API_KEY}",
            "Content-Type": "application/json"
        }
        
        response = requests.post(
            "https://api.sendgrid.com/v3/mail/send",
            headers=headers,
            json=email_data
        )
        response.raise_for_status()
        
        logger.info(f"✅ SendGrid email sent successfully to {to_email}")
        return True
        
    except Exception as e:
        logger.error(f"❌ SendGrid email failed to {to_email}: {str(e)}")
        return False

def send_email_gmail(to_email: str, subject: str, body: str, attachment_path: Optional[str] = None) -> bool:
    """Send email using Gmail SMTP (fallback)"""
    try:
        if not GMAIL_PASSWORD:
            logger.warning("⚠️ Gmail password not configured")
            return False
            
        msg = MIMEMultipart()
        msg['From'] = GMAIL_USER
        msg['To'] = to_email
        msg['Subject'] = subject
        
        msg.attach(MIMEText(body, 'html'))
        
        # Add attachment if provided (ICS file)
        if attachment_path and os.path.exists(attachment_path):
            with open(attachment_path, "rb") as attachment:
                part = MIMEBase('text', 'calendar')
                part.set_payload(attachment.read())
                encoders.encode_base64(part)
                part.add_header(
                    'Content-Disposition',
                    f'attachment; filename= {os.path.basename(attachment_path)}'
                )
                msg.attach(part)
        
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        server.login(GMAIL_USER, GMAIL_PASSWORD)
        text = msg.as_string()
        server.sendmail(GMAIL_USER, to_email, text)
        server.quit()
        
        logger.info(f"✅ Gmail email sent successfully to {to_email}")
        return True
        
    except Exception as e:
        logger.error(f"❌ Failed to send Gmail email to {to_email}: {str(e)}")
        return False

def send_email_with_fallback(to_email: str, subject: str, body, attachment_path: Optional[str] = None) -> bool:
    """Send email with automatic fallback between providers"""
    providers = [email_config.primary_provider, email_config.fallback_provider]
    
    for provider in providers:
        try:
            if provider == "sendgrid":
                if send_email_sendgrid(to_email, subject, body, attachment_path):
                    return True
            elif provider == "gmail":
                # For Gmail fallback, convert template data to HTML if needed
                if isinstance(body, dict):
                    # Convert template data to simple HTML for Gmail
                    html_body = f"""
                    <h2>Appointment Details</h2>
                    <p><strong>Date:</strong> {body.get('appointment_date', '')}</p>
                    <p><strong>Time:</strong> {body.get('time_slot', '')}</p>
                    <p><strong>Doctor:</strong> {body.get('doctor_name', '')}</p>
                    <p><strong>Patient:</strong> {body.get('patient_name', '')}</p>
                    <p><strong>Meeting Link:</strong> <a href="{body.get('meeting_link', '')}">{body.get('meeting_link', '')}</a></p>
                    <p><strong>Passcode:</strong> {body.get('passcode', '')}</p>
                    <p><strong>Concern:</strong> {body.get('concern', '')}</p>
                    """
                else:
                    html_body = body
                
                if send_email_gmail(to_email, subject, html_body, attachment_path):
                    return True
        except Exception as e:
            logger.warning(f"⚠️ {provider} email failed, trying next provider: {str(e)}")
            continue
    
    logger.error(f"❌ All email providers failed for {to_email}")
    return False

def generate_ics_file(appointment) -> str:
    """Generate .ics calendar invite file"""
    try:
        from datetime import datetime, timedelta
        
        # Format appointment details
        appointment_date = appointment.date
        time_slot = appointment.time_slot
        
        # Parse time slot (e.g., "10:00" -> 10:00)
        hour, minute = map(int, time_slot.split(':'))
        start_time = datetime.combine(appointment_date, datetime.min.time().replace(hour=hour, minute=minute))
        end_time = start_time + timedelta(minutes=30)  # 30-minute appointment
        
        # Create .ics content
        ics_content = f"""BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Oliva Clinic//Appointment//EN
CALSCALE:GREGORIAN
METHOD:REQUEST
BEGIN:VEVENT
UID:{appointment.meeting_link.split('/')[-1]}
DTSTART:{start_time.strftime('%Y%m%dT%H%M%S')}
DTEND:{end_time.strftime('%Y%m%dT%H%M%S')}
DTSTAMP:{datetime.now().strftime('%Y%m%dT%H%M%SZ')}
ORGANIZER;CN=Oliva Clinic:mailto:akash.manda@olivaclinic.com
SUMMARY:Oliva Clinic Appointment
DESCRIPTION:Virtual consultation with {getattr(appointment, 'doctor_name', 'Doctor')}
LOCATION:{appointment.meeting_link}
STATUS:CONFIRMED
SEQUENCE:0
BEGIN:VALARM
TRIGGER:-PT10M
DESCRIPTION:Reminder
ACTION:DISPLAY
END:VALARM
END:VEVENT
END:VCALENDAR"""
        
        # Save to temporary file
        ics_filename = f"appointment_{appointment.id}.ics"
        ics_path = os.path.join("/tmp", ics_filename)
        
        # Create temp directory if it doesn't exist
        os.makedirs("/tmp", exist_ok=True)
        
        with open(ics_path, "w", encoding="utf-8") as f:
            f.write(ics_content)
        
        return ics_path
        
    except Exception as e:
        logger.error(f"❌ Failed to generate .ics file: {str(e)}")
        return None

def send_appointment_details_email(patient_email: str, doctor_email: str, appointment) -> bool:
    """Send appointment confirmation emails to both patient and doctor with calendar invite"""
    try:
        # Format appointment details
        appointment_date = appointment.date.strftime("%B %d, %Y")
        
        # Handle time slot formatting
        time_slot = appointment.time_slot
        if time_slot:
            try:
                hour, minute = map(int, time_slot.split(':'))
                if hour < 12:
                    time_display = f"{hour}:{minute:02d} AM"
                elif hour == 12:
                    time_display = f"{hour}:{minute:02d} PM"
                else:
                    time_display = f"{hour-12}:{minute:02d} PM"
            except:
                time_display = time_slot
        else:
            time_display = "TBD"
        
        # Generate calendar invite
        ics_path = generate_ics_file(appointment)
        
        # Prepare template data
        template_data = {
            "appointment_date": appointment_date,
            "time_slot": time_display,
            "doctor_name": getattr(appointment, 'doctor_name', 'Your Doctor'),
            "patient_name": getattr(appointment, 'patient_name', 'Patient'),
            "meeting_link": appointment.meeting_link,
            "passcode": getattr(appointment, 'passcode', 'No passcode required'),
            "concern": getattr(appointment, 'concern', 'Not specified')
        }
        
        # Patient email
        patient_subject = f"Appointment Confirmation - {appointment_date}"
        
        # Doctor email
        doctor_subject = f"New Appointment - {appointment_date}"
        
        # Send emails with template data
        patient_sent = send_email_with_fallback(patient_email, patient_subject, template_data, ics_path)
        doctor_sent = send_email_with_fallback(doctor_email, doctor_subject, template_data, ics_path)
        
        return patient_sent and doctor_sent
        
    except Exception as e:
        logger.error(f"❌ Failed to send appointment emails: {str(e)}")
        return False

def send_reminder_email(patient_email: str, doctor_email: str, appointment) -> bool:
    """Send reminder emails 10 minutes before appointment"""
    try:
        appointment_date = appointment.date.strftime("%B %d, %Y")
        time_slot = appointment.time_slot
        if time_slot:
            try:
                hour, minute = map(int, time_slot.split(':'))
                if hour < 12:
                    time_display = f"{hour}:{minute:02d} AM"
                elif hour == 12:
                    time_display = f"{hour}:{minute:02d} PM"
                else:
                    time_display = f"{hour-12}:{minute:02d} PM"
            except:
                time_display = time_slot
        else:
            time_display = "TBD"
        
        reminder_subject = f"Appointment Reminder - {appointment_date} at {time_display}"
        reminder_body = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Appointment Reminder</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0; }}
        .content {{ background: #f9f9f9; padding: 20px; border-radius: 0 0 10px 10px; }}
        .reminder {{ background: white; padding: 15px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #ff6b6b; }}
        .button {{ display: inline-block; background: #ff6b6b; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 10px 0; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⏰ Appointment Reminder</h1>
            <h2>Your appointment starts in 10 minutes!</h2>
        </div>
        <div class="content">
            <div class="reminder">
                <h3>📅 Appointment Details</h3>
                <p><strong>Date:</strong> {appointment_date}</p>
                <p><strong>Time:</strong> {time_display}</p>
                <p><strong>Meeting Link:</strong> <a href="{appointment.meeting_link}">{appointment.meeting_link}</a></p>
                <p><strong>Passcode:</strong> {getattr(appointment, 'passcode', 'No passcode required')}</p>
            </div>
            
            <p><strong>Please join the meeting now!</strong></p>
            
            <a href="{appointment.meeting_link}" class="button">Join Meeting Now</a>
        </div>
    </div>
</body>
</html>
"""
        
        # Send reminder to both patient and doctor
        patient_sent = send_email_with_fallback(patient_email, reminder_subject, reminder_body)
        doctor_sent = send_email_with_fallback(doctor_email, reminder_subject, reminder_body)
        
        return patient_sent and doctor_sent
        
    except Exception as e:
        logger.error(f"❌ Failed to send reminder emails: {str(e)}")
        return False

def send_alert_to_admin(message: str) -> bool:
    """Send alert to admin about system issues"""
    try:
        admin_email = "admin@olivaclinic.com"
        subject = "Oliva Clinic System Alert"
        body = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>System Alert</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0; }}
        .content {{ background: #f9f9f9; padding: 20px; border-radius: 0 0 10px 10px; }}
        .alert {{ background: white; padding: 15px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #ff6b6b; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚨 System Alert</h1>
        </div>
        <div class="content">
            <div class="alert">
                <h3>Alert Message</h3>
                <p>{message}</p>
                <p><strong>Time:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
            </div>
            <p>Please check the system immediately.</p>
        </div>
    </div>
</body>
</html>
"""
        
        return send_email_with_fallback(admin_email, subject, body)
        
    except Exception as e:
        logger.error(f"❌ Failed to send admin alert: {str(e)}")
        return False

# Legacy function for backward compatibility
def send_email(to_email: str, subject: str, body: str, attachment_path: Optional[str] = None) -> bool:
    """Legacy email function - now uses fallback system"""
    return send_email_with_fallback(to_email, subject, body, attachment_path)

# For backward compatibility (Azure paused)
def send_email_azure(to_email: str, subject: str, body: str) -> bool:
    """Legacy Azure email function - now uses SendGrid"""
    return send_email_with_fallback(to_email, subject, body, None)

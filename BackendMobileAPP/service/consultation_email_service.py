import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import List, Optional
from datetime import date
from config.settings import settings
import re

class ConsultationEmailService:
    """Service for handling consultation email operations"""
    
    @staticmethod
    def validate_email(email: str) -> bool:
        """Validate email format"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(pattern, email) is not None
    
    @staticmethod
    def send_email(to_email: str, subject: str, body: str) -> bool:
        """Send email using SMTP"""
        try:
            # Check if email configuration is set
            if not settings.SENDER_EMAIL or not settings.SENDER_PASSWORD:
                print("Email configuration not set")
                return False
            
            # Validate email format
            if not ConsultationEmailService.validate_email(to_email):
                print(f"Invalid email format: {to_email}")
                return False
                
            msg = MIMEMultipart()
            msg['From'] = settings.SENDER_EMAIL
            msg['To'] = to_email
            msg['Subject'] = subject
            
            msg.attach(MIMEText(body, 'html'))
            
            server = smtplib.SMTP(settings.SMTP_SERVER, settings.SMTP_PORT)
            server.starttls()
            server.login(settings.SENDER_EMAIL, settings.SENDER_PASSWORD)
            text = msg.as_string()
            server.sendmail(settings.SENDER_EMAIL, to_email, text)
            server.quit()
            return True
        except Exception as e:
            print(f"Email sending failed: {e}")
            return False
    
    @staticmethod
    def create_meeting_email_body(customer_name: str, doctor_name: str, slot_time: str, meeting_link: str) -> str:
        """Create HTML email body for meeting invitation"""
        return f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Oliva Clinic - Consultation Meeting</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 0 auto; background: white; }}
        .header {{ background: white; padding: 20px; text-align: center; border-bottom: 2px solid #20B2AA; }}
        .logo {{ font-size: 32px; font-weight: bold; color: #20B2AA; margin-bottom: 10px; }}
        .logo-o {{ font-size: 40px; color: #20B2AA; }}
        .subtitle {{ color: #666; font-size: 14px; margin: 5px 0; }}
        .clinic-text {{ color: #20B2AA; font-size: 16px; margin-top: 10px; }}
        .content {{ padding: 30px; }}
        .meeting-details {{ background: #f9f9f9; padding: 20px; border-radius: 8px; margin: 20px 0; }}
        .meeting-link {{ background: #20B2AA; color: white; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0; }}
        .meeting-link a {{ color: white; text-decoration: none; font-weight: bold; }}
        .instructions {{ background: #fff3cd; padding: 15px; border-radius: 8px; margin: 20px 0; }}
        .footer {{ background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">O<span class="logo-o">liva</span></div>
            <div class="clinic-text">Virtual Clinic</div>
            <div class="subtitle">Professional Skin Care Consultation</div>
        </div>
        
        <div class="content">
            <h2>Your Consultation Meeting is Ready!</h2>
            
            <div class="meeting-details">
                <h3>Meeting Details:</h3>
                <p><strong>Patient:</strong> {customer_name}</p>
                <p><strong>Doctor:</strong> {doctor_name}</p>
                <p><strong>Date & Time:</strong> {slot_time}</p>
            </div>
            
            <div class="meeting-link">
                <a href="{meeting_link}" target="_blank">Join Consultation Meeting</a>
            </div>
            
            <div class="instructions">
                <h4>Instructions:</h4>
                <ul>
                    <li>Click the "Join Consultation Meeting" button above</li>
                    <li>Allow camera and microphone access when prompted</li>
                    <li>Ensure you have a stable internet connection</li>
                    <li>Test your camera and microphone before joining</li>
                    <li>Close other applications for better performance</li>
                </ul>
            </div>
            
            <p><strong>Note:</strong> The meeting will start automatically when both parties join.</p>
        </div>
        
        <div class="footer">
            <p>© 2024 Oliva Clinic. All rights reserved.</p>
            <p>For technical support, contact: support@olivaclinic.com</p>
        </div>
    </div>
</body>
</html>
"""
    
    @staticmethod
    def send_meeting_emails(
        customer_name: str, 
        doctor_name: str, 
        slot_time: str, 
        meeting_link: str,
        customer_email: Optional[str] = None,
        doctor_email: Optional[str] = None
    ) -> List[str]:
        """Send meeting emails to both parties"""
        emails_sent = []
        subject = f"Oliva Clinic - Consultation Meeting for {customer_name} & {doctor_name}"
        body = ConsultationEmailService.create_meeting_email_body(customer_name, doctor_name, slot_time, meeting_link)
        
        # Send to customer
        if customer_email:
            if ConsultationEmailService.send_email(customer_email, subject, body):
                emails_sent.append(f"Customer email sent to {customer_email}")
            else:
                emails_sent.append(f"Failed to send email to customer {customer_email}")
        
        # Send to doctor
        if doctor_email:
            if ConsultationEmailService.send_email(doctor_email, subject, body):
                emails_sent.append(f"Doctor email sent to {doctor_email}")
            else:
                emails_sent.append(f"Failed to send email to doctor {doctor_email}")
        
        return emails_sent
    
    @staticmethod
    def send_doctor_appointment_email(
        doctor_email: str,
        doctor_name: str,
        patient_name: str,
        appointment_date: date,
        time_slot: str,
        meeting_link: str,
        concern: Optional[str] = None
    ) -> bool:
        """Send appointment confirmation email to doctor"""
        subject = f"New Consultation Appointment - {patient_name}"
        
        concern_text = f"<p><strong>Patient Concern:</strong> {concern}</p>" if concern else ""
        
        body = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>New Consultation Appointment</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: #20B2AA; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; }}
        .meeting-link {{ background: #20B2AA; color: white; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0; }}
        .meeting-link a {{ color: white; text-decoration: none; font-weight: bold; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>New Consultation Appointment</h2>
        </div>
        <div class="content">
            <h3>Appointment Details:</h3>
            <p><strong>Patient:</strong> {patient_name}</p>
            <p><strong>Date:</strong> {appointment_date}</p>
            <p><strong>Time:</strong> {time_slot}</p>
            {concern_text}
            
            <div class="meeting-link">
                <a href="{meeting_link}" target="_blank">Join Consultation Meeting</a>
            </div>
            
            <p>Please join the meeting at the scheduled time.</p>
        </div>
    </div>
</body>
</html>
"""
        
        return ConsultationEmailService.send_email(doctor_email, subject, body)
    
    @staticmethod
    def send_patient_appointment_email(
        patient_email: str,
        patient_name: str,
        doctor_name: str,
        appointment_date: date,
        time_slot: str,
        meeting_link: str,
        passcode: str,
        concern: Optional[str] = None
    ) -> bool:
        """Send appointment confirmation email to patient"""
        subject = f"Oliva Clinic - Consultation Appointment Confirmation"
        
        concern_text = f"<p><strong>Your Concern:</strong> {concern}</p>" if concern else ""
        
        body = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Appointment Confirmation</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: #20B2AA; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; }}
        .meeting-link {{ background: #20B2AA; color: white; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0; }}
        .meeting-link a {{ color: white; text-decoration: none; font-weight: bold; }}
        .passcode {{ background: #f8f9fa; padding: 10px; border-radius: 5px; margin: 10px 0; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Appointment Confirmation</h2>
        </div>
        <div class="content">
            <h3>Your consultation appointment has been confirmed!</h3>
            
            <p><strong>Doctor:</strong> {doctor_name}</p>
            <p><strong>Date:</strong> {appointment_date}</p>
            <p><strong>Time:</strong> {time_slot}</p>
            {concern_text}
            
            <div class="passcode">
                <strong>Meeting Passcode:</strong> {passcode}
            </div>
            
            <div class="meeting-link">
                <a href="{meeting_link}" target="_blank">Join Consultation Meeting</a>
            </div>
            
            <p>Please join the meeting 5 minutes before the scheduled time.</p>
        </div>
    </div>
</body>
</html>
"""
        
        return ConsultationEmailService.send_email(patient_email, subject, body)

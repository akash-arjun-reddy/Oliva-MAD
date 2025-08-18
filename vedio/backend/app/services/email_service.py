import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import List, Optional
from datetime import date
from app.config.settings import settings
from app.utils.validators import validate_email

class EmailService:
    """Service for handling email operations"""
    
    @staticmethod
    def send_email(to_email: str, subject: str, body: str) -> bool:
        """Send email using SMTP"""
        try:
            # Check if email configuration is set
            if not settings.SENDER_EMAIL or not settings.SENDER_PASSWORD:
                return False
            
            # Validate email format
            if not validate_email(to_email):
                return False
                
            msg = MIMEMultipart()
            msg['From'] = settings.SENDER_EMAIL
            msg['To'] = to_email
            msg['Subject'] = subject
            
            msg.attach(MIMEText(body, 'plain'))
            
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
        """Create email body for meeting invitation"""
        return f"""
Hello,

Your Jitsi Meet meeting link has been generated:

Meeting Details:
- Customer: {customer_name}
- Doctor: {doctor_name}
- Date: {slot_time}
- Meeting Link: {meeting_link}

Instructions:
1. Click the link above to join the meeting
2. Allow camera and microphone access when prompted
3. The meeting will start automatically when both parties join

Tips for the best experience:
- Use a stable internet connection
- Test your camera and microphone before joining
- Close other applications to improve performance

Best regards,
Jitsi Meet Link Generator
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
        subject = f"Jitsi Meet Link - {customer_name} & {doctor_name}"
        body = EmailService.create_meeting_email_body(customer_name, doctor_name, slot_time, meeting_link)
        
        # Send to customer
        if customer_email:
            if EmailService.send_email(customer_email, subject, body):
                emails_sent.append(f"Customer email sent to {customer_email}")
            else:
                emails_sent.append(f"Failed to send email to customer {customer_email}")
        
        # Send to doctor
        if doctor_email:
            if EmailService.send_email(doctor_email, subject, body):
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
        """Send appointment notification email to doctor"""
        subject = f"New Appointment - {patient_name} on {appointment_date.strftime('%B %d, %Y')}"
        
        concern_text = f"\nPatient Concern: {concern}" if concern else ""
        
        body = f"""
Dear Dr. {doctor_name},

You have a new appointment scheduled:

Patient: {patient_name}
Date: {appointment_date.strftime('%B %d, %Y')}
Time: {time_slot}
Meeting Link: {meeting_link}{concern_text}

Please join the meeting 5 minutes before the scheduled time.

Best regards,
Oliva Skin & Hair Clinic
"""
        
        return EmailService.send_email(doctor_email, subject, body)
    
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
        subject = f"Appointment Confirmation - {appointment_date.strftime('%B %d, %Y')}"
        
        concern_text = f"\nYour Concern: {concern}" if concern else ""
        
        body = f"""
Dear {patient_name},

Your appointment has been confirmed:

Doctor: {doctor_name}
Date: {appointment_date.strftime('%B %d, %Y')}
Time: {time_slot}
Meeting Link: {meeting_link}
Passcode: {passcode}{concern_text}

Instructions:
1. Click the meeting link 5 minutes before your appointment
2. Enter the passcode when prompted
3. Allow camera and microphone access
4. Wait for the doctor to join

Tips for the best experience:
- Use a stable internet connection
- Test your camera and microphone before joining
- Find a quiet, well-lit location
- Have your medical history ready if needed

If you need to reschedule or cancel, please contact us at least 24 hours in advance.

Best regards,
Oliva Skin & Hair Clinic
"""
        
        return EmailService.send_email(patient_email, subject, body) 
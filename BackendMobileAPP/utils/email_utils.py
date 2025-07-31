import requests
import json
from fastapi import HTTPException
import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail, Attachment, FileContent, FileName, FileType, Disposition
import base64

from config import settings
from models import appointment


# import your settings instance

def get_access_token():
    url = f'https://login.microsoftonline.com/{settings.AZURE_TENANT_ID}/oauth2/v2.0/token'
    payload = {
        'client_id':    settings.AZURE_CLIENT_ID,
        'client_secret': settings.AZURE_CLIENT_SECRET,
        'scope': settings.AZURE_SCOPE,
        'grant_type': 'client_credentials'
    }
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    response = requests.post(url, data=payload, headers=headers)

    if response.status_code == 200:
        return response.json().get('access_token')
    else:
        raise HTTPException(status_code=500, detail="Failed to get access token for email service")

def send_password_reset_email(to_email: str, reset_link: str):
    access_token = get_access_token()
    email_msg = {
        "message": {
            "subject": "Password Reset Request",
            "body": {
                "contentType": "Text",
                "content": f"Copy the Token to reset your password:\n\n{reset_link}\n\nIf you did not request this, please ignore."
            },
            "toRecipients": [{"emailAddress": {"address": to_email}}]
        }
    }
    email_headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }

    email_url = f'https://graph.microsoft.com/v1.0/users/{settings.AZURE_MAIL_USER}/sendMail'
    email_response = requests.post(email_url, headers=email_headers, data=json.dumps(email_msg))

    if email_response.status_code != 202:
        raise HTTPException(status_code=500, detail=f"Failed to send email: {email_response.text}")

def send_email_sendgrid(to_emails, subject, body, attachment_path=None):
    message = Mail(
        from_email='akash.manda@olivaclinic.com',
        to_emails=to_emails,  # Can be a string or a list of emails
        subject=subject,
        plain_text_content=body
    )
    if attachment_path:
        with open(attachment_path, "rb") as f:
            data = f.read()
            encoded = base64.b64encode(data).decode()
        attachedFile = Attachment(
            FileContent(encoded),
            FileName("appointment.ics"),
            FileType("text/calendar"),
            Disposition("attachment")
        )
        message.attachment = attachedFile
    try:
        sg = SendGridAPIClient(os.getenv("SENDGRID_API_KEY"))
        response = sg.send(message)
        if response.status_code not in [200, 202]:
            raise Exception(f"SendGrid error: {response.status_code} {response.body}")
    except Exception as e:
        print(f"Error sending email: {e}")
        raise

# Example functions for reminders and appointment details

def send_appointment_details_email(patient_email, doctor_email, appointment):
    subject = "Appointment Scheduled"
    body = (
        f"Dear Patient,\n\n"
        f"Your appointment is scheduled:\n"
        f"\U0001F4C5 Date: {appointment.date}\n"
        f"\U0001F552 Time: {appointment.start_time} - {appointment.end_time}\n"
        f"\U0001F517 Video Call: {appointment.video_call_link}\n\n"
        f"Regards,\nClinic Team"
    )
    from utils.ics_utils import generate_ics_file
    ics_path = generate_ics_file(appointment)
    send_email_sendgrid([patient_email, doctor_email], subject, body, attachment_path=ics_path)
    os.remove(ics_path)

def send_reminder_email(patient_email, doctor_email, appointment):
    subject = "Appointment Reminder"
    body = (
        f"Dear Patient,\n\n"
        f"This is a reminder for your upcoming appointment:\n"
        f"\U0001F4C5 Date: {appointment.date}\n"
        f"\U0001F552 Time: {appointment.start_time} - {appointment.end_time}\n"
        f"\U0001F517 Video Call: {appointment.video_call_link}\n\n"
        f"Please be on time.\n\n"
        f"Regards,\nClinic Team"
    )
    send_email_sendgrid([patient_email, doctor_email], subject, body)


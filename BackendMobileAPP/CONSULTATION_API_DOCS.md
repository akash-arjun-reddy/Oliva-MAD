# Oliva Clinic Consultation API Documentation

## Overview
The Consultation API provides functionality for managing online video consultations using Jitsi Meet. It includes meeting generation, email notifications, and meeting management features.

## Base URL
```
http://localhost:8000/api/v1/consultation
```

## Configuration
The following environment variables need to be configured:

```env
# Email Configuration
SENDER_EMAIL=akash.manda@olivaclinic.com
SENDER_PASSWORD=your_app_password_here
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587

# Jitsi Configuration
JITSI_BASE_URL=https://meet.jit.si
JITSI_CONFIG_PARAMS=config.prejoinPageEnabled=false&config.disableDeepLinking=true
```

## Available Doctors
The system is pre-configured with the following doctors:
- Dr. Mythree Koyyana (mythree.koyyana@olivaclinic.com)
- Dr. Nikhil Kadarla (nikhil.kadarla@olivaclinic.com)
- Dr. Akhila Sandana (akhila.sandana@olivaclinic.com)
- Dr. Vyshnavi Mettala (vyshnavi.mettala@olivaclinic.com)

## API Endpoints

### 1. Health Check
**GET** `/api/v1/consultation/`

Returns a simple health check message.

**Response:**
```json
{
  "message": "Oliva Clinic Consultation API"
}
```

### 2. Generate Meeting Link
**POST** `/api/v1/consultation/generate-meeting`

Generates a unique Jitsi Meet link for consultation.

**Request Body:**
```json
{
  "customer_name": "John Doe",
  "doctor_name": "Dr. Mythree Koyyana",
  "slot_time": "2024-08-15 10:00 AM",
  "customer_email": "john.doe@example.com",
  "doctor_email": "mythree.koyyana@olivaclinic.com"
}
```

**Response:**
```json
{
  "meeting_id": "john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g",
  "meeting_link": "https://meet.jit.si/john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g#config.prejoinPageEnabled=false&config.disableDeepLinking=true",
  "customer_name": "John Doe",
  "doctor_name": "Dr. Mythree Koyyana",
  "slot_time": "2024-08-15 10:00 AM",
  "customer_email": "john.doe@example.com",
  "doctor_email": "mythree.koyyana@olivaclinic.com",
  "status": "active",
  "created_at": "2024-08-11T23:18:08.567Z"
}
```

### 3. Send Meeting Email
**POST** `/api/v1/consultation/send-meeting-email`

Generates a meeting link and sends emails to both parties.

**Request Body:** (Same as generate-meeting)

**Response:**
```json
{
  "meeting_id": "john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g",
  "meeting_link": "https://meet.jit.si/john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g#config.prejoinPageEnabled=false&config.disableDeepLinking=true",
  "emails_sent": [
    "Customer email sent to john.doe@example.com",
    "Doctor email sent to mythree.koyyana@olivaclinic.com"
  ],
  "message": "Meeting created and emails sent successfully"
}
```

### 4. Get Meeting Details
**GET** `/api/v1/consultation/meeting/{meeting_id}`

Retrieves meeting details by meeting ID.

**Response:**
```json
{
  "meeting_id": "john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g",
  "meeting_link": "https://meet.jit.si/john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g#config.prejoinPageEnabled=false&config.disableDeepLinking=true",
  "customer_name": "John Doe",
  "doctor_name": "Dr. Mythree Koyyana",
  "slot_time": "2024-08-15 10:00 AM",
  "customer_email": "john.doe@example.com",
  "doctor_email": "mythree.koyyana@olivaclinic.com",
  "status": "active",
  "created_at": "2024-08-11T23:18:08.567Z"
}
```

### 5. Get Meetings by Customer
**GET** `/api/v1/consultation/meetings/customer/{customer_name}`

Retrieves all meetings for a specific customer.

**Response:**
```json
[
  {
    "meeting_id": "john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g",
    "meeting_link": "https://meet.jit.si/john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g#config.prejoinPageEnabled=false&config.disableDeepLinking=true",
    "customer_name": "John Doe",
    "doctor_name": "Dr. Mythree Koyyana",
    "slot_time": "2024-08-15 10:00 AM",
    "customer_email": "john.doe@example.com",
    "doctor_email": "mythree.koyyana@olivaclinic.com",
    "status": "active",
    "created_at": "2024-08-11T23:18:08.567Z"
  }
]
```

### 6. Get Meetings by Doctor
**GET** `/api/v1/consultation/meetings/doctor/{doctor_name}`

Retrieves all meetings for a specific doctor.

**Response:** (Same format as customer meetings)

### 7. Get All Meetings
**GET** `/api/v1/consultation/meetings?skip=0&limit=100`

Retrieves all meetings with pagination.

**Query Parameters:**
- `skip` (optional): Number of records to skip (default: 0)
- `limit` (optional): Number of records to return (default: 100, max: 1000)

**Response:**
```json
{
  "meetings": [
    {
      "meeting_id": "john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g",
      "meeting_link": "https://meet.jit.si/john_doe_dr_mythree_koyyana_20250811_2318_rkcb4g#config.prejoinPageEnabled=false&config.disableDeepLinking=true",
      "customer_name": "John Doe",
      "doctor_name": "Dr. Mythree Koyyana",
      "slot_time": "2024-08-15 10:00 AM",
      "customer_email": "john.doe@example.com",
      "doctor_email": "mythree.koyyana@olivaclinic.com",
      "status": "active",
      "created_at": "2024-08-11T23:18:08.567Z"
    }
  ],
  "total": 1
}
```

### 8. Update Meeting Status
**PUT** `/api/v1/consultation/meeting/{meeting_id}/status?status={status}`

Updates the status of a meeting.

**Query Parameters:**
- `status`: New status (active, completed, cancelled)

**Response:** (Same as meeting details with updated status)

### 9. Delete Meeting
**DELETE** `/api/v1/consultation/meeting/{meeting_id}`

Deletes a meeting by ID.

**Response:**
```json
{
  "message": "Meeting deleted successfully"
}
```

### 10. Get Available Doctors
**GET** `/api/v1/consultation/doctors`

Retrieves the list of available doctors for consultation.

**Response:**
```json
{
  "doctors": [
    "Dr. Mythree Koyyana",
    "Dr. Nikhil Kadarla",
    "Dr. Akhila Sandana",
    "Dr. Vyshnavi Mettala"
  ],
  "total": 4
}
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Customer name is required"
}
```

### 404 Not Found
```json
{
  "detail": "Meeting not found"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error: Database connection failed"
}
```

## Email Templates

The system sends beautifully formatted HTML emails with:
- Oliva Clinic branding
- Meeting details
- Direct meeting link
- Instructions for joining
- Professional styling

## Testing

You can test the API using the provided test script:

```bash
python test_consultation.py
```

## Integration with Frontend

To integrate with your Flutter frontend, you can use these endpoints to:
1. Generate meeting links when appointments are confirmed
2. Send email notifications to patients and doctors
3. Track meeting status and history
4. Manage consultation schedules

## Security Notes

- Meeting IDs are generated with timestamps and random strings for uniqueness
- Email passwords should be stored securely as environment variables
- Consider implementing authentication for sensitive endpoints in production

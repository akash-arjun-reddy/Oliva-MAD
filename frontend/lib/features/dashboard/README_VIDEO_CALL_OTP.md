# Video Call OTP Integration

This document describes the OTP (One-Time Password) integration for video call access in the dashboard feature.

## Overview

The video call OTP integration adds an additional security layer before users can join video consultations. When a user clicks the "Join Video" button on an upcoming consultation card, the system:

1. **Sends OTP**: Generates and sends a 6-digit OTP to the user's registered phone number
2. **Verifies OTP**: User enters the OTP received on their phone
3. **Joins Video Call**: If OTP is verified, the video call link is provided and opened

## How It Works

### 1. User Authentication
- User must be logged in with a valid phone number
- Phone number is stored during login/signup for OTP functionality

### 2. Video Call OTP Flow
1. User clicks "Join Video" button on consultation card
2. System checks if user is authenticated
3. If authenticated, sends OTP to user's phone number
4. User enters OTP in the verification dialog
5. If OTP is verified, video call link is retrieved and opened
6. If OTP is invalid, error message is shown

### 3. Error Handling
- **Authentication errors**: Shows "Please log in" message
- **Phone number missing**: Shows "Phone number not found" message
- **Invalid OTP**: Shows "Invalid or expired OTP" message
- **Network errors**: Shows appropriate error messages

## Backend Components

### 1. New API Endpoints

#### Send Video Call OTP
```
POST /appointments/{appointment_id}/send-video-otp
Authorization: Bearer {token}
```

**Response:**
```json
{
  "message": "OTP sent successfully for video call access",
  "appointment_id": "uuid"
}
```

#### Verify Video Call OTP
```
POST /appointments/{appointment_id}/verify-video-otp
Authorization: Bearer {token}
Content-Type: application/json

{
  "contact_number": "+1234567890",
  "otp_code": "123456"
}
```

**Response:**
```json
{
  "message": "OTP verified successfully",
  "video_call_link": "https://meet.jit.si/{meeting-id}",
  "appointment_id": "uuid"
}
```

### 2. Updated Services

#### Appointment Controller (`MAD/BackendMobileAPP/controller/appointment_controller.py`)
- **`send_video_call_otp()`**: Sends OTP for video call access
- **`verify_video_call_otp()`**: Verifies OTP and returns video call link

#### Auth Service Integration
- Uses existing OTP infrastructure from `AuthService`
- Leverages existing SMS service for OTP delivery
- Reuses OTP validation logic

## Frontend Components

### 1. Updated Services

#### Token Service (`lib/services/token_service.dart`)
- **`saveUserPhoneNumber()`**: Saves user's phone number
- **`getUserPhoneNumber()`**: Retrieves user's phone number
- **`clearToken()`**: Also clears phone number on logout

#### Appointment API Service (`lib/features/dashboard/data/appointment_api_service.dart`)
- **`sendVideoCallOtp()`**: Sends OTP for video call access
- **`verifyVideoCallOtp()`**: Verifies OTP and gets video call link

### 2. New UI Components

#### Video Call OTP Dialog (`lib/features/dashboard/presentation/widgets/video_call_otp_dialog.dart`)
- **Features**:
  - 6-digit OTP input with auto-focus
  - Resend OTP functionality
  - Loading states
  - Error handling
  - Modern UI design

#### Updated Dashboard (`lib/features/dashboard/presentation/pages/newdashboard.dart`)
- **`_showVideoCallOtpDialog()`**: Shows OTP verification dialog
- **Updated `_handleJoinVideo()`**: Integrates OTP flow

### 3. Authentication Integration

#### Auth API Service (`lib/features/authentication/data/auth_api_service.dart`)
- **Updated `verifyPhoneOTP()`**: Saves phone number after successful verification
- **Updated `signupWithPhone()`**: Saves phone number after successful signup

## SMS Configuration

The OTP functionality uses the existing SMS service configuration:

### Development Mode (Default)
- OTPs are printed to console
- No actual SMS sent
- Useful for testing

### Production Mode (Twilio)
- Requires Twilio configuration
- Sends actual SMS to phone numbers
- Environment variables needed:
  ```
  SMS_PROVIDER=twilio
  TWILIO_ACCOUNT_SID=your_sid
  TWILIO_AUTH_TOKEN=your_token
  TWILIO_FROM_NUMBER=+1234567890
  ```

## Testing

### Backend Testing
```bash
cd MAD/BackendMobileAPP
python test_video_call_otp.py
```

### Frontend Testing
1. Login with phone number
2. Navigate to dashboard
3. Click "Join Video" on consultation card
4. Enter OTP received on phone
5. Verify video call opens

## Security Features

1. **Phone Number Verification**: Only registered phone numbers can receive OTPs
2. **OTP Expiry**: OTPs expire after 10 minutes
3. **Single Use**: Each OTP can only be used once
4. **Appointment Authorization**: Only appointment owners can request OTPs
5. **Token-based Authentication**: Requires valid authentication token

## Error Scenarios

### Common Issues and Solutions

1. **"Phone number not found"**
   - **Cause**: User logged in without phone number
   - **Solution**: Re-login with phone number or update profile

2. **"Invalid or expired OTP"**
   - **Cause**: Wrong OTP or expired OTP
   - **Solution**: Request new OTP and try again

3. **"Unauthorized access to appointment"**
   - **Cause**: User trying to access someone else's appointment
   - **Solution**: Contact support

4. **"Failed to send OTP"**
   - **Cause**: SMS service issues or invalid phone number
   - **Solution**: Check phone number format and SMS configuration

## Future Enhancements

1. **Rate Limiting**: Prevent OTP spam
2. **Voice OTP**: Alternative to SMS OTP
3. **Email OTP**: Backup OTP delivery method
4. **Biometric Verification**: Fingerprint/face recognition
5. **Multi-factor Authentication**: Combine with other verification methods

## Dependencies

### Backend
- FastAPI
- SQLAlchemy
- Twilio (for production SMS)
- Existing OTP infrastructure

### Frontend
- Flutter
- SharedPreferences (for phone number storage)
- HTTP package (for API calls)
- URL launcher (for video calls)

## Configuration

### Environment Variables
```env
# SMS Configuration
SMS_PROVIDER=development  # or twilio
TWILIO_ACCOUNT_SID=your_sid
TWILIO_AUTH_TOKEN=your_token
TWILIO_FROM_NUMBER=+1234567890

# OTP Configuration
OTP_LENGTH=6
OTP_EXPIRY_MINUTES=10
```

## Troubleshooting

### Backend Issues
1. Check SMS service configuration
2. Verify database connectivity
3. Check appointment authorization logic
4. Review OTP expiry settings

### Frontend Issues
1. Verify phone number is saved during login
2. Check API endpoint URLs
3. Review error handling in OTP dialog
4. Test with development mode first

### SMS Issues
1. Verify Twilio credentials (production)
2. Check phone number format (+1234567890)
3. Review SMS service logs
4. Test with development mode 
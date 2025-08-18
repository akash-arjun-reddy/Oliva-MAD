# Video Call Integration

This document describes the video call integration implemented in the dashboard feature.

## Overview

The video call integration allows users to join video consultations directly from the dashboard. When a user clicks the "Join Video" button on an upcoming consultation card, the system:

1. Authenticates the user
2. Retrieves the video call link from the backend
3. Opens the video call in an external browser/application

## Components

### Backend Components

#### 1. Appointment Service (`MAD/BackendMobileAPP/service/appointment_service.py`)
- **`get_appointment_by_id()`**: Retrieves appointment details including video call link
- **`book_appointment()`**: Creates appointments with Jitsi Meet video call links

#### 2. Appointment Controller (`MAD/BackendMobileAPP/controller/appointment_controller.py`)
- **`GET /appointments/{appointment_id}`**: Endpoint to get appointment details with video call link

### Frontend Components

#### 1. Token Service (`lib/services/token_service.dart`)
- Handles authentication token storage and retrieval using SharedPreferences
- Provides methods for token management and authentication status

#### 2. Appointment API Service (`lib/features/dashboard/data/appointment_api_service.dart`)
- Communicates with backend to retrieve appointment details
- Handles video call link retrieval

#### 3. Video Call Service (`lib/features/dashboard/services/video_call_service.dart`)
- Manages video call URL launching using url_launcher package
- Provides confirmation dialogs and error handling

#### 4. Updated Dashboard (`lib/features/dashboard/presentation/pages/newdashboard.dart`)
- Enhanced consultation card with video call functionality
- Loading states and error handling

## How It Works

### 1. User Authentication
- When users log in, their authentication token is automatically saved
- The token is used for all API calls requiring authentication

### 2. Video Call Flow
1. User clicks "Join Video" button on consultation card
2. System checks if user is authenticated
3. If authenticated, retrieves video call link from backend
4. Shows confirmation dialog
5. Opens video call link in external browser/application

### 3. Error Handling
- Authentication errors: Shows "Please log in" message
- Network errors: Shows appropriate error messages
- Missing video call links: Shows "No video call available" message

## API Endpoints

### Get Appointment Details
```
GET /appointments/{appointment_id}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "appointment_id": "uuid",
  "video_call_link": "https://meet.jit.si/{meeting-id}",
  "status": "Scheduled",
  "date": "2024-01-15",
  "start_time": "08:00:00",
  "end_time": "08:30:00",
  "doctor_id": 123,
  "patient_id": 456
}
```

## Dependencies

### Backend
- FastAPI
- SQLAlchemy
- JWT authentication
- UUID generation for meeting IDs

### Frontend
- `url_launcher: ^6.2.5` - For opening video call links
- `shared_preferences: ^2.2.2` - For token storage
- `http: ^1.1.0` - For API communication

## Video Call Platform

The system uses **Jitsi Meet** as the video calling platform:
- Free and open-source
- No account required
- Works in browsers and mobile apps
- Secure and encrypted

## Testing

Run the integration tests:
```bash
flutter test lib/features/dashboard/test/video_call_integration_test.dart
```

## Future Enhancements

1. **Real-time Status Updates**: Show when doctor joins the call
2. **Call History**: Track completed video calls
3. **Recording**: Option to record consultations (with consent)
4. **Screen Sharing**: Enable screen sharing during calls
5. **Chat Integration**: Text chat during video calls
6. **Mobile App Integration**: Deep linking to video call apps

## Security Considerations

1. **Token Management**: Tokens are securely stored and automatically cleared on logout
2. **Authorization**: Only appointment participants can access video call links
3. **HTTPS**: All API calls use HTTPS for secure communication
4. **Meeting IDs**: Unique UUIDs prevent unauthorized access to meetings

## Troubleshooting

### Common Issues

1. **"Authentication Required" Error**
   - User needs to log in first
   - Check if token is properly saved

2. **"No Video Call Available" Error**
   - Appointment may not have a video call link
   - Check backend appointment creation

3. **URL Launch Failure**
   - Check internet connection
   - Verify url_launcher package is properly configured

### Debug Steps

1. Check authentication status:
   ```dart
   bool isAuth = await TokenService.isAuthenticated();
   print('Is authenticated: $isAuth');
   ```

2. Check token:
   ```dart
   String? token = await TokenService.getToken();
   print('Token: $token');
   ```

3. Test API call:
   ```dart
   try {
     final link = await appointmentApiService.getVideoCallLink(appointmentId);
     print('Video call link: $link');
   } catch (e) {
     print('Error: $e');
   }
   ``` 
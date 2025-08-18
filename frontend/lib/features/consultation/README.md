# Consultation Feature

This feature provides a complete online consultation booking flow for the Oliva Clinic mobile app.

## Flow Overview

1. **Home Page** → User clicks "Consult" tab
2. **Consultation Page** → User selects "Online Consultation" → Clicks "Book Online Consultation"
3. **Doctor Selection Page** → User selects a doctor → Clicks "Book Now"
4. **Appointments Page** → Shows the booked consultation with "Join Video" button

## Pages

### 1. ConsultationPage (`presentation/pages/consultation_page.dart`)
- Shows consultation type selection (Offline/Online)
- When "Online Consultation" is selected, shows details and "Book Online Consultation" button
- Matches the design from the reference images

### 2. DoctorSelectionPage (`presentation/pages/doctor_selection_page.dart`)
- Displays available doctors from the backend API
- Shows doctor specialties, ratings, and fees
- "Book Now" button creates consultation and navigates to appointments

### 3. AppointmentsPage (`presentation/pages/appointments_page.dart`)
- Shows user's appointments with tabs (Past/Upcoming/Cancelled)
- Displays appointment details including doctor, treatment type, and time
- "Join Video" button launches the Jitsi Meet link

## Models

### Doctor (`data/models/doctor.dart`)
- Contains doctor information (name, specialization, email, fees, rating)
- Used for displaying doctor cards in selection page

### Appointment (`data/models/appointment.dart`)
- Contains appointment details (doctor, treatment, time, status, meeting link)
- Used for displaying appointments in the appointments page

## Service

### ConsultationService (`services/consultation_service.dart`)
- Integrates with the backend consultation API
- Methods:
  - `getAvailableDoctors()` - Fetches doctors from API
  - `createConsultation()` - Creates consultation booking
  - `getUserAppointments()` - Gets user's appointments
  - `joinMeeting()` - Launches meeting link

## Routes

### ConsultationRoutes (`routes/consultation_routes.dart`)
- Defines navigation routes for the consultation flow
- Routes:
  - `/consultation` - Main consultation page
  - `/doctor-selection` - Doctor selection page
  - `/appointments` - Appointments page

## Integration

### Backend API Integration
The consultation feature integrates with the backend consultation API:
- `GET /api/v1/consultation/doctors` - Get available doctors
- `POST /api/v1/consultation/send-meeting-email` - Create consultation booking
- `GET /api/v1/consultation/meetings/customer/{name}` - Get user appointments

### Navigation Integration
To integrate with the main app navigation:

1. Add the consultation routes to your main app routes:
```dart
// In your main app routes
routes: {
  ...ConsultationRoutes.getRoutes(),
}
```

2. Update your bottom navigation to navigate to consultation:
```dart
// When "Consult" tab is tapped
Navigator.pushNamed(context, ConsultationRoutes.consultation);
```

## Dependencies

Add these to your `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  url_launcher: ^6.2.1
```

## Usage

1. **Start the consultation flow:**
```dart
Navigator.pushNamed(context, ConsultationRoutes.consultation);
```

2. **Navigate to doctor selection:**
```dart
Navigator.pushNamed(context, ConsultationRoutes.doctorSelection);
```

3. **Navigate to appointments:**
```dart
Navigator.pushNamed(context, ConsultationRoutes.appointments);
```

## Features

- ✅ Complete consultation booking flow
- ✅ Doctor selection with ratings and fees
- ✅ Appointment management with status tracking
- ✅ Video meeting integration with Jitsi Meet
- ✅ Email notifications (handled by backend)
- ✅ Responsive design matching reference images
- ✅ Error handling and loading states
- ✅ Integration with backend consultation API

## Customization

- Update doctor specializations in `_getSpecializationForDoctor()`
- Modify appointment mock data in `getUserAppointments()`
- Customize UI colors and styles using app theme constants
- Add authentication headers to API calls if needed

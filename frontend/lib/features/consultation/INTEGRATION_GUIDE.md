# Consultation Feature Integration Guide

This guide shows how to integrate the consultation feature into your main Oliva Clinic app.

## Quick Integration Steps

### 1. Update Main App Routes

Add the consultation routes to your main app's route configuration:

```dart
// In your main.dart or app.dart
import 'package:oliva_clinic/features/consultation/routes/consultation_routes.dart';

// Add to your MaterialApp routes
MaterialApp(
  // ... other properties
  routes: {
    // ... your existing routes
    ...ConsultationRoutes.getRoutes(),
  },
  onGenerateRoute: ConsultationRoutes.onGenerateRoute,
)
```

### 2. Update Bottom Navigation

Update your bottom navigation to navigate to the consultation page when "Consult" is tapped:

```dart
// In your bottom navigation widget
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_bag),
      label: 'Shop',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite), // or Icons.videocam
      label: 'Consult',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Doctors',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore),
      label: 'Explore',
    ),
  ],
  onTap: (index) {
    if (index == 2) { // Consult tab
      Navigator.pushNamed(context, ConsultationRoutes.consultation);
    }
    // ... handle other tabs
  },
)
```

### 3. Update Environment Configuration

Make sure your `config/env.dart` has the correct API URL:

```dart
class Env {
  static const String apiUrl = 'http://localhost:8000'; // or your backend URL
}
```

### 4. Test the Integration

1. Start your backend server:
```bash
cd BackendMobileAPP
python main.py
```

2. Run your Flutter app:
```bash
cd frontend
flutter run
```

3. Navigate to the "Consult" tab and test the flow:
   - Select "Online Consultation"
   - Click "Book Online Consultation"
   - Select a doctor
   - Click "Book Now"
   - Verify the appointment appears in the appointments page

## Complete Flow Integration

### Home Page Integration

If you want to add a consultation button to your home page:

```dart
// In your home page
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, ConsultationRoutes.consultation);
  },
  child: Text('Book Consultation'),
)
```

### Dashboard Integration

If you want to show upcoming consultations on your dashboard:

```dart
// In your dashboard
FutureBuilder<List<Appointment>>(
  future: ConsultationService().getUserAppointments(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final upcomingAppointments = snapshot.data!
          .where((app) => app.status == 'scheduled')
          .take(3)
          .toList();
      
      return Column(
        children: upcomingAppointments.map((appointment) {
          return AppointmentCard(appointment: appointment);
        }).toList(),
      );
    }
    return CircularProgressIndicator();
  },
)
```

## Customization Options

### 1. Update Doctor Data

To customize the doctor information, update the helper methods in `ConsultationService`:

```dart
String _getSpecializationForDoctor(String doctorName) {
  // Add your custom specializations
  switch (doctorName) {
    case 'Dr. Mythree Koyyana':
      return 'Dermatology';
    // ... add more cases
  }
}
```

### 2. Customize Appointment Data

To show real appointment data instead of mock data, update the `getUserAppointments()` method:

```dart
Future<List<Appointment>> getUserAppointments() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/meetings/customer/Mr. Williamson'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((json) => Appointment.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Error loading appointments: $e');
  }
}
```

### 3. Add Authentication

If your API requires authentication, add headers to the service:

```dart
// In ConsultationService
static const Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token', // Add your auth token
};

// Use in API calls
final response = await http.get(
  Uri.parse('$baseUrl/doctors'),
  headers: headers,
);
```

## Troubleshooting

### Common Issues

1. **API Connection Error**: Make sure your backend server is running and accessible
2. **Route Not Found**: Verify that consultation routes are added to your main app routes
3. **Dependencies Missing**: Run `flutter pub get` to install dependencies
4. **URL Launcher Error**: Add URL launcher permissions to your app

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>https</string>
    <string>http</string>
</array>
```

## Testing

### Unit Tests

Create tests for the consultation service:

```dart
// test/features/consultation/services/consultation_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:oliva_clinic/features/consultation/services/consultation_service.dart';

void main() {
  group('ConsultationService', () {
    test('should get available doctors', () async {
      final service = ConsultationService();
      final doctors = await service.getAvailableDoctors();
      expect(doctors, isNotEmpty);
    });
  });
}
```

### Integration Tests

Test the complete flow:

```dart
// integration_test/consultation_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete consultation flow', (tester) async {
    // Navigate to consultation page
    // Select online consultation
    // Choose doctor
    // Book consultation
    // Verify appointment appears
  });
}
```

## Support

If you encounter any issues:

1. Check the backend API documentation in `BackendMobileAPP/CONSULTATION_API_DOCS.md`
2. Verify all dependencies are installed
3. Ensure the backend server is running
4. Check the Flutter console for error messages

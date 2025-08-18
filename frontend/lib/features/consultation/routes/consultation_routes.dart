import 'package:flutter/material.dart';
import 'package:frontend/features/consultation/presentation/pages/consultation_type_page.dart';
import 'package:frontend/features/consultation/presentation/pages/doctor_selection_page.dart';
import 'package:frontend/features/consultation/presentation/pages/appointments_page.dart';
import 'package:frontend/features/consultation/presentation/pages/email_demo_page.dart';

class ConsultationRoutes {
  static const String consultation = '/consultation';
  static const String consultationType = '/consultation-type';
  static const String doctorSelection = '/doctor-selection';
  static const String appointments = '/appointments';
  static const String emailDemo = '/email-demo';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      consultation: (context) => const ConsultationTypePage(),
      consultationType: (context) => const ConsultationTypePage(),
      doctorSelection: (context) => const DoctorSelectionPage(),
      appointments: (context) => const AppointmentsPage(),
      emailDemo: (context) => const EmailDemoPage(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case consultation:
        return MaterialPageRoute(
          builder: (context) => const ConsultationTypePage(),
        );
      case consultationType:
        return MaterialPageRoute(
          builder: (context) => const ConsultationTypePage(),
        );
      case doctorSelection:
        return MaterialPageRoute(
          builder: (context) => const DoctorSelectionPage(),
        );
      case appointments:
        return MaterialPageRoute(
          builder: (context) => const AppointmentsPage(),
        );
      case emailDemo:
        return MaterialPageRoute(
          builder: (context) => const EmailDemoPage(),
        );
      default:
        return null;
    }
  }
}

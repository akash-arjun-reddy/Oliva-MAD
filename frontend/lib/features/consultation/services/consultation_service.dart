import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/config/env.dart';
import 'package:frontend/features/consultation/data/models/doctor.dart';
import 'package:frontend/features/consultation/data/models/appointment.dart';

class ConsultationService {
  static const String baseUrl = 'https://oliva-clinic-backend.onrender.com/api/v1/consultation';

  // Get available doctors from the API
  Future<List<Doctor>> getAvailableDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctors'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final doctorsList = data['doctors'] as List;
        
        // Convert the simple doctor names to Doctor objects
        return doctorsList.asMap().entries.map((entry) {
          final index = entry.key;
          final doctorName = entry.value as String;
          
          // Create mock data for demonstration
          return Doctor(
            id: 'doctor_$index',
            name: doctorName,
            specialization: _getSpecializationForDoctor(doctorName),
            email: _getEmailForDoctor(doctorName),
            fees: 50.99,
            rating: 4.5,
            reviewCount: 2530,
          );
        }).toList();
      } else {
        throw Exception('Failed to load doctors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading doctors: $e');
    }
  }

  // Create a consultation booking
  Future<Map<String, dynamic>> createConsultation({
    required String customerName,
    required String doctorName,
    required String slotTime,
    required String customerEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-meeting-email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'customer_name': customerName,
          'doctor_name': doctorName,
          'slot_time': slotTime,
          'customer_email': customerEmail,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create consultation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating consultation: $e');
    }
  }

  // Get user appointments
  Future<List<Appointment>> getUserAppointments() async {
    try {
      // For demo purposes, return mock appointments
      // In real implementation, this would call the API
      return [
        Appointment(
          id: '1',
          doctorName: 'Dr. Andrea H.',
          treatmentType: 'Laser Treatment',
          consultationType: 'Video Consultation',
          dateTime: 'Friday, July 12 • 8:00 - 8:30 AM',
          status: 'scheduled',
          meetingLink: 'https://meet.jit.si/sample-meeting-123',
          meetingId: 'sample-meeting-123',
        ),
        Appointment(
          id: '2',
          doctorName: 'Dr. Amira Yuasha',
          treatmentType: 'Skin Consultation',
          consultationType: 'Video Consultation',
          dateTime: 'Friday, July 12 • 9:00 - 9:30 AM',
          status: 'scheduled',
          meetingLink: 'https://meet.jit.si/sample-meeting-456',
          meetingId: 'sample-meeting-456',
        ),
        Appointment(
          id: '3',
          doctorName: 'Dr. Eion Morgan',
          treatmentType: 'Hair Treatment',
          consultationType: 'Video Consultation',
          dateTime: 'Friday, July 12 • 10:00 - 10:30 AM',
          status: 'scheduled',
          meetingLink: 'https://meet.jit.si/sample-meeting-789',
          meetingId: 'sample-meeting-789',
        ),
        Appointment(
          id: '4',
          doctorName: 'Dr. Jerry Jones',
          treatmentType: 'Dermatology',
          consultationType: 'Video Consultation',
          dateTime: 'Saturday, July 13 • 9:00 - 9:30 AM',
          status: 'scheduled',
          meetingLink: 'https://meet.jit.si/sample-meeting-101',
          meetingId: 'sample-meeting-101',
        ),
        Appointment(
          id: '5',
          doctorName: 'Dr. Eion Morgan',
          treatmentType: 'Follow-up',
          consultationType: 'Video Consultation',
          dateTime: 'Saturday, July 13 • 10:00 - 10:30 AM',
          status: 'scheduled',
          meetingLink: 'https://meet.jit.si/sample-meeting-102',
          meetingId: 'sample-meeting-102',
        ),
      ];
    } catch (e) {
      throw Exception('Error loading appointments: $e');
    }
  }

  // Join meeting by launching the URL
  Future<void> joinMeeting(String meetingLink) async {
    try {
      final Uri url = Uri.parse(meetingLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch meeting link');
      }
    } catch (e) {
      throw Exception('Error joining meeting: $e');
    }
  }

  // Helper methods for mock data
  String _getSpecializationForDoctor(String doctorName) {
    switch (doctorName) {
      case 'Dr. Mythree Koyyana':
        return 'M.Ch (Neuro)';
      case 'Dr. Nikhil Kadarla':
        return 'Spinal Surgery';
      case 'Dr. Akhila Sandana':
        return 'MD, DNB(Endo)';
      case 'Dr. Vyshnavi Mettala':
        return 'Diploma (Cardiac EP)';
      default:
        return 'General Medicine';
    }
  }

  String _getEmailForDoctor(String doctorName) {
    switch (doctorName) {
      case 'Dr. Mythree Koyyana':
        return 'mythree.koyyana@olivaclinic.com';
      case 'Dr. Nikhil Kadarla':
        return 'nikhil.kadarla@olivaclinic.com';
      case 'Dr. Akhila Sandana':
        return 'akhila.sandana@olivaclinic.com';
      case 'Dr. Vyshnavi Mettala':
        return 'vyshnavi.mettala@olivaclinic.com';
      default:
        return 'doctor@olivaclinic.com';
    }
  }
}

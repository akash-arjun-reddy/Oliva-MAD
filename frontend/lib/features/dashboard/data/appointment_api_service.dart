import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../services/token_service.dart';

class AppointmentApiService {
  final String baseUrl;

  AppointmentApiService({required this.baseUrl});

  Future<Map<String, dynamic>> getAppointmentDetails(String appointmentId) async {
    final authHeader = await TokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/appointments/$appointmentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Appointment not found');
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized access to appointment');
    } else {
      throw Exception('Failed to load appointment details');
    }
  }

  Future<String> getVideoCallLink(String appointmentId) async {
    try {
      final appointmentData = await getAppointmentDetails(appointmentId);
      return appointmentData['video_call_link'] ?? '';
    } catch (e) {
      throw Exception('Failed to get video call link: $e');
    }
  }

  // Send OTP for video call access
  Future<Map<String, dynamic>> sendVideoCallOtp(String appointmentId) async {
    final authHeader = await TokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/send-video-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Appointment not found');
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized access to appointment');
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'Phone number not found for user');
    } else {
      throw Exception('Failed to send video call OTP');
    }
  }

  // Verify OTP and get video call link
  Future<Map<String, dynamic>> verifyVideoCallOtp(String appointmentId, String otpCode) async {
    final authHeader = await TokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/verify-video-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
      },
      body: json.encode({
        'contact_number': await TokenService.getUserPhoneNumber() ?? '',
        'otp_code': otpCode,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Appointment not found');
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized access to appointment');
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'Invalid or expired OTP');
    } else {
      throw Exception('Failed to verify video call OTP');
    }
  }
} 
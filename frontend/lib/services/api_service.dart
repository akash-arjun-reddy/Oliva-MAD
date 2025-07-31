import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class ApiService {
  // Send OTP to the provided phone number
  static Future<Map<String, dynamic>> sendOtp(String contactNumber) async {
    try {
      String baseUrl = await Env.findWorkingUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contact_number': contactNumber,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }
  
  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String contactNumber, String otpCode) async {
    try {
      String baseUrl = await Env.findWorkingUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contact_number': contactNumber,
          'otp_code': otpCode,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }
}
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/env.dart';

class AppConnectionTest {
  static Future<void> testBackendConnection() async {
    print('🔍 Testing backend connection...');
    
    try {
      String baseUrl = await Env.baseUrl;
      print('📍 Using backend URL: $baseUrl');
      
      // Test basic connectivity
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('✅ Backend is reachable! Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');
      
    } catch (e) {
      print('❌ Backend connection failed: $e');
      print('🔧 Please check if backend server is running');
    }
  }

  static Future<void> testOTPFlow() async {
    print('🔍 Testing OTP flow...');
    
    try {
      String baseUrl = await Env.baseUrl;
      
      // Test sending OTP
      final otpResponse = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'contact_number': '+919676052644'}),
      ).timeout(Duration(seconds: 10));
      
      print('📱 OTP Send Status: ${otpResponse.statusCode}');
      print('📄 OTP Response: ${otpResponse.body}');
      
      if (otpResponse.statusCode == 200) {
        print('✅ OTP sent successfully!');
      } else {
        print('❌ OTP send failed');
      }
      
    } catch (e) {
      print('❌ OTP test failed: $e');
    }
  }

  static Future<void> testAllEndpoints() async {
    print('🔍 Testing all endpoints...');
    
    try {
      String baseUrl = await Env.baseUrl;
      List<String> endpoints = [
        '/health',
        '/auth/send-otp',
        '/appointments/',
      ];
      
      for (String endpoint in endpoints) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
          ).timeout(Duration(seconds: 5));
          
          print('✅ $endpoint: ${response.statusCode}');
        } catch (e) {
          print('❌ $endpoint: Failed - $e');
        }
      }
      
    } catch (e) {
      print('❌ Endpoint test failed: $e');
    }
  }
} 
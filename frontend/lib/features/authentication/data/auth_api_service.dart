import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/env.dart';
import '../../../../services/token_service.dart';

class AuthApiService {
  String? _cachedBaseUrl;
  DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Get the working base URL with caching
  Future<String> get _baseUrl async {
    if (_cachedBaseUrl != null && _lastCacheTime != null) {
      if (DateTime.now().difference(_lastCacheTime!) < _cacheDuration) {
        return _cachedBaseUrl!;
      }
    }

    String workingUrl = await Env.findWorkingUrl();
    _cachedBaseUrl = workingUrl;
    _lastCacheTime = DateTime.now();
    return workingUrl;
  }

  // Phone-based authentication methods
  Future<Map<String, dynamic>> sendPhoneOTP(String phoneNumber) async {
    try {
      String baseUrl = await _baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'contact_number': phoneNumber}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> verifyPhoneOTP(String phoneNumber, String otpCode) async {
    try {
      String baseUrl = await _baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contact_number': phoneNumber,
          'otp_code': otpCode,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Save the token if it's present in the response
        if (responseData['access_token'] != null) {
          await TokenService.saveToken(
            responseData['access_token'],
            responseData['token_type'] ?? 'Bearer'
          );
          // Save the phone number for future OTP functionality
          await TokenService.saveUserPhoneNumber(phoneNumber);
        }
        
        return responseData;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> signupWithPhone({
    required String phoneNumber,
    required String password,
    required String otpCode,
    String? fullName,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      String baseUrl = await _baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup-phone'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contact_number': phoneNumber,
          'password': password,
          'otp_code': otpCode,
          'full_name': fullName,
          'gender': gender,
          'date_of_birth': dateOfBirth,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Save the token if it's present in the response
        if (responseData['access_token'] != null) {
          await TokenService.saveToken(
            responseData['access_token'],
            responseData['token_type'] ?? 'Bearer'
          );
          // Save the phone number for future OTP functionality
          await TokenService.saveUserPhoneNumber(phoneNumber);
        }
        
        return responseData;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to sign up');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Email-based authentication methods (existing)
  Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      String baseUrl = await _baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      String baseUrl = await _baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> setupUserProfile(Map<String, dynamic> profileData) async {
    try {
      String baseUrl = await _baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/setup-profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profileData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to setup user profile');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      String baseUrl = await _baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Save the token if it's present in the response
        if (responseData['access_token'] != null) {
          await TokenService.saveToken(
            responseData['access_token'],
            responseData['token_type'] ?? 'Bearer'
          );
        }
        
        return responseData;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
} 
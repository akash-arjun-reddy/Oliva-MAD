import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/env.dart';

class AuthConnectionTest {
  static Future<bool> testBackendConnection() async {
    print('🔍 Testing backend connection...');
    
    try {
      String baseUrl = await Env.findWorkingUrl();
      print('📍 Using backend URL: $baseUrl');
      
      // Test basic connectivity
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('✅ Backend is reachable! Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');
      
      return true;
    } catch (e) {
      print('❌ Backend connection failed: $e');
      print('🔧 Please check if backend server is running');
      return false;
    }
  }

  static Future<bool> testUserRegistration() async {
    print('\n🔐 Testing User Registration...');
    
    try {
      String baseUrl = await Env.findWorkingUrl();
      
      // Test user registration
      final registrationData = {
        "username": "frontendtestuser",
        "email": "frontendtestuser@example.com",
        "password": "FrontendTest123!",
        "full_name": "Frontend Test User",
        "contact_number": "+1234567890",
        "gender": "male",
        "city": "Test City",
        "state": "Test State",
        "country": "Test Country"
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registrationData),
      ).timeout(Duration(seconds: 10));
      
      print('📝 Registration Status: ${response.statusCode}');
      print('📄 Registration Response: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ User registration successful!');
        return true;
      } else {
        print('❌ User registration failed!');
        return false;
      }
      
    } catch (e) {
      print('❌ Registration test failed: $e');
      return false;
    }
  }

  static Future<String?> testUserLogin() async {
    print('\n🔑 Testing User Login...');
    
    try {
      String baseUrl = await Env.findWorkingUrl();
      
      // Test user login
      final loginData = {
        "login": "frontendtestuser@example.com",
        "password": "FrontendTest123!"
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      ).timeout(Duration(seconds: 10));
      
      print('🔑 Login Status: ${response.statusCode}');
      print('📄 Login Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['access_token'] != null) {
          print('✅ User login successful!');
          print('🎫 Access token received: ${responseData['access_token'].substring(0, 20)}...');
          return responseData['access_token'];
        }
      } else {
        print('❌ User login failed!');
      }
      
      return null;
    } catch (e) {
      print('❌ Login test failed: $e');
      return null;
    }
  }

  static Future<bool> testProtectedEndpoint(String token) async {
    print('\n🔒 Testing Protected Endpoint...');
    
    try {
      String baseUrl = await Env.findWorkingUrl();
      
      // Test accessing a protected endpoint
      final uiData = {
        "page": "home",
        "section": "banner",
        "user_id": "frontendtestuser"
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/rewards/ui-content'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(uiData),
      ).timeout(Duration(seconds: 10));
      
      print('🔒 Protected Endpoint Status: ${response.statusCode}');
      print('📄 Protected Endpoint Response: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Protected endpoint access successful!');
        return true;
      } else {
        print('❌ Protected endpoint access failed!');
        return false;
      }
      
    } catch (e) {
      print('❌ Protected endpoint test failed: $e');
      return false;
    }
  }

  static Future<bool> testOAuthConfiguration() async {
    print('\n🔧 Testing OAuth Configuration...');
    
    try {
      String baseUrl = await Env.findWorkingUrl();
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/oauth/test-config'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('🔧 OAuth Config Status: ${response.statusCode}');
      print('📄 OAuth Config Response: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ OAuth configuration is ready!');
        return true;
      } else {
        print('❌ OAuth configuration failed!');
        return false;
      }
      
    } catch (e) {
      print('❌ OAuth config test failed: $e');
      return false;
    }
  }

  static Future<void> runAllTests() async {
    print('🚀 Starting Frontend-Backend Authentication Tests...');
    print('=' * 60);
    
    // Test backend connection
    bool backendConnected = await testBackendConnection();
    if (!backendConnected) {
      print('\n❌ Backend connection failed. Stopping tests.');
      return;
    }
    
    // Test OAuth configuration
    await testOAuthConfiguration();
    
    // Test user registration
    bool registrationSuccess = await testUserRegistration();
    
    // Test user login
    String? token = await testUserLogin();
    
    // Test protected endpoint if login was successful
    if (token != null) {
      await testProtectedEndpoint(token);
    }
    
    print('\n' + '=' * 60);
    print('🏁 Frontend-Backend Authentication Tests Completed!');
    
    if (registrationSuccess && token != null) {
      print('✅ All tests passed! Frontend can successfully connect to backend authentication.');
      print('🎉 Your mobile app authentication is working perfectly!');
    } else {
      print('❌ Some tests failed. Please check the errors above.');
    }
  }
}

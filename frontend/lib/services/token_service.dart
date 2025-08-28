import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userPhoneKey = 'user_phone_number';
  static const String _userEmailKey = 'user_email';

  // Save authentication token
  static Future<void> saveToken(String token, String tokenType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenTypeKey, tokenType);
  }

  // Get authentication token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get token type
  static Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  // Get full authorization header
  static Future<String?> getAuthorizationHeader() async {
    final token = await getToken();
    final tokenType = await getTokenType();
    
    if (token != null && tokenType != null) {
      return '$tokenType $token';
    }
    return null;
  }

  // Save user phone number
  static Future<void> saveUserPhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPhoneKey, phoneNumber);
  }

  // Get user phone number
  static Future<String?> getUserPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  // Save user email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Clear authentication token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userEmailKey);
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
} 
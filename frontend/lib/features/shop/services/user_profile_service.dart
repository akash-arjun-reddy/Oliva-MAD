import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyPhone = 'user_phone';
  static const String _keyAddress = 'user_address';

  // Get user name
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? 'John Doe';
  }

  // Set user name
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }

  // Get user email
  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? 'test@gmail.com';
  }

  // Set user email
  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  // Get user phone
  static Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone) ?? '9876543210';
  }

  // Set user phone
  static Future<void> setUserPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhone, phone);
  }

  // Get user address
  static Future<String> getUserAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAddress) ?? '123 Main Street, Mumbai, Maharashtra 400001';
  }

  // Set user address
  static Future<void> setUserAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAddress, address);
  }

  // Get complete user profile
  static Future<Map<String, String>> getUserProfile() async {
    return {
      'name': await getUserName(),
      'email': await getUserEmail(),
      'phone': await getUserPhone(),
      'address': await getUserAddress(),
    };
  }

  // Set complete user profile
  static Future<void> setUserProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    await setUserName(name);
    await setUserEmail(email);
    await setUserPhone(phone);
    await setUserAddress(address);
  }
} 
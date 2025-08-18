import 'package:flutter/material.dart';
import '../../data/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService apiService;
  Map<String, dynamic>? user;
  bool isLoading = false;
  String? error;
  bool isAuthenticated = false;

  AuthProvider({required this.apiService});

  Future<bool> sendOTP(String email) async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      await apiService.sendOTP(email);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      final response = await apiService.verifyOTP(email, otp);
      user = response;
      isAuthenticated = true;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setupUserProfile(Map<String, dynamic> profileData) async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      final response = await apiService.setupUserProfile(profileData);
      user = response;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      final response = await apiService.login(email, password);
      user = response;
      isAuthenticated = true;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    user = null;
    isAuthenticated = false;
    notifyListeners();
  }
} 
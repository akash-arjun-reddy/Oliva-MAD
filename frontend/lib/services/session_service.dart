import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'token_service.dart';

class SessionService {
  static Timer? _refreshTimer;
  static const int _refreshIntervalMinutes = 25; // Refresh every 25 minutes (before 30 min expiry)
  
  // Initialize session monitoring
  static Future<void> initializeSessionMonitoring() async {
    final isAuthenticated = await TokenService.isAuthenticated();
    if (isAuthenticated) {
      _startRefreshTimer();
    }
  }
  
  // Start automatic token refresh
  static void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(minutes: _refreshIntervalMinutes),
      (_) => _refreshSession(),
    );
  }
  
  // Stop session monitoring
  static void stopSessionMonitoring() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  // Refresh session activity
  static Future<void> _refreshSession() async {
    try {
      final baseUrl = await Env.findWorkingUrl();
      final authHeader = await TokenService.getAuthorizationHeader();
      
      if (authHeader == null) {
        stopSessionMonitoring();
        return;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/sessions/refresh'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        print('Session refreshed successfully');
      } else {
        print('Session refresh failed: ${response.statusCode}');
        await _handleSessionExpired();
      }
    } catch (e) {
      print('Session refresh error: $e');
      await _handleSessionExpired();
    }
  }
  
  // Handle session expiration
  static Future<void> _handleSessionExpired() async {
    print('Session expired, logging out user');
    await logout();
  }
  
  // Get session status
  static Future<Map<String, dynamic>?> getSessionStatus() async {
    try {
      final baseUrl = await Env.findWorkingUrl();
      final authHeader = await TokenService.getAuthorizationHeader();
      
      if (authHeader == null) {
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/status'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Get session status error: $e');
      return null;
    }
  }
  
  // Get user sessions
  static Future<Map<String, dynamic>?> getUserSessions() async {
    try {
      final baseUrl = await Env.findWorkingUrl();
      final authHeader = await TokenService.getAuthorizationHeader();
      
      if (authHeader == null) {
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/my-sessions'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Get user sessions error: $e');
      return null;
    }
  }
  
  // Get session logs
  static Future<Map<String, dynamic>?> getSessionLogs() async {
    try {
      final baseUrl = await Env.findWorkingUrl();
      final authHeader = await TokenService.getAuthorizationHeader();
      
      if (authHeader == null) {
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/my-session-logs'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Get session logs error: $e');
      return null;
    }
  }
  
  // Logout current session
  static Future<bool> logout() async {
    try {
      final baseUrl = await Env.findWorkingUrl();
      final authHeader = await TokenService.getAuthorizationHeader();
      
      if (authHeader == null) {
        await TokenService.clearToken();
        stopSessionMonitoring();
        return true;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/sessions/logout'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      await TokenService.clearToken();
      stopSessionMonitoring();
      
      return response.statusCode == 200;
    } catch (e) {
      print('Logout error: $e');
      await TokenService.clearToken();
      stopSessionMonitoring();
      return false;
    }
  }
  
  // Logout from all devices
  static Future<bool> logoutAllDevices() async {
    try {
      final baseUrl = await Env.findWorkingUrl();
      final authHeader = await TokenService.getAuthorizationHeader();
      
      if (authHeader == null) {
        await TokenService.clearToken();
        stopSessionMonitoring();
        return true;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/sessions/logout-all'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      await TokenService.clearToken();
      stopSessionMonitoring();
      
      return response.statusCode == 200;
    } catch (e) {
      print('Logout all devices error: $e');
      await TokenService.clearToken();
      stopSessionMonitoring();
      return false;
    }
  }
  
  // Check if user should stay logged in (optimized for speed)
  static Future<bool> shouldStayLoggedIn() async {
    final isAuthenticated = await TokenService.isAuthenticated();
    if (!isAuthenticated) {
      return false;
    }
    
    // For faster startup, just check if token exists
    // Full session validation can happen later
    return true;
  }
}

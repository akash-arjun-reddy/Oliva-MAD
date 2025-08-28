import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class AuthService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userData;
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  
  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Base URL for API calls
  final String _baseUrl = 'http://localhost:8000';

  // Getters
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  AuthService() {
    _initializeAuthState();
  }

  // Cookie helper methods
  void _setCookie(String name, String value) {
    html.document.cookie = '$name=$value; path=/; max-age=31536000'; // 1 year
  }

  String? _getCookie(String name) {
    try {
      final cookieString = html.document.cookie;
      if (cookieString == null || cookieString.isEmpty) return null;
      
      final cookies = cookieString.split(';');
      for (final cookie in cookies) {
        final parts = cookie.trim().split('=');
        if (parts.length == 2 && parts[0] == name) {
          return parts[1];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _removeCookie(String name) {
    html.document.cookie = '$name=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
  }

  // Initialize authentication state
  Future<void> _initializeAuthState() async {
    await _loadAuthState();
    _isInitialized = true;
    notifyListeners();
  }

  // Load authentication state from persistent storage
  Future<void> _loadAuthState() async {
    try {
      // Try cookies first (most reliable for web)
      String? storedToken = _getCookie(_tokenKey);
      String? storedUserData = _getCookie(_userDataKey);
      String? storedIsLoggedIn = _getCookie(_isLoggedInKey);
      
      print('🔍 LOAD: Cookie token = ${storedToken != null ? "EXISTS" : "NULL"}');
      print('🔍 LOAD: Cookie userData = ${storedUserData != null ? "EXISTS" : "NULL"}');
      print('🔍 LOAD: Cookie isLoggedIn = $storedIsLoggedIn');
      
      // If cookies are empty, try localStorage as backup
      if (storedToken == null) {
        storedToken = html.window.localStorage[_tokenKey];
        storedUserData = html.window.localStorage[_userDataKey];
        storedIsLoggedIn = html.window.localStorage[_isLoggedInKey];
        
        print('🔍 LOAD: localStorage token = ${storedToken != null ? "EXISTS" : "NULL"}');
        
        // If localStorage has data, migrate to cookies
        if (storedToken != null) {
          _setCookie(_tokenKey, storedToken);
          if (storedUserData != null) {
            _setCookie(_userDataKey, storedUserData);
          }
          if (storedIsLoggedIn != null) {
            _setCookie(_isLoggedInKey, storedIsLoggedIn);
          }
          print('🔍 LOAD: Migrated from localStorage to cookies');
        }
      }
      
      // Set the values
      _token = storedToken;
      _isLoggedIn = storedIsLoggedIn == 'true';
      
      if (storedUserData != null) {
        try {
          _userData = json.decode(storedUserData);
        } catch (e) {
          print('🔍 LOAD: Error decoding user data: $e');
        }
      }
      
      print('🔍 LOAD: Final state - Token: ${_token != null}, UserData: ${_userData != null}, IsLoggedIn: $_isLoggedIn');
    } catch (e) {
      print('🔍 LOAD: Error loading auth state: $e');
    }
  }

  // Save authentication state to persistent storage
  Future<void> _saveAuthState() async {
    try {
      print('🔍 SAVE: Saving auth state...');
      
      // Save to cookies (most reliable for web)
      if (_token != null) {
        _setCookie(_tokenKey, _token!);
        print('🔍 SAVE: Token saved to cookies');
      }
      
      if (_userData != null) {
        _setCookie(_userDataKey, json.encode(_userData));
        print('🔍 SAVE: User data saved to cookies');
      }
      
      _setCookie(_isLoggedInKey, _isLoggedIn.toString());
      print('🔍 SAVE: Login state saved to cookies: $_isLoggedIn');
      
      // Also save to localStorage as backup
      if (_token != null) {
        html.window.localStorage[_tokenKey] = _token!;
      }
      if (_userData != null) {
        html.window.localStorage[_userDataKey] = json.encode(_userData);
      }
      html.window.localStorage[_isLoggedInKey] = _isLoggedIn.toString();
      
      print('🔍 SAVE: Data saved to both cookies and localStorage');
    } catch (e) {
      print('🔍 SAVE: Error saving auth state: $e');
    }
  }

  // Google OAuth Login
  Future<Map<String, dynamic>> signInWithGoogle(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/oauth'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': accessToken,
          'token_type': 'access_token',
          'provider': 'google',
          'device_id': 'flutter_app',
          'device_name': 'Flutter App',
          'device_type': 'mobile',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract token and user data
        _token = data['tokens']['access_token'];
        _userData = {
          'email': data['user']['email'],
          'name': data['user']['name'],
          'picture': data['user']['picture'],
          'is_new_user': data['is_new_user'],
        };
        _isLoggedIn = true;

        // Save to persistent storage
        await _saveAuthState();
        notifyListeners();
        
        return {
          'success': true,
          'user': _userData,
          'is_new_user': data['is_new_user'],
        };
      } else {
        return {
          'success': false,
          'error': 'Login failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Force refresh authentication state
  Future<void> forceRefreshAuthState() async {
    print('🔍 FORCE REFRESH: Starting force refresh...');
    await _loadAuthState();
    notifyListeners();
    print('🔍 FORCE REFRESH: Auth state refreshed - isLoggedIn: $_isLoggedIn');
  }

  // Logout - clean and efficient
  Future<void> logout() async {
    try {
      print('🔍 LOGOUT: Starting logout process...');
      print('🔍 LOGOUT: Current state - Token: ${_token != null}, UserData: ${_userData != null}, IsLoggedIn: $_isLoggedIn');
      
      // Clear local state IMMEDIATELY first
      _token = null;
      _userData = null;
      _isLoggedIn = false;
      print('🔍 LOGOUT: Local state cleared IMMEDIATELY');
      
      // Notify listeners IMMEDIATELY
      notifyListeners();
      print('🔍 LOGOUT: IMMEDIATE notifyListeners() called');
      
      // Call logout endpoint if token existed
      if (_token != null) {
        try {
          await http.post(
            Uri.parse('$_baseUrl/auth/oauth/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_token',
            },
            body: json.encode({
              'token': _token,
              'token_type': 'access_token',
              'provider': 'google',
              'logout_all_devices': true,
            }),
          );
          print('🔍 LOGOUT: Backend logout called');
        } catch (e) {
          print('🔍 LOGOUT: Backend logout error (ignored): $e');
        }
      }

      // Clear cookies
      try {
        _removeCookie(_tokenKey);
        _removeCookie(_userDataKey);
        _removeCookie(_isLoggedInKey);
        print('🔍 LOGOUT: Cookies cleared');
      } catch (e) {
        print('🔍 LOGOUT: Cookie clear error: $e');
      }
      
      // Clear localStorage
      try {
        html.window.localStorage.clear();
        print('🔍 LOGOUT: localStorage cleared');
      } catch (e) {
        print('🔍 LOGOUT: localStorage clear error: $e');
      }

      // Force notify listeners again with shorter delays
      await Future.delayed(const Duration(milliseconds: 50));
      notifyListeners();
      print('🔍 LOGOUT: Second notifyListeners() called');
      
      await Future.delayed(const Duration(milliseconds: 50));
      notifyListeners();
      print('🔍 LOGOUT: Third notifyListeners() called');
      
      print('🔍 LOGOUT: Logout completed - isLoggedIn: $_isLoggedIn');
    } catch (e) {
      print('🔍 LOGOUT: Error during logout: $e');
      // Even if there's an error, ensure logout state
      _token = null;
      _userData = null;
      _isLoggedIn = false;
      notifyListeners();
      print('🔍 LOGOUT: Forced logout state after error');
    }
  }

  // Test method to check localStorage
  Future<void> testLocalStorage() async {
    try {
      // Test writing to localStorage
      html.window.localStorage['test_key'] = 'test_value';
      
      // Test reading from localStorage
      final testValue = html.window.localStorage['test_key'];
      
      print('🔍 TEST: localStorage test_key = $testValue');
      print('🔍 TEST: localStorage auth_token = ${html.window.localStorage[_tokenKey]}');
      print('🔍 TEST: localStorage user_data = ${html.window.localStorage[_userDataKey]}');
      print('🔍 TEST: localStorage is_logged_in = ${html.window.localStorage[_isLoggedInKey]}');
      
      // Clear test data
      html.window.localStorage.remove('test_key');
    } catch (e) {
      print('🔍 TEST: localStorage error: $e');
    }
  }

  // Check if user is logged in
  Future<bool> checkAuthStatus() async {
    await _loadAuthState();
    await testLocalStorage(); // Test localStorage
    return _isLoggedIn && _token != null;
  }

  // Get authorization header for API requests
  String? getAuthorizationHeader() {
    return _token != null ? 'Bearer $_token' : null;
  }



  // Refresh user data
  Future<void> refreshUserData() async {
    if (_token != null) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/auth/me'),
          headers: {
            'Authorization': 'Bearer $_token',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _userData = data;
          await _saveAuthState();
          notifyListeners();
        }
      } catch (e) {
        // Ignore refresh errors
      }
    }
  }
}

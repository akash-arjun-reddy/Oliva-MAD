import 'dart:io';
import 'dart:async';

class Env {
  static String? _cachedBaseUrl;
  static DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Production backend URL (Render deployment)
  static const String _productionBackendUrl = 'https://oliva-clinic-backend.onrender.com';
  
  // Development backend URL (local)
  static const String _developmentBackendUrl = 'http://localhost:8000';

  // Automatically detect the computer's IP address for local development
  static Future<String> get baseUrl async {
    // Check if we have a cached URL that's still valid
    if (_cachedBaseUrl != null && _lastCacheTime != null) {
      if (DateTime.now().difference(_lastCacheTime!) < _cacheDuration) {
        return _cachedBaseUrl!;
      }
    }

    // For production builds, use the Render URL
    if (const bool.fromEnvironment('dart.vm.product')) {
      _cachedBaseUrl = _productionBackendUrl;
      _lastCacheTime = DateTime.now();
      return _cachedBaseUrl!;
    }

    // For development, try to detect local IP
    String detectedIp = await _detectLocalIpAddress();
    
    // Cache the result
    _cachedBaseUrl = 'http://$detectedIp:8000';
    _lastCacheTime = DateTime.now();
    
    return _cachedBaseUrl!;
  }

  // Alternative URLs to try if the main one doesn't work
  static List<String> get alternativeUrls => [
    'http://10.0.2.2:8000', // Android emulator
    'http://localhost:8000',
    'http://127.0.0.1:8000',
    _productionBackendUrl, // Production URL as fallback
  ];

  // Detect local IP address automatically
  static Future<String> _detectLocalIpAddress() async {
    try {
      // Get all network interfaces
      List<NetworkInterface> interfaces = await NetworkInterface.list();
      
      // Common local network prefixes
      List<String> localPrefixes = [
        '192.168.',
        '10.0.',
        '172.16.',
        '172.17.',
        '172.18.',
        '172.19.',
        '172.20.',
        '172.21.',
        '172.22.',
        '172.23.',
        '172.24.',
        '172.25.',
        '172.26.',
        '172.27.',
        '172.28.',
        '172.29.',
        '172.30.',
        '172.31.',
      ];

      // Find the first valid local IP address
      for (NetworkInterface interface in interfaces) {
        for (InternetAddress address in interface.addresses) {
          // Skip loopback addresses
          if (address.isLoopback) continue;
          
          // Check if it's a local network address
          String ip = address.address;
          for (String prefix in localPrefixes) {
            if (ip.startsWith(prefix)) {
              print('Detected local IP: $ip');
              return ip;
            }
          }
        }
      }

      // Fallback to localhost if no local IP found
      print('No local IP detected, using localhost');
      return 'localhost';
    } catch (e) {
      print('Error detecting IP address: $e');
      return 'localhost';
    }
  }

  // Get all available URLs for testing connectivity
  static Future<List<String>> getAllUrls() async {
    String mainUrl = await baseUrl;
    List<String> urls = [mainUrl];
    urls.addAll(alternativeUrls);
    return urls;
  }

  // Test connectivity to find working URL
  static Future<String> findWorkingUrl() async {
    List<String> urls = await getAllUrls();
    
    for (String url in urls) {
      try {
        HttpClient client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 3);
        
        HttpClientRequest request = await client.getUrl(Uri.parse('$url/test'));
        HttpClientResponse response = await request.close();
        
        if (response.statusCode == 200) {
          client.close();
          print('Working URL found: $url');
          return url;
        }
        
        client.close();
      } catch (e) {
        print('URL $url not accessible: $e');
        continue;
      }
    }
    
    // Return the first URL as fallback
    return urls.first;
  }

  // Get the production URL directly
  static String get productionUrl => _productionBackendUrl;
  
  // Get the development URL directly
  static String get developmentUrl => _developmentBackendUrl;
} 
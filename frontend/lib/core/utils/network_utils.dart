import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../config/env.dart';

class NetworkUtils {
  // Test connectivity to all available URLs and return the working one
  static Future<String> findWorkingServer() async {
    print('🔍 Searching for working server...');
    
    try {
      String workingUrl = await Env.findWorkingUrl();
      print('✅ Found working server: $workingUrl');
      return workingUrl;
    } catch (e) {
      print('❌ Error finding working server: $e');
      // Fallback to localhost
      return 'http://localhost:8000';
    }
  }

  // Get current IP address
  static Future<String> getCurrentIpAddress() async {
    try {
      String ip = await Env._detectLocalIpAddress();
      print('📍 Current IP address: $ip');
      return ip;
    } catch (e) {
      print('❌ Error getting IP address: $e');
      return 'localhost';
    }
  }

  // Test if a specific URL is accessible
  static Future<bool> testUrlConnectivity(String url) async {
    try {
      HttpClient client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      
      HttpClientRequest request = await client.getUrl(Uri.parse('$url/health'));
      HttpClientResponse response = await request.close();
      
      client.close();
      
      bool isAccessible = response.statusCode == 200;
      print('${isAccessible ? '✅' : '❌'} $url is ${isAccessible ? 'accessible' : 'not accessible'}');
      return isAccessible;
    } catch (e) {
      print('❌ $url is not accessible: $e');
      return false;
    }
  }

  // Get all available URLs for testing
  static Future<List<String>> getAllTestUrls() async {
    List<String> urls = await Env.getAllUrls();
    print('📋 Available URLs for testing:');
    for (String url in urls) {
      print('  - $url');
    }
    return urls;
  }

  // Comprehensive network test
  static Future<Map<String, dynamic>> runNetworkTest() async {
    print('🚀 Starting comprehensive network test...');
    
    Map<String, dynamic> results = {
      'currentIp': await getCurrentIpAddress(),
      'workingUrl': await findWorkingServer(),
      'allUrls': await getAllTestUrls(),
      'connectivityTests': {},
    };

    // Test connectivity to all URLs
    List<String> urls = await getAllTestUrls();
    for (String url in urls) {
      bool isAccessible = await testUrlConnectivity(url);
      results['connectivityTests'][url] = isAccessible;
    }

    print('📊 Network test completed!');
    return results;
  }
} 
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardApiService {
  final String baseUrl;

  DashboardApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchDashboardData() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecentAppointments() async {
    final response = await http.get(Uri.parse('$baseUrl/appointments/recent'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load recent appointments');
    }
  }
} 
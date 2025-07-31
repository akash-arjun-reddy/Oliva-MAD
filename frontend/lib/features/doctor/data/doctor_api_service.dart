import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorApiService {
  final String baseUrl;

  DoctorApiService({required this.baseUrl});

  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final response = await http.get(Uri.parse('baseUrl/doctors'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load doctors');
    }
  }
} 
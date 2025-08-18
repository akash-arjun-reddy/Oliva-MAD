import 'package:http/http.dart' as http;
import 'dart:convert';

class ClinicApiService {
  final String baseUrl;

  ClinicApiService({required this.baseUrl});

  Future<List<Map<String, dynamic>>> fetchClinics() async {
    final response = await http.get(Uri.parse('$baseUrl/clinics'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load clinics');
    }
  }

  Future<Map<String, dynamic>> bookAppointment(Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bookingData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to book appointment');
    }
  }
} 
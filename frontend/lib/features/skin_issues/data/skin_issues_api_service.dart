import 'package:http/http.dart' as http;
import 'dart:convert';

class SkinIssuesApiService {
  final String baseUrl;

  SkinIssuesApiService({required this.baseUrl});

  Future<List<Map<String, dynamic>>> fetchSkinIssues() async {
    final response = await http.get(Uri.parse('$baseUrl/skin-issues'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load skin issues');
    }
  }

  Future<Map<String, dynamic>> submitSkinConcern(Map<String, dynamic> concernData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/skin-concerns'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(concernData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit skin concern');
    }
  }
} 
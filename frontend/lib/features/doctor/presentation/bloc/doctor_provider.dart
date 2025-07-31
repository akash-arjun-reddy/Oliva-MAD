import 'package:flutter/material.dart';
import '../../data/doctor_api_service.dart';

class DoctorProvider extends ChangeNotifier {
  final DoctorApiService apiService;
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = false;
  String? error;

  DoctorProvider({required this.apiService});

  Future<void> fetchDoctors() async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      doctors = await apiService.fetchDoctors();
    } catch (e) {
      error = e.toString();
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshDoctors() async {
    await fetchDoctors();
  }
} 
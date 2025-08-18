import 'package:flutter/material.dart';
import '../../data/clinic_api_service.dart';

class ClinicProvider extends ChangeNotifier {
  final ClinicApiService apiService;
  List<Map<String, dynamic>> clinics = [];
  bool isLoading = false;
  String? error;
  bool isBooking = false;

  ClinicProvider({required this.apiService});

  Future<void> fetchClinics() async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      clinics = await apiService.fetchClinics();
    } catch (e) {
      error = e.toString();
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshClinics() async {
    await fetchClinics();
  }

  Future<bool> bookAppointment(Map<String, dynamic> bookingData) async {
    isBooking = true;
    error = null;
    notifyListeners();
    
    try {
      await apiService.bookAppointment(bookingData);
      isBooking = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isBooking = false;
      notifyListeners();
      return false;
    }
  }
} 
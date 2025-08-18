import 'package:flutter/material.dart';
import '../../data/dashboard_api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardApiService apiService;
  Map<String, dynamic> dashboardData = {};
  List<Map<String, dynamic>> recentAppointments = [];
  bool isLoading = false;
  String? error;

  DashboardProvider({required this.apiService});

  Future<void> fetchDashboardData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      dashboardData = await apiService.fetchDashboardData();
    } catch (e) {
      error = e.toString();
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecentAppointments() async {
    try {
      recentAppointments = await apiService.fetchRecentAppointments();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    await Future.wait([
      fetchDashboardData(),
      fetchRecentAppointments(),
    ]);
  }
} 
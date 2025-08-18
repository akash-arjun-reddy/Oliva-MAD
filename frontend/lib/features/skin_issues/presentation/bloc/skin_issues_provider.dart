import 'package:flutter/material.dart';
import '../../data/skin_issues_api_service.dart';

class SkinIssuesProvider extends ChangeNotifier {
  final SkinIssuesApiService apiService;
  List<Map<String, dynamic>> skinIssues = [];
  bool isLoading = false;
  String? error;
  bool isSubmitting = false;

  SkinIssuesProvider({required this.apiService});

  Future<void> fetchSkinIssues() async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      skinIssues = await apiService.fetchSkinIssues();
    } catch (e) {
      error = e.toString();
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshSkinIssues() async {
    await fetchSkinIssues();
  }

  Future<bool> submitSkinConcern(Map<String, dynamic> concernData) async {
    isSubmitting = true;
    error = null;
    notifyListeners();
    
    try {
      await apiService.submitSkinConcern(concernData);
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
} 
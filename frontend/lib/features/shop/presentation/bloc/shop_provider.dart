import 'package:flutter/material.dart';
import '../../data/shop_api_service.dart';

class ShopProvider extends ChangeNotifier {
  final ShopApiService apiService;
  List<Map<String, dynamic>> products = [];
  bool isLoading = false;
  String? error;

  ShopProvider({required this.apiService});

  Future<void> fetchProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      products = await apiService.fetchProducts();
    } catch (e) {
      error = e.toString();
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    await fetchProducts();
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    try {
      return await apiService.fetchProductDetails(productId);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }
} 
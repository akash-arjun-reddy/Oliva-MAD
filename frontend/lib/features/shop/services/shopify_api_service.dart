import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../../config/env.dart';

class ShopifyApiService {
  // Remove hardcoded URL and use dynamic URL detection
  
  // Test Shopify connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final baseUrl = await Env.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/shopify/test-connection'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to test connection: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error testing connection: $e');
    }
  }
  
  // Get Shopify products
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final baseUrl = await Env.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/shopify/products'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['products'] ?? []);
      } else {
        throw Exception('Failed to get products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting products: $e');
    }
  }
  
  // Create Shopify order
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> lineItems,
    required Map<String, dynamic> customer,
    required Map<String, dynamic> shippingAddress,
  }) async {
    try {
      final baseUrl = await Env.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/shopify/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'line_items': lineItems,
          'customer': customer,
          'shipping_address': shippingAddress,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
  
  // Handle payment success and create order
  static Future<Map<String, dynamic>> handlePaymentSuccess({
    required String paymentId,
    required Map<String, dynamic> paymentData,
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      final baseUrl = await Env.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/shopify/payment-success'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'payment_id': paymentId,
          'payment_data': paymentData,
          'products': products,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to handle payment success: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error handling payment success: $e');
    }
  }
  
  // Fulfill order
  static Future<Map<String, dynamic>> fulfillOrder(int orderId) async {
    try {
      final baseUrl = await Env.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/shopify/fulfill-order/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fulfill order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fulfilling order: $e');
    }
  }
  
  // Get order details
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final baseUrl = await Env.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/shopify/order/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get order details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting order details: $e');
    }
  }
  
  // Get all orders
  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final baseUrl = await Env.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/shopify/orders'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['orders'] ?? []);
      } else {
        throw Exception('Failed to get orders: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting orders: $e');
    }
  }
  
  // Create order directly (for COD orders)
  static Future<Map<String, dynamic>> createOrderDirectly({
    required Map<String, dynamic> paymentData,
    required List<Map<String, dynamic>> products,
    required String paymentMethod,
  }) async {
    try {
      final baseUrl = await Env.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/shopify/create-order-directly'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'payment_data': paymentData,
          'products': products,
          'payment_method': paymentMethod,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create order directly: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating order directly: $e');
    }
  }
} 
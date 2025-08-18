import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PaymentService {
  static const String _baseUrl = 'https://payments.olivaclinic.com/api';
  static String? _authToken;

  // Generate authentication token
  static Future<String?> generateToken({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/token'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authToken = data['access_token']; // Adjust based on actual response structure
        return _authToken;
      } else {
        throw Exception('Failed to generate token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating token: $e');
    }
  }

  // Create payment
  static Future<Map<String, dynamic>> createPayment({
    required String customerName,
    required String phoneNumber,
    required String email,
    required double amount,
    required String center,
    required String centerId,
    required Map<String, dynamic> personalInfo,
    required Map<String, dynamic> addressInfo,
    required Map<String, dynamic> preferences,
  }) async {
    if (_authToken == null) {
      throw Exception('Authentication token not available. Please generate token first.');
    }

    try {
      final paymentData = {
        "customer_name": customerName,
        "phone_number": phoneNumber.replaceAll(RegExp(r'[^\d]'), '').length > 10 ? phoneNumber.replaceAll(RegExp(r'[^\d]'), '').substring(phoneNumber.replaceAll(RegExp(r'[^\d]'), '').length - 10) : phoneNumber.replaceAll(RegExp(r'[^\d]'), ''),
        "email": email,
        "amount": amount,
        "center": center,
        "center_id": centerId,
        "personal_info_user_name": personalInfo['user_name'],
        "personal_info_first_name": personalInfo['first_name'],
        "personal_info_last_name": personalInfo['last_name'],
        "personal_info_middle_name": personalInfo['middle_name'],
        "personal_info_email": personalInfo['email'],
        "personal_info_mobile_country_code": personalInfo['mobile_country_code'],
        "personal_info_mobile_number": personalInfo['mobile_number'],
        "personal_info_work_country_code": personalInfo['work_country_code'],
        "personal_info_work_number": personalInfo['work_number'],
        "personal_info_home_country_code": personalInfo['home_country_code'],
        "personal_info_home_number": personalInfo['home_number'],
        "personal_info_gender": personalInfo['gender'],
        "personal_info_date_of_birth": personalInfo['date_of_birth'],
        "personal_info_is_minor": personalInfo['is_minor'],
        "personal_info_nationality_id": personalInfo['nationality_id'],
        "personal_info_anniversary_date": personalInfo['anniversary_date'],
        "personal_info_lock_guest_custom_data": personalInfo['lock_guest_custom_data'],
        "personal_info_pan": personalInfo['pan'],
        "address_info_address_1": addressInfo['address_1'],
        "address_info_address_2": addressInfo['address_2'],
        "address_info_city": addressInfo['city'],
        "address_info_country_id": addressInfo['country_id'],
        "address_info_state_id": addressInfo['state_id'],
        "address_info_state_other": addressInfo['state_other'],
        "address_info_zip_code": addressInfo['zip_code'],
        "preferences_receive_transactional_email": preferences['receive_transactional_email'],
        "preferences_receive_transactional_sms": preferences['receive_transactional_sms'],
        "preferences_receive_marketing_email": preferences['receive_marketing_email'],
        "preferences_receive_marketing_sms": preferences['receive_marketing_sms'],
        "preferences_recieve_lp_stmt": preferences['recieve_lp_stmt'],
        "preferences_preferred_therapist_id": preferences['preferred_therapist_id'],
        "login_info_password": null,
        "tags": null,
        "referral_referral_source_id": null,
        "referral_referred_by_id": null,
        "primary_employee_id": null,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/payment'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain, */*',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Payment API Response: $responseData'); // Debug log
        return responseData;
      } else {
        print('Payment API Error: ${response.statusCode} - ${response.body}'); // Debug log
        throw Exception('Payment creation failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  // Initialize payment service with token
  static Future<void> initialize() async {
    try {
      await generateToken(
        username: 'test@exampl.com',
        password: '123',
      );
    } catch (e) {
      throw Exception('Failed to initialize payment service: $e');
    }
  }

  // Get payment URL for specific payment method
  static Future<String?> getPaymentUrl({
    required String paymentMethod,
    required Map<String, dynamic> paymentData,
  }) async {
    try {
      final response = await createPayment(
        customerName: paymentData['customer_name'],
        phoneNumber: paymentData['phone_number'],
        email: paymentData['email'],
        amount: paymentData['amount'],
        center: paymentData['center'],
        centerId: paymentData['center_id'],
        personalInfo: paymentData['personal_info'],
        addressInfo: paymentData['address_info'],
        preferences: paymentData['preferences'],
      );

      // Extract payment URL from response
      print('Looking for payment URL in response: $response'); // Debug log
      
      // Try different possible field names for payment URL
      final paymentUrl = response['payment_url'] ?? 
                        response['redirect_url'] ?? 
                        response['url'] ?? 
                        response['payment_link'] ?? 
                        response['checkout_url'];
      
      print('Found payment URL: $paymentUrl'); // Debug log
      return paymentUrl;
    } catch (e) {
      throw Exception('Error getting payment URL: $e');
    }
  }
}

// Payment data model
class PaymentData {
  final String customerName;
  final String phoneNumber;
  final String email;
  final double amount;
  final String center;
  final String centerId;
  final Map<String, dynamic> personalInfo;
  final Map<String, dynamic> addressInfo;
  final Map<String, dynamic> preferences;

  PaymentData({
    required this.customerName,
    required this.phoneNumber,
    required this.email,
    required this.amount,
    required this.center,
    required this.centerId,
    required this.personalInfo,
    required this.addressInfo,
    required this.preferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'email': email,
      'amount': amount,
      'center': center,
      'center_id': centerId,
      'personal_info': personalInfo,
      'address_info': addressInfo,
      'preferences': preferences,
    };
  }
} 
import 'dart:io';
import 'dart:async';

class Env {
  // API Configuration
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
  
  // Shopify Configuration
  static const String shopifyAccessToken = String.fromEnvironment('SHOPIFY_ACCESS_TOKEN', defaultValue: '');
  static const String shopifyBaseUrl = String.fromEnvironment('SHOPIFY_BASE_URL', defaultValue: 'https://oliva-clinic.myshopify.com');
  
  // Payment Configuration
  static const String paymentApiKey = String.fromEnvironment('PAYMENT_API_KEY', defaultValue: '');
  static const String paymentSecretKey = String.fromEnvironment('PAYMENT_SECRET_KEY', defaultValue: '');
  
  // Email Configuration
  static const String sendGridApiKey = String.fromEnvironment('SENDGRID_API_KEY', defaultValue: '');
  
  // SMS Configuration
  static const String twilioAuthToken = String.fromEnvironment('TWILIO_AUTH_TOKEN', defaultValue: '');
  
  // Video Call Configuration
  static const String jitsiPassword = String.fromEnvironment('JITSI_PASSWORD', defaultValue: '');
  
  // App Configuration
  static const String appName = 'Oliva Clinic';
  static const String appVersion = '1.0.0';
  
  // Feature Flags
  static const bool enableVideoCalls = bool.fromEnvironment('ENABLE_VIDEO_CALLS', defaultValue: true);
  static const bool enablePayments = bool.fromEnvironment('ENABLE_PAYMENTS', defaultValue: true);
  static const bool enableShopify = bool.fromEnvironment('ENABLE_SHOPIFY', defaultValue: true);
} 
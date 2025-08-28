import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'unveil_registration_page.dart';
import 'otp_verification_page.dart';
import 'email_otp_page.dart';
import 'setup_profile_page.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/auth_wrapper.dart';
import '../widgets/login_header_widget.dart';
import '../widgets/primary_button_widget.dart';
import '../../../../services/api_service.dart';
import '../../../dashboard/presentation/pages/newdashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    clientId: '601952184258-2e48qr0anivb3nm8dvil7jhiarg10j2d.apps.googleusercontent.com',
    signInOption: SignInOption.standard,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleGetOtp() async {
    if (_formKey.currentState!.validate()) {
      try {
        _showLoadingDialog();
        
        String phoneNumber = _phoneController.text.trim();
        
        // Simulate API call delay
        await Future.delayed(const Duration(seconds: 1));
        
        _hideLoadingDialog();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(phoneNumber: phoneNumber),
          ),
        );
      } catch (e) {
        _hideLoadingDialog();
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.pop(context);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmailOtpPage(email: 'user@example.com')),
    );
  }

  void _handleNotRegistered() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UnveilRegistrationPage()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      _showLoadingDialog();
      
      // Clear any existing sign-in session first
      await _googleSignIn.signOut();
      print('🔍 Cleared existing Google Sign-In session');
      
      // Sign in with Google with timeout
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('🔍 Google Sign-In timeout');
          throw Exception('Google Sign-In timed out. Please try again.');
        },
      );
      
      if (googleUser == null) {
        _hideLoadingDialog();
        if (mounted) {
          _showErrorSnackBar('Google sign-in was cancelled');
        }
        print('🔍 User cancelled Google Sign-In');
        return;
      }

      

      // Get authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Use access token if available, otherwise use ID token
      String? accessToken;
      
      if (googleAuth.accessToken != null) {
        accessToken = googleAuth.accessToken;

      } else if (googleAuth.idToken != null) {
        accessToken = googleAuth.idToken;

      } else {
        _hideLoadingDialog();
        if (mounted) {
          _showErrorSnackBar('No authentication tokens received from Google');
        }
        return;
      }
      
      // Get the AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Call the backend with the access token
      final loginResult = await authService.signInWithGoogle(accessToken!);
      
      _hideLoadingDialog();
      
      if (loginResult['success']) {
        // Successfully logged in - Navigate to NewDashboard

        
        // Show success message
        if (mounted) {
          final userName = loginResult['user']['name'] ?? 'User';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, $userName!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Navigate to AuthWrapper after successful login
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthWrapper(),
              ),
              (route) => false,
            );
          }
        }
      } else {
        // Login failed - user might not exist

        if (mounted) {
          _showErrorSnackBar('Account not found. Please sign up first.');
        }
      }
    } catch (e) {
      _hideLoadingDialog();

      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handleForgotPassword,
              icon: const Icon(Icons.lock_outline, color: Color(0xFF00BFAE), size: 20),
              label: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: Color(0xFF00BFAE),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00BFAE), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                backgroundColor: Colors.white.withOpacity(0.9),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handleNotRegistered,
              icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF00BFAE), size: 20),
              label: const Text(
                'Not registered?',
                style: TextStyle(
                  color: Color(0xFF00BFAE),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00BFAE), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                backgroundColor: Colors.white.withOpacity(0.9),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IntlPhoneField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: 'Mobile Number',
            hintStyle: const TextStyle(fontSize: 16, color: Colors.black45),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00BFAE), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          initialCountryCode: 'IN',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 16, color: Colors.black),
          dropdownTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          onChanged: (phone) {},
          validator: (value) {
            if (value == null || value.number.isEmpty) {
              return 'Enter phone number';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: Image.asset('assets/images/google_logo.png', height: 24),
        label: const Text(
          'Login with Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A4D4A),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF00BFAE), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Text.rich(
        TextSpan(
          text: 'By continuing, you agree to our ',
          style: const TextStyle(color: Colors.black54, fontSize: 13),
          children: [
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00BFAE)),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Terms of Service',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00BFAE)),
            ),
            const TextSpan(
              text: '. We value your privacy and never share your information.',
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE1F5FE), // Light blue
              Color(0xFFB3E5FC), // Lighter blue
              Color(0xFFE8F5E8), // Light green
              Color(0xFFF0F8FF), // Alice blue
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Image section without horizontal padding
                  const LoginHeaderWidget(
                    title: 'Log in or Sign Up',
                    subtitle: 'Enter your mobile number to receive a one-time password',
                    imageAsset: 'assets/images/treatment.png',
                  ),
                  // Form section with horizontal padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        _buildPhoneInput(),
                        const SizedBox(height: 24),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00BFAE).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: PrimaryButtonWidget(
                            text: 'Get OTP',
                            onPressed: _handleGetOtp,
                            height: 56,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                        const SizedBox(height: 16),
                        _buildGoogleSignInButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPrivacyPolicy(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
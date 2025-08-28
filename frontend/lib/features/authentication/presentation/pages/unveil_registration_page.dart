import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'email_otp_page.dart';
import 'login_page.dart';
import 'setup_profile_page.dart';
import '../../../dashboard/presentation/pages/main_dashboard.dart';
import '../../../dashboard/presentation/pages/newdashboard.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../data/auth_api_service.dart';
import '../../../../../../config/env.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/auth_wrapper.dart';

const Color kTeal = Color(0xFF00BFAE);
const Color kTextDark = Color(0xFF1A4D4A);

class UnveilRegistrationPage extends StatefulWidget {
  const UnveilRegistrationPage({super.key});

  @override
  State<UnveilRegistrationPage> createState() => _UnveilRegistrationPageState();
}

class _UnveilRegistrationPageState extends State<UnveilRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final AuthApiService _authService = AuthApiService(); // Use dynamic IP detection
  bool _isLoading = false;
  String _selectedCountryCode = '+91';
  String _fullPhoneNumber = '';
  
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

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 Starting Google Sign-Up...');
      
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
        setState(() {
          _isLoading = false;
        });
        print('🔍 User cancelled Google Sign-In');
        return; // User cancelled
      }

      print('🔍 Google user selected: ${googleUser.email}');

      // Get authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Use access token if available, otherwise use ID token
      String? accessToken;
      
      if (googleAuth.accessToken != null) {
        accessToken = googleAuth.accessToken;
        print('🔍 Using access token, length: ${accessToken!.length}');
      } else if (googleAuth.idToken != null) {
        accessToken = googleAuth.idToken;
        print('🔍 Using ID token, length: ${accessToken!.length}');
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No authentication tokens received from Google')),
          );
        }
        return;
      }
      
      // Get the AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Call the backend with the access token
      final signUpResult = await authService.signInWithGoogle(accessToken!);
      
      setState(() {
        _isLoading = false;
      });
      
      if (signUpResult['success']) {
        // Successfully signed up - Navigate to NewDashboard

        
        // Show success message
        if (mounted) {
          final isNewUser = signUpResult['is_new_user'] == true;
          final userName = signUpResult['user']['name'] ?? 'User';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isNewUser 
                  ? 'Welcome to Oliva Clinic, $userName! Your account has been created successfully.'
                  : 'Welcome back, $userName! You have been logged in successfully.'
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Navigate to AuthWrapper after successful sign-up
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
        // Sign-up failed - check if user already exists

        if (mounted) {
          final errorMessage = signUpResult['error'] ?? 'Sign-up failed';
          
          // If user already exists, redirect to login
          if (errorMessage.contains('already exists') || errorMessage.contains('Account not found')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account already exists. Please login instead.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
            
            // Navigate to login page
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign-up failed: $errorMessage')),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top image fills half the screen
            SizedBox(
              height: screenHeight * 0.5,
              child: ClipPath(
                clipper: _BottomCurveClipper(),
                child: Image.asset(
                  'assets/images/doctors_placeholder.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Bottom content fills the rest
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Unveil Your Inner Glow',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kTeal,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        child: IntlPhoneField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: 'Phone number',
                            hintStyle: const TextStyle(fontSize: 16, color: Colors.black45),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: kTeal, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: kTeal, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: kTeal, width: 2),
                            ),
                          ),
                          initialCountryCode: 'IN',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                          dropdownTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          onChanged: (phone) {
                            _selectedCountryCode = phone.countryCode;
                            _fullPhoneNumber = phone.completeNumber;
                          },
                          validator: (value) {
                            if (value == null || value.number.isEmpty) {
                              return 'Enter phone number';
                            }
                            if (value.number.length < 10) {
                              return 'Enter valid phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  final phoneNumber = _fullPhoneNumber.replaceAll('+', '');
                                  await _authService.sendPhoneOTP(phoneNumber);
                                  
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EmailOtpPage(
                                          email: phoneNumber,
                                          isPhoneRegistration: true,
                                          phoneNumber: phoneNumber,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Get OTP',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      // OR divider
                      Row(
                        children: const [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      // Google sign up button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleGoogleSignUp,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: kTeal, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(kTeal),
                                    ),
                                  )
                                else
                                  Image.asset(
                                    'assets/images/google_logo.png',
                                    height: 28.0,
                                  ),
                                const SizedBox(width: 16),
                                Text(
                                  _isLoading ? 'Signing up...' : 'Sign up with Google',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: kTextDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          text: "By continuing, you agree to Oliva's ",
                          style: const TextStyle(color: kTextDark, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const TextSpan(
                              text: ' and ',
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for curved bottom image
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height + 40, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
} 
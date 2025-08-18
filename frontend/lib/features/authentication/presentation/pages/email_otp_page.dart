import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import 'login_page.dart';
import '../../data/auth_api_service.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../config/env.dart';

const Color kTealGreen = Color(0xFF00796B);

class EmailOtpPage extends StatefulWidget {
  final String email;
  final bool isPhoneRegistration;
  final String? phoneNumber;
  
  const EmailOtpPage({
    Key? key, 
    required this.email, 
    this.isPhoneRegistration = false,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<EmailOtpPage> createState() => _EmailOtpPageState();
}

class _EmailOtpPageState extends State<EmailOtpPage> with CodeAutoFill {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthApiService _authService = AuthApiService(); // Use dynamic IP detection
  bool _isLoading = false;
  String _otpCode = '';
  String? _appSignature;
  bool _isAutoFillEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSmsAutoFill();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _focusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  Future<void> _initSmsAutoFill() async {
    try {
      // Request SMS permission
      final status = await Permission.sms.request();
      if (status.isGranted) {
        _appSignature = await SmsAutoFill().getAppSignature;
        await SmsAutoFill().listenForCode();
        setState(() {
          _isAutoFillEnabled = true;
        });
      }
    } catch (e) {
      print('SMS AutoFill initialization failed: $e');
    }
  }

  @override
  void codeUpdated() {
    setState(() {
      _otpCode = code!;
      // Auto-fill the OTP boxes
      for (int i = 0; i < _otpCode.length && i < _controllers.length; i++) {
        _controllers[i].text = _otpCode[i];
      }
    });
  }

  void _onOtpChanged(int idx, String value) {
    if (value.length == 1 && idx < 5) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && idx > 0) {
      FocusScope.of(context).previousFocus();
    }
    
    // Update OTP code
    _otpCode = _controllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.isPhoneRegistration 
                        ? 'Almost Done – Just Set Your Password'
                        : 'Almost Done – Just Set Your Password',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: widget.isPhoneRegistration 
                              ? 'We sent an OTP to '
                              : 'We sent an OTP to ',
                        ),
                        TextSpan(
                          text: widget.isPhoneRegistration 
                              ? widget.phoneNumber ?? widget.email
                              : widget.email,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const TextSpan(text: '\nEnter it below to continue.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Auto-fill status
                if (_isAutoFillEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'SMS Auto-fill enabled',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (idx) {
                      return Container(
                        width: 40,
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: _controllers[idx],
                          focusNode: idx == 0 ? _focusNode : null,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: kTealGreen, width: 2),
                            ),
                          ),
                          onChanged: (value) => _onOtpChanged(idx, value),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                // Manual entry hint
                if (!_isAutoFillEnabled)
                  Text(
                    'Enter OTP manually if auto-fill is not working',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                // New Password field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kTealGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password must contain at least 12 characters',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm Password field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirm password',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Re-enter new password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDFE3E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kTealGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Passwords must be identical',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      if (_otpCode.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter complete OTP'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      if (_passwordController.text.length < 12) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password must be at least 12 characters'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      if (_passwordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      setState(() {
                        _isLoading = true;
                      });
                      
                      try {
                        if (widget.isPhoneRegistration) {
                          // Phone registration flow
                          await _authService.signupWithPhone(
                            phoneNumber: widget.phoneNumber ?? widget.email,
                            password: _passwordController.text,
                            otpCode: _otpCode,
                          );
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registration successful!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          }
                        } else {
                          // Email registration flow (existing)
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTealGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                            'SUBMIT',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_back, size: 18, color: Colors.black45),
                      SizedBox(width: 6),
                      Text(
                        'Back to Login Page',
                        style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
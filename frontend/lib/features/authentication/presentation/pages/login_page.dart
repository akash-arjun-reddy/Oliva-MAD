import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'unveil_registration_page.dart';
import 'otp_verification_page.dart';
import 'email_otp_page.dart';
import '../widgets/login_header_widget.dart';
import '../widgets/primary_button_widget.dart';
import '../../../../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

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

  Widget _buildActionButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _handleForgotPassword,
          icon: const Icon(Icons.lock_outline, color: Color(0xFF00BFAE), size: 18),
          label: const Text(
            'Forgot password?',
            style: TextStyle(
              color: Color(0xFF00BFAE),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF00BFAE)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _handleNotRegistered,
          icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF00BFAE), size: 18),
          label: const Text(
            'Not registered?',
            style: TextStyle(
              color: Color(0xFF00BFAE),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF00BFAE)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }





  Widget _buildPhoneInput() {
    return Form(
      key: _formKey,
      child: IntlPhoneField(
        controller: _phoneController,
        decoration: InputDecoration(
          hintText: 'Mobile Number',
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black45),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black26, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black26, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF00BFAE), width: 2),
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
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Terms of Service',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LoginHeaderWidget(
                        title: 'Log in or Sign Up',
                        subtitle: 'Enter your mobile number to receive a one-time password',
                        imageAsset: 'assets/images/treatment.png',
                      ),
                      const SizedBox(height: 24),
                      _buildPhoneInput(),
                      const SizedBox(height: 18),
                      PrimaryButtonWidget(
                        text: 'Get OTP',
                        onPressed: _handleGetOtp,
                        height: 50,
                      ),
                      const SizedBox(height: 10),
                      _buildActionButtons(),
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
    );
  }
} 
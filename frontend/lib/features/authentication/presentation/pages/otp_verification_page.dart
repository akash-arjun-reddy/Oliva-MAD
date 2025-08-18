import 'package:flutter/material.dart';
import 'setup_profile_page.dart';
import '../widgets/otp_input_widget.dart';
import '../widgets/primary_button_widget.dart';
import '../../../../services/api_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  
  const OtpVerificationPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    for (int i = 0; i < 5; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
  
  String get otpCode => _otpControllers.map((c) => c.text).join();
  
  Future<void> _verifyOtp() async {
    if (otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }
    
    try {
      _showLoadingDialog();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      _hideLoadingDialog();
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetupProfilePage()),
      );
    } catch (e) {
      _hideLoadingDialog();
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    }
  }
  
  Future<void> _resendOtp() async {
    try {
      _showLoadingDialog();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      _hideLoadingDialog();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully'))
      );
    } catch (e) {
      _hideLoadingDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'))
      );
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OTP Verification',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the OTP code sent to ${widget.phoneNumber}',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(6, (idx) {
            return Container(
              width: 40,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _otpControllers[idx],
                focusNode: _focusNodes[idx],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: _focusNodes[idx].hasFocus ? const Color(0xFFE6F7FA) : Colors.white,
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
                    borderSide: const BorderSide(color: Color(0xFF00BFAE), width: 2),
                  ),
                ),
              ),
            );
          }),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildResendSection() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive code?",
              style: TextStyle(
                color: Colors.black54, 
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _resendOtp,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFAE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00BFAE).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: Color(0xFF00BFAE),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 32),
            _buildOtpInput(),
            const SizedBox(height: 24),
            _buildResendSection(),
            const Spacer(),
            PrimaryButtonWidget(
              text: 'Verify Now',
              onPressed: _verifyOtp,
              height: 52,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 
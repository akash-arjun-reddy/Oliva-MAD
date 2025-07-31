import 'package:flutter/material.dart';
import '../../../features/authentication/presentation/pages/introduction_page.dart';

const Color kTextDark = Color(0xFF1A4D4A);

class OlivaSplashPage extends StatefulWidget {
  const OlivaSplashPage({Key? key}) : super(key: key);

  @override
  State<OlivaSplashPage> createState() => _OlivaSplashPageState();
}

class _OlivaSplashPageState extends State<OlivaSplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const IntroductionPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Expanded section for centering the logo
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/oliva_logo.png',
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Woman image at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/lady.png',
              height: 320,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}

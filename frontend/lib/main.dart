import 'package:flutter/material.dart';
import 'core/pages/oliva_splash_page.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/home_page.dart';
import 'features/authentication/presentation/pages/email_otp_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oliva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
        useMaterial3: true,
      ),
      home: const OlivaSplashPage(),
    );
  }
}

class SplashToLoginFlow extends StatefulWidget {
  const SplashToLoginFlow({Key? key}) : super(key: key);

  @override
  State<SplashToLoginFlow> createState() => _SplashToLoginFlowState();
}

class _SplashToLoginFlowState extends State<SplashToLoginFlow> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const OlivaSplashPage();
  }
}

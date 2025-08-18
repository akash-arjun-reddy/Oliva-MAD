import 'package:flutter/material.dart';
import 'core/pages/oliva_splash_page.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/home_page.dart';
import 'features/dashboard/presentation/pages/main_dashboard.dart';
import 'features/authentication/presentation/pages/email_otp_page.dart';
import 'features/consultation/routes/consultation_routes.dart';

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
      home: const SplashToLoginFlow(),
      routes: {
        '/dashboard': (context) => const MainDashboard(),
        ...ConsultationRoutes.getRoutes(),
      },
      onGenerateRoute: ConsultationRoutes.onGenerateRoute,
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
  Widget build(BuildContext context) {
    return const OlivaSplashPage();
  }
}

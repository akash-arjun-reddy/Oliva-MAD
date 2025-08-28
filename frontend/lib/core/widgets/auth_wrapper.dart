import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/newdashboard.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _lastLoginState = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Wait for AuthService to be initialized
    while (!authService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Force refresh auth state to ensure it's current
    await authService.forceRefreshAuthState();
    
    _lastLoginState = authService.isLoggedIn;
    print('🔍 AUTHWRAPPER: Initialized with isLoggedIn: $_lastLoginState');
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Check if login state changed
        if (_lastLoginState != authService.isLoggedIn) {
          print('🔍 AUTHWRAPPER: Login state changed from $_lastLoginState to ${authService.isLoggedIn}');
          _lastLoginState = authService.isLoggedIn;
          
          // Force immediate rebuild
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }

        print('🔍 AUTHWRAPPER: Building with isLoggedIn: ${authService.isLoggedIn}');
        
        if (authService.isLoggedIn) {
          print('🔍 AUTHWRAPPER: Showing NewDashboard');
          return const NewDashboardPage();
        } else {
          print('🔍 AUTHWRAPPER: Showing LoginPage');
          return const LoginPage();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'services/google_auth_service.dart';
import 'config/env.dart';

class GoogleOAuthTest extends StatefulWidget {
  const GoogleOAuthTest({Key? key}) : super(key: key);

  @override
  State<GoogleOAuthTest> createState() => _GoogleOAuthTestState();
}

class _GoogleOAuthTestState extends State<GoogleOAuthTest> {
  String _status = 'Ready to test';
  bool _isLoading = false;

  Future<void> _testGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Google Sign-In...';
    });

    try {
      final result = await GoogleAuthService.signInWithGoogle();
      
      if (result != null) {
        setState(() {
          _status = '✅ Google Sign-In Success!\nUser: ${result['user']?['email'] ?? 'Unknown'}';
        });
      } else {
        setState(() {
          _status = '❌ Google Sign-In cancelled by user';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Google Sign-In Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing backend connection...';
    });

    try {
      final baseUrl = await Env.findWorkingUrl();
      setState(() {
        _status = '✅ Backend URL: $baseUrl';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Backend connection error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google OAuth Test'),
        backgroundColor: const Color(0xFF00BFAE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Google OAuth Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testBackendConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFAE),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Test Backend Connection',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGoogleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Test Google Sign-In',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. First test backend connection'),
                    Text('2. Then test Google Sign-In'),
                    Text('3. Check the status messages above'),
                    Text('4. If successful, you can use the main app'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

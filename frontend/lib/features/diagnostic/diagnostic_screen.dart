import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/env.dart';
import '../../../services/token_service.dart';

class DiagnosticScreen extends StatefulWidget {
  @override
  _DiagnosticScreenState createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  String _status = 'Ready to test';
  List<String> _logs = [];
  bool _isTesting = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _testBackendConnection() async {
    setState(() {
      _isTesting = true;
      _status = 'Testing backend connection...';
    });

    try {
      String baseUrl = await Env.baseUrl;
      _addLog('📍 Backend URL: $baseUrl');

      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        _addLog('✅ Backend is reachable!');
        setState(() {
          _status = 'Backend connected successfully';
        });
      } else {
        _addLog('❌ Backend returned status: ${response.statusCode}');
        setState(() {
          _status = 'Backend connection failed';
        });
      }
    } catch (e) {
      _addLog('❌ Backend connection failed: $e');
      setState(() {
        _status = 'Backend connection failed';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testOTPFlow() async {
    setState(() {
      _isTesting = true;
      _status = 'Testing OTP flow...';
    });

    try {
      String baseUrl = await Env.baseUrl;

      // Test sending OTP
      final otpResponse = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'contact_number': '+919676052644'}),
      ).timeout(Duration(seconds: 10));

      _addLog('📱 OTP Send Status: ${otpResponse.statusCode}');
      _addLog('📄 OTP Response: ${otpResponse.body}');

      if (otpResponse.statusCode == 200) {
        _addLog('✅ OTP sent successfully!');
        setState(() {
          _status = 'OTP flow working';
        });
      } else {
        _addLog('❌ OTP send failed');
        setState(() {
          _status = 'OTP flow failed';
        });
      }
    } catch (e) {
      _addLog('❌ OTP test failed: $e');
      setState(() {
        _status = 'OTP flow failed';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testTokenService() async {
    setState(() {
      _isTesting = true;
      _status = 'Testing token service...';
    });

    try {
      // Test saving token
      await TokenService.saveToken('test_token', 'Bearer');
      _addLog('✅ Token saved successfully');

      // Test getting token
      String? token = await TokenService.getToken();
      if (token != null) {
        _addLog('✅ Token retrieved: ${token.substring(0, 10)}...');
      } else {
        _addLog('❌ Token retrieval failed');
      }

      // Test saving phone number
      await TokenService.saveUserPhoneNumber('+919676052644');
      _addLog('✅ Phone number saved');

      // Test getting phone number
      String? phone = await TokenService.getUserPhoneNumber();
      if (phone != null) {
        _addLog('✅ Phone number retrieved: $phone');
      } else {
        _addLog('❌ Phone number retrieval failed');
      }

      setState(() {
        _status = 'Token service working';
      });
    } catch (e) {
      _addLog('❌ Token service failed: $e');
      setState(() {
        _status = 'Token service failed';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _status = 'Ready to test';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔧 App Diagnostic'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _status.contains('failed') ? Colors.red : Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This screen helps test your app functionality',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testBackendConnection,
                    child: Text('🔗 Test Backend'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testOTPFlow,
                    child: Text('📱 Test OTP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isTesting ? null : _testTokenService,
              child: Text('🔑 Test Token Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Test Logs:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _clearLogs,
                  child: Text('Clear'),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _logs[index],
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
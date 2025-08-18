import 'package:flutter/material.dart';
import '../utils/network_utils.dart';
import '../../config/env.dart';

class NetworkTestPage extends StatefulWidget {
  const NetworkTestPage({super.key});

  @override
  State<NetworkTestPage> createState() => _NetworkTestPageState();
}

class _NetworkTestPageState extends State<NetworkTestPage> {
  Map<String, dynamic>? _testResults;
  bool _isLoading = false;

  Future<void> _runNetworkTest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> results = await NetworkUtils.runNetworkTest();
      setState(() {
        _testResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error running network test: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Test'),
        backgroundColor: const Color(0xFF00BFAE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _runNetworkTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFAE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Run Network Test', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            if (_testResults != null) ...[
              const Text(
                'Test Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultCard('Current IP', _testResults!['currentIp']),
                      _buildResultCard('Working URL', _testResults!['workingUrl']),
                      const SizedBox(height: 10),
                      const Text(
                        'Connectivity Tests:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      ...(_testResults!['connectivityTests'] as Map<String, dynamic>)
                          .entries
                          .map((entry) => _buildConnectivityResult(entry.key, entry.value)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectivityResult(String url, bool isAccessible) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          isAccessible ? Icons.check_circle : Icons.error,
          color: isAccessible ? Colors.green : Colors.red,
        ),
        title: Text(url),
        subtitle: Text(isAccessible ? 'Accessible' : 'Not accessible'),
      ),
    );
  }
} 
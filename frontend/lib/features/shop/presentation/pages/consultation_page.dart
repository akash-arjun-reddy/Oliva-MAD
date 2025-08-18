import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/navigation_helper.dart';
import '../../../consultation/routes/consultation_routes.dart';

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({Key? key}) : super(key: key);

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  bool _isLoading = false;
  String? _error;
  List<ServiceCenter> _serviceCenters = [];
  ConsultationType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Consultation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B2B8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            color: Color(0xFF00B2B8),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose Consultation Type',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Select your preferred consultation method',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Consultation Options
              Row(
                children: [
                  Expanded(
                    child: _buildConsultationOption(
                      title: 'Offline Consultation',
                      subtitle: 'Visit our centers',
                      icon: Icons.location_on,
                      color: const Color(0xFF00B2B8),
                      onTap: () => _selectConsultationType(ConsultationType.offline),
                      isSelected: _selectedType == ConsultationType.offline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildConsultationOption(
                      title: 'Online Consultation',
                      subtitle: 'Video call consultation',
                      icon: Icons.video_call,
                      color: const Color(0xFF197D7D),
                      onTap: () => _selectConsultationType(ConsultationType.online),
                      isSelected: _selectedType == ConsultationType.online,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Results Section
              if (_selectedType != null) ...[
                Expanded(
                  child: _buildResultsSection(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsultationOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color.withOpacity(0.8) : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  _selectedType == ConsultationType.offline
                      ? Icons.location_on
                      : Icons.video_call,
                  color: const Color(0xFF00B2B8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedType == ConsultationType.offline
                      ? 'Service Centers'
                      : 'Online Consultation',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildResultsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent() {
    if (_selectedType == ConsultationType.online) {
      return _buildOnlineConsultation();
    } else {
      return _buildOfflineConsultation();
    }
  }

  Widget _buildOnlineConsultation() {
                     // Navigate to consultation type selection
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                   Navigator.pushNamed(context, ConsultationRoutes.consultation);
                 });
    
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B2B8)),
      ),
    );
  }

  Widget _buildOfflineConsultation() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B2B8)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading service centers...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load service centers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchServiceCenters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B2B8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_serviceCenters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.location_off,
                size: 48,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No service centers found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _serviceCenters.length,
      itemBuilder: (context, index) {
        final center = _serviceCenters[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00B2B8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFF00B2B8),
                size: 20,
              ),
            ),
            title: Text(
              center.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  center.address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (center.phone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        center.phone!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Show snackbar message with center name
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Booking for ${center.name} coming soon!',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 3),
                    backgroundColor: const Color(0xFF00B2B8),
                    behavior: SnackBarBehavior.floating,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                );
                
                // Navigate to Explore tab after a short delay
                Future.delayed(const Duration(milliseconds: 800), () {
                  _navigateToExploreTab(context);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B2B8),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Book'),
            ),
          ),
        );
      },
    );
  }

     void _selectConsultationType(ConsultationType type) {
     if (type == ConsultationType.online) {
       // Navigate to consultation type selection
       Navigator.pushNamed(context, ConsultationRoutes.consultation);
       return;
     }
    
    setState(() {
      _selectedType = type;
      _serviceCenters.clear();
      _error = null;
    });

    if (type == ConsultationType.offline) {
      _fetchServiceCenters();
    }
  }

  Future<void> _fetchServiceCenters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.zenoti.com/v1/Centers/90e79e59-6202-4feb-a64f-b647801469e4/services?page=1&size=100'),
        headers: {
          'Authorization': 'apikey f5bd053c34de47c686d2a0f35e68c136e7539811437e4749915b48e725d40eca',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final centers = <ServiceCenter>[];

        // Parse the response and extract service centers
        if (data['centers'] != null) {
          for (final center in data['centers']) {
            centers.add(ServiceCenter.fromJson(center));
          }
        } else if (data['data'] != null && data['data']['centers'] != null) {
          // Alternative response format
          for (final center in data['data']['centers']) {
            centers.add(ServiceCenter.fromJson(center));
          }
        } else {
          // If API doesn't return expected format, use mock data
          centers.addAll(_getMockServiceCenters());
        }

        setState(() {
          _serviceCenters = centers;
          _isLoading = false;
        });
      } else {
        // If API fails, use mock data
        setState(() {
          _serviceCenters = _getMockServiceCenters();
          _isLoading = false;
        });
      }
    } catch (e) {
      // If network error, use mock data
      setState(() {
        _serviceCenters = _getMockServiceCenters();
        _isLoading = false;
      });
    }
  }

  List<ServiceCenter> _getMockServiceCenters() {
    return [
      ServiceCenter(
        id: '1',
        name: 'Oliva Skin & Hair Clinic - Mumbai',
        address: 'Shop No. 5, Ground Floor, Crystal Plaza, Andheri West, Mumbai - 400058',
        phone: '+91 22 2678 9012',
        email: 'mumbai@oliva.com',
        latitude: 19.0760,
        longitude: 72.8777,
      ),
      ServiceCenter(
        id: '2',
        name: 'Oliva Skin & Hair Clinic - Delhi',
        address: 'C-12, Connaught Place, New Delhi - 110001',
        phone: '+91 11 2345 6789',
        email: 'delhi@oliva.com',
        latitude: 28.6139,
        longitude: 77.2090,
      ),
      ServiceCenter(
        id: '3',
        name: 'Oliva Skin & Hair Clinic - Bangalore',
        address: 'No. 45, MG Road, Bangalore - 560001',
        phone: '+91 80 2345 6789',
        email: 'bangalore@oliva.com',
        latitude: 12.9716,
        longitude: 77.5946,
      ),
      ServiceCenter(
        id: '4',
        name: 'Oliva Skin & Hair Clinic - Chennai',
        address: 'Plot No. 12, Anna Nagar, Chennai - 600040',
        phone: '+91 44 2345 6789',
        email: 'chennai@oliva.com',
        latitude: 13.0827,
        longitude: 80.2707,
      ),
      ServiceCenter(
        id: '5',
        name: 'Oliva Skin & Hair Clinic - Hyderabad',
        address: 'Shop No. 8, Banjara Hills, Hyderabad - 500034',
        phone: '+91 40 2345 6789',
        email: 'hyderabad@oliva.com',
        latitude: 17.3850,
        longitude: 78.4867,
      ),
    ];
  }

  /// Navigates to the Explore tab in the bottom navigation
  void _navigateToExploreTab(BuildContext context) {
    NavigationHelper.navigateToExplore(context);
  }
}

enum ConsultationType { offline, online }

class ServiceCenter {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;

  ServiceCenter({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
  });

  factory ServiceCenter.fromJson(Map<String, dynamic> json) {
    return ServiceCenter(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
      email: json['email'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

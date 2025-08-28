import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shop/presentation/pages/shop_page.dart';
import 'explore_screen.dart';
import '../../../doctor/presentation/pages/doctors_page.dart';
import 'concern_page.dart';
import '../../data/appointment_api_service.dart';
import '../../services/video_call_service.dart';
import '../../../../services/token_service.dart';
import '../../../../config/env.dart';
import '../widgets/video_call_otp_dialog.dart';
import '../../../diagnostic/diagnostic_screen.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/auth_wrapper.dart';

class NewDashboardPage extends StatefulWidget {
  const NewDashboardPage({Key? key}) : super(key: key);

  @override
  State<NewDashboardPage> createState() => _NewDashboardPageState();
}

class _NewDashboardPageState extends State<NewDashboardPage> {
  int _selectedIndex = 0;
  String _selectedLocation = "Begumpet";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Top Bar - Equal height with bottom bar
          Container(
            height: 60, // Fixed height equal to bottom bar
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00B383), // Oliva green
                  Color(0xFF0077B6), // Deep blue
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Location Icon with Text
                    GestureDetector(
                      onTap: _showLocationDialog,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedLocation,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Profile/Menu Icon with Logout
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'logout') {
                              _showLogoutDialog(context, authService);
                            } else if (value == 'profile') {
                              _showProfileDialog(context, authService);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            if (authService.userData != null)
                              PopupMenuItem<String>(
                                value: 'profile',
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: authService.userData!['picture'] != null
                                          ? NetworkImage(authService.userData!['picture'])
                                          : null,
                                      child: authService.userData!['picture'] == null
                                          ? Text(authService.userData!['name']?[0] ?? 'U')
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            authService.userData!['name'] ?? 'User',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            authService.userData!['email'] ?? '',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Logout', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: authService.userData?['picture'] != null
                                ? NetworkImage(authService.userData!['picture'])
                                : null,
                            child: authService.userData?['picture'] == null
                                ? Text(authService.userData?['name']?[0] ?? 'U')
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Search Bar - Fixed position below top bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search services, doctors, products…',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          // Scrollable Content Area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Banner Carousel
                  SizedBox(
                    height: 220,
                    child: PageView(
                      children: [
                        _BannerCard(),
                        _BannerCard(),
                        _BannerCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // FEEL YOUNG LOOK YOUNGER Section
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF00796B), // Teal
                          Color(0xFF00BFAE), // Light teal
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FEEL YOUNG\nLOOK YOUNGER',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _OfferCard(
                              image: 'assets/images/skin_light.png',
                              label: 'Skin Lightening',
                              price: '₹4,830',
                            ),
                            _OfferCard(
                              image: 'assets/images/hair_rev.png',
                              label: 'Hair Revival',
                              price: '₹5,040',
                            ),
                            _OfferCard(
                              image: 'assets/images/body_count.png',
                              label: 'Body Contouring',
                              price: '₹6,843',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Our Treatments
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Our Treatments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ConcernPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00796B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'What\'s Your Concern?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'View All',
                              style: TextStyle(
                                color: Color(0xFF00796B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: const [
                        _TreatmentCard(
                          image: 'assets/images/unwanted_hair.png',
                          label: 'Unwanted Hair',
                        ),
                        SizedBox(width: 12),
                        _TreatmentCard(
                          image: 'assets/images/skin_rej.png',
                          label: 'Skin Rejuvenation',
                        ),
                        SizedBox(width: 12),
                        _TreatmentCard(
                          image: 'assets/images/anti_age.png',
                          label: 'Anti-Aging',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Upcoming Consultation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upcoming Consultation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ConsultationCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Promotional Image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/dbp.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        height: 170,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Testimonial Carousel Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Qualified Doctors. Real Results',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 400,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _TestimonialCard(
                                beforeImage: 'assets/images/before1.png',
                                afterImage: 'assets/images/female_icon.png',
                                name: 'Ameena Ara Khanum',
                                testimonial:
                                    "I have been in a dilemma about going for laser services that offer quality and are affordable too. After researching, I stumbled upon Oliva that offers revolutionary results without burning a hole in the pocket. Can't recommend it enough.",
                                treatment: 'Laser Hair Removal',
                              ),
                              const SizedBox(width: 18),
                              _TestimonialCard(
                                beforeImage: 'assets/images/male_icon.png',
                                afterImage: 'assets/images/doctors_group.png',
                                name: 'Rahul Sharma',
                                testimonial:
                                    "The results were amazing and the doctors are very professional. Highly recommend Oliva for anyone looking for real results!",
                                treatment: 'Acne Scar Treatment',
                              ),
                              const SizedBox(width: 18),
                              _TestimonialCard(
                                beforeImage: 'assets/images/female_icon.png',
                                afterImage: 'assets/images/doctors_placeholder.png',
                                name: 'Priya Verma',
                                testimonial:
                                    "I was skeptical at first, but the transformation is real. Thank you Oliva!",
                                treatment: 'Skin Rejuvenation',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Bottom Bar - Equal height with top bar
          Container(
            height: 60, // Fixed height equal to top bar
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00B383), // Oliva green
                  Color(0xFF0077B6), // Deep blue
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.home, 'Home', 0),
                  _buildBottomNavItem(Icons.calendar_today, 'Appointments', 1),
                  _buildScannerItem(),
                  _buildBottomNavItem(Icons.local_offer, 'Deals', 3),
                  _buildBottomNavItem(Icons.person, 'Profile', 4),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiagnosticScreen(),
            ),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.bug_report, color: Colors.white),
        tooltip: 'App Diagnostic',
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _handleNavigation(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerItem() {
    final isSelected = _selectedIndex == 2;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = 2;
        });
        _handleNavigation(2);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.qr_code_scanner,
              color: Colors.black,
              size: 28, // Slightly larger to highlight
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Scanner',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: // Home
        // Already on home
        break;
      case 1: // Appointments
        NavigationHelper.navigateToConsult(context);
        break;
      case 2: // Scanner
        // Handle scanner functionality
        break;
      case 3: // Deals
        NavigationHelper.navigateToShop(context);
        break;
      case 4: // Profile
        // Handle profile navigation
        break;
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Use Current Location'),
                onTap: () {
                  // Enable system location
                  Navigator.pop(context);
                  setState(() {
                    _selectedLocation = "Current Location";
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search Location'),
                onTap: () {
                  Navigator.pop(context);
                  _showLocationSearch();
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Popular Locations'),
                onTap: () {
                  Navigator.pop(context);
                  _showPopularLocations();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationSearch() {
    // Implement location search functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Location'),
          content: const TextField(
            decoration: InputDecoration(
              hintText: 'Enter city or area name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedLocation = "New Location";
                });
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  void _showPopularLocations() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Popular Locations'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Begumpet'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedLocation = "Begumpet";
                  });
                },
              ),
              ListTile(
                title: const Text('Banjara Hills'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedLocation = "Banjara Hills";
                  });
                },
              ),
              ListTile(
                title: const Text('Jubilee Hills'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedLocation = "Jubilee Hills";
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                print('🔍 DASHBOARD: User clicked logout');
                
                // Single logout call - the enhanced logout method should handle everything
                await authService.logout();
                print('🔍 DASHBOARD: Logout completed');
                
                // Force navigation to ensure UI updates
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthWrapper(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showProfileDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (authService.userData != null) ...[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: authService.userData!['picture'] != null
                      ? NetworkImage(authService.userData!['picture'])
                      : null,
                  child: authService.userData!['picture'] == null
                      ? Text(authService.userData!['name']?[0] ?? 'U', style: const TextStyle(fontSize: 24))
                      : null,
                ),
                const SizedBox(height: 16),
                Text('Name: ${authService.userData!['name'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Email: ${authService.userData!['email'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Account Type: ${authService.userData!['is_new_user'] == true ? 'New User' : 'Existing User'}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Color(0xFF00B2B8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FEEL YOUNG\nLOOK YOUNGER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BannerMiniCard(image: 'assets/images/skin_light.png', label: 'Skin Lightening', price: 'Starts From ₹4,830', avatarRadius: 38, labelFont: 14, priceFont: 12),
                  _BannerMiniCard(image: 'assets/images/hair_rev.png', label: 'Hair Revival', price: 'Starts From ₹5,040', avatarRadius: 38, labelFont: 14, priceFont: 12),
                  _BannerMiniCard(image: 'assets/images/body_count.png', label: 'Body Contouring', price: 'Starts From ₹6,843', avatarRadius: 38, labelFont: 14, priceFont: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerMiniCard extends StatelessWidget {
  final String image;
  final String label;
  final String price;
  final double avatarRadius;
  final double labelFont;
  final double priceFont;
  const _BannerMiniCard({required this.image, required this.label, required this.price, this.avatarRadius = 24, this.labelFont = 12, this.priceFont = 10});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(backgroundImage: AssetImage(image), radius: avatarRadius),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: labelFont)),
        Text(price, style: TextStyle(color: Colors.white, fontSize: priceFont)),
      ],
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  final String image;
  final String label;
  const _TreatmentCard({required this.image, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _ConsultationCard extends StatefulWidget {
  const _ConsultationCard();

  @override
  State<_ConsultationCard> createState() => _ConsultationCardState();
}

class _ConsultationCardState extends State<_ConsultationCard> {
  bool _isLoading = false;
  late AppointmentApiService _appointmentApiService;
  
  // Mock appointment ID - in real app, this would come from the appointment data
  final String _appointmentId = "mock-appointment-id-123";

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final baseUrl = await Env.findWorkingUrl();
    _appointmentApiService = AppointmentApiService(baseUrl: baseUrl);
  }

  Future<void> _handleJoinVideo() async {
    if (!await TokenService.isAuthenticated()) {
      _showErrorDialog('Authentication Required', 'Please log in to join the video consultation.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Show OTP dialog for video call verification
      await _showVideoCallOtpDialog();
    } catch (e) {
      _showErrorDialog('Error', 'Failed to join video call: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showVideoCallOtpDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return VideoCallOtpDialog(
          appointmentId: _appointmentId,
          onSendOtp: () async {
            await _appointmentApiService.sendVideoCallOtp(_appointmentId);
          },
          onOtpVerified: (String otpCode) async {
            final result = await _appointmentApiService.verifyVideoCallOtp(_appointmentId, otpCode);
            final videoCallLink = result['video_call_link'] as String;
            
            if (videoCallLink.isNotEmpty) {
              await VideoCallService.joinVideoCallWithConfirmation(videoCallLink, context);
            } else {
              throw Exception('No video call link available');
            }
          },
          isLoading: _isLoading,
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Laser Treatment',
                  style: TextStyle(
                    color: Color(0xFF00B2B8),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFB2EBF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Confirmed',
                  style: TextStyle(
                    color: Color(0xFF00B2B8),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Friday, July 12',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(fontSize: 18, color: Colors.black38)),
              const SizedBox(width: 8),
              const Text(
                '8:00 - 8:30 AM',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300, height: 1, thickness: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/female_icon.png'),
                radius: 28,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dr. Pooja R Uppoor',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Video Consultation',
                    style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00B2B8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _handleJoinVideo,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Join Video', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String image;
  final String label;
  final String price;

  const _OfferCard({
    required this.image,
    required this.label,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Starts From $price',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String beforeImage;
  final String afterImage;
  final String name;
  final String testimonial;
  final String treatment;
  const _TestimonialCard({
    required this.beforeImage,
    required this.afterImage,
    required this.name,
    required this.testimonial,
    required this.treatment,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.13),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    beforeImage,
                    width: 70,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    afterImage,
                    width: 70,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              testimonial,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                treatment,
                style: const TextStyle(
                  color: Color(0xFF00B2B8),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
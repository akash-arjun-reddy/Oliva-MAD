import 'package:flutter/material.dart';
import '../../../shop/presentation/pages/shop_page.dart';
import 'explore_screen.dart';
import '../../../doctor/presentation/pages/doctors_page.dart'; // Added import for DoctorsPage
import 'concern_page.dart';
import '../../data/appointment_api_service.dart';
import '../../services/video_call_service.dart';
import '../../../../services/token_service.dart';
import '../../../../config/env.dart';
import '../widgets/video_call_otp_dialog.dart';
import '../../../diagnostic/diagnostic_screen.dart';
import '../../../../core/utils/navigation_helper.dart';

class NewDashboardPage extends StatefulWidget {
  const NewDashboardPage({Key? key}) : super(key: key);

  @override
  State<NewDashboardPage> createState() => _NewDashboardPageState();
}

class _NewDashboardPageState extends State<NewDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: true,
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
        child: Icon(Icons.bug_report, color: Colors.white),
        tooltip: 'App Diagnostic',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Blue-green gradient top bar
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A), // Deep blue
                    Color(0xFF3B82F6), // Medium blue
                    Color(0xFF06B6D4), // Cyan
                    Color(0xFF10B981), // Emerald green
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.location_on, color: Colors.white, size: 20),
                                  SizedBox(width: 4),
                                  Text('Begumpet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search treatments, doctor etc',
                        hintStyle: TextStyle(color: Color(0xFF1A4D4A), fontSize: 16),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF00796B)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Our Treatments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          _TreatmentCard(image: 'assets/images/unwanted_hair.png', label: 'Unwanted Hair'),
                          SizedBox(width: 12),
                          _TreatmentCard(image: 'assets/images/skin_rej.png', label: 'Skin Rejuvenation'),
                          SizedBox(width: 12),
                          _TreatmentCard(image: 'assets/images/anti_age.png', label: 'Anti-Aging'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Upcoming Consultation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    _ConsultationCard(),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/dbp.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        height: 170,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Testimonial Carousel Section
                    const Text(
                      'Qualified Doctors. Real Results',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _TestimonialCard(
                            beforeImage: 'assets/images/before1.png',
                            afterImage: 'assets/images/female_icon.png',
                            name: 'Ameena Ara Khanum',
                            testimonial: "I have been in a dilemma about going for laser services that offer quality and are affordable too. After researching, I stumbled upon Oliva that offers revolutionary results without burning a hole in the pocket. Can’t recommend it enough.",
                            treatment: 'Laser Hair Removal',
                          ),
                          SizedBox(width: 18),
                          _TestimonialCard(
                            beforeImage: 'assets/images/male_icon.png',
                            afterImage: 'assets/images/doctors_group.png',
                            name: 'Rahul Sharma',
                            testimonial: "The results were amazing and the doctors are very professional. Highly recommend Oliva for anyone looking for real results!",
                            treatment: 'Acne Scar Treatment',
                          ),
                          SizedBox(width: 18),
                          _TestimonialCard(
                            beforeImage: 'assets/images/female_icon.png',
                            afterImage: 'assets/images/doctors_placeholder.png',
                            name: 'Priya Verma',
                            testimonial: "I was skeptical at first, but the transformation is real. Thank you Oliva!",
                            treatment: 'Skin Rejuvenation',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00B2B8),
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            NavigationHelper.navigateToShop(context);
          }
          if (index == 2) {
            NavigationHelper.navigateToConsult(context);
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorsPage()),
            );
          }
          if (index == 4) {
            NavigationHelper.navigateToExplore(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Consult',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Explore',
          ),
        ],
      ),
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
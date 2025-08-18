import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import '../../../consultation/routes/consultation_routes.dart';

const Color kTealGreen = Color(0xFF00796B);
const Color kTealLight = Color(0xFFE0F2F1);
const Color kTextDark = Color(0xFF1A4D4A);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGradientHeader(context),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
        child: Column(
          children: [
                        _buildOffersSection(context),
                        _buildMainCards(context),
                        _buildMiniCards(context),
                        const SizedBox(height: 18),
                        _buildTreatmentsSection(context),
                        const SizedBox(height: 12),
                        _buildTreatmentCards(context),
                        const SizedBox(height: 12),
                        _buildDoctorGrid(context),
                        const SizedBox(height: 24),
                        _buildUpcomingConsultation(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Floating banner
          _buildFloatingBanner(context),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search treatments, doctor etc',
                hintStyle: const TextStyle(color: kTextDark, fontSize: 16),
                prefixIcon: const Icon(Icons.search, color: kTealGreen),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00796B), // Teal
            Color(0xFF00BFAE), // Light teal
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00796B).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
          const Text(
            'FEEL YOUNG',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'LOOK YOUNGER',
            style: TextStyle(
                            color: Colors.white,
              fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOfferCard(
                  'Skin Lightening',
                  'Starts From ₹4,830',
                  'assets/images/skin_light.png',
                  'Skin Lightening Treatments',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOfferCard(
                  'Hair Revival',
                  'Starts From ₹5,040',
                  'assets/images/hair_rev.png',
                  'Hair Revival Treatments',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOfferCard(
                  'Body Contouring',
                  'Starts From ₹6,843',
                  'assets/images/body_count.png',
                  'Body Contouring Treatments',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String title, String price, String image, String treatment) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(image),
                backgroundColor: Colors.white,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                          child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                    treatment,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00796B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            price,
            style: const TextStyle(
                      color: Colors.white,
              fontSize: 10,
                    ),
            textAlign: TextAlign.center,
                  ),
                ],
              ),
    );
  }

  Widget _buildMainCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
          Expanded(
            child: _ImageCard(
              title: 'Book In-Clinic Appointment',
              image: 'assets/images/lady2.png',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ImageCard(
              title: 'Instant Video Consultation',
              image: 'assets/images/doctors_placeholder.png',
              onTap: () {
                      Navigator.pushNamed(context, ConsultationRoutes.consultation);
                    },
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildMiniCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
          _MiniImageCard(
            title: 'Medicines',
            image: 'assets/images/doctors_placeholder.png',
            onTap: () {},
          ),
          _MiniImageCard(
            title: 'Lab Tests',
            image: 'assets/images/lady.png',
            onTap: () {},
          ),
          _MiniImageCard(
            title: 'Surgeries',
            image: 'assets/images/lady2.png',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
          const Text(
            'Our Treatments',
            style: TextStyle(
              fontSize: 18,
                      fontWeight: FontWeight.bold,
              color: kTextDark,
                    ),
                  ),
          Row(
            children: [
              ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, ConsultationRoutes.consultation);
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTealGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
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
                  color: kTealGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildTreatmentCard(
              'Unwanted Hair',
              'assets/images/unwanted_hair.png',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTreatmentCard(
              'Skin Rejuvenation',
              'assets/images/skin_rej.png',
            ),
          ),
          const SizedBox(width: 12),
            Expanded(
            child: _buildTreatmentCard(
              'Anti-Aging',
              'assets/images/anti_age.png',
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildTreatmentCard(String title, String image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(image),
            backgroundColor: kTealLight,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: kTextDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorGrid(BuildContext context) {
    final items = [
      {'icon': Icons.medical_services, 'label': 'General Physician'},
      {'icon': Icons.face_retouching_natural, 'label': 'Skin & Hair'},
      {'icon': Icons.pregnant_woman, 'label': "Women's Health"},
      {'icon': Icons.medical_services, 'label': 'Dental Care'},
      {'icon': Icons.child_care, 'label': 'Child'},
      {'icon': Icons.hearing, 'label': 'Ear, Nose'},
      {'icon': Icons.psychology, 'label': 'Mental'},
      {'icon': Icons.more_horiz, 'label': '20+\nmore'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 18,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kTealLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  items[i]['icon'] as IconData,
                  color: kTealGreen,
                  size: 32,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  (items[i]['label'] as String).replaceAll('\\n', '\n'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: kTextDark),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpcomingConsultation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Consultation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
              borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
          ),
        ],
      ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
                    const Text(
                      'Laser Treatment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTealGreen,
                      ),
                    ),
          Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                        color: const Color(0xFF00BFAE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Confirmed',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Friday, July 12 • 8:00 - 8:30 AM',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: kTealLight,
                      child: Icon(Icons.person, color: kTealGreen),
                    ),
                    const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                          const Text(
                            'Dr. Pooja R Uppoor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kTextDark,
                            ),
                          ),
                          const Text(
                            'Video Consultation',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTealGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Join Video',
                      style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBanner(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 18,
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: 14,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00796B),
                      Color(0xFF00BFAE),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00796B).withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: const AssetImage('assets/images/lady.png'),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                Row(
                  children: [
                              const Text(
                                'Ask Care AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'FREE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                      ),
                    ),
                  ],
                ),
                          const SizedBox(height: 2),
                          const Text(
                            '20000+ health queries resolved in last month',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
              ],
            ),
          ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.arrow_forward, color: kTealGreen, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const _ImageCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(image, height: 56, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kTextDark,
                    fontWeight: FontWeight.w600,
                      fontSize: 15,
                  ),
                ),
              ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, color: kTealGreen, size: 16),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class _MiniImageCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const _MiniImageCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(image, height: 40, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextDark,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
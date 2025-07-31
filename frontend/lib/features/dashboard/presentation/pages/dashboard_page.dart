
import 'package:flutter/material.dart';
import 'concern_page.dart';

const Color kTealGreen = Color(0xFF00796B);
const Color kTealLight = Color(0xFFE0F2F1);
const Color kTextDark = Color(0xFF1A4D4A);

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildMainCards(context),
                _buildMiniCards(context),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Find a Doctor for your Health Problem',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                        ),
                      ),
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
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildDoctorGrid(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
          _buildFloatingBanner(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kTealGreen,
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
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: kTealGreen, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.location_on, color: Colors.white, size: 20),
                    SizedBox(width: 4),
                    Text('Begumpet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for Services',
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
              onTap: () {},
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
              Text(
                (items[i]['label'] as String).replaceAll('\\n', '\n'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: kTextDark),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingBanner(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 18,
      child: Material(
        elevation: 14,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: kTealGreen,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: kTealGreen.withOpacity(0.18),
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
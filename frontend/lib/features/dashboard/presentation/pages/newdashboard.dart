import 'package:flutter/material.dart';
import '../../../shop/presentation/pages/shop_page.dart';
import 'explore_screen.dart';
import '../../../doctor/presentation/pages/doctors_page.dart'; // Added import for DoctorsPage
import 'concern_page.dart';

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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search treatments, doctor etc',
                    border: InputBorder.none,
                  ),
                ),
              ),
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopPage()),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorsPage()),
            );
          }
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExploreScreen()),
            );
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

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard();
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
              onPressed: () {},
              child: const Text('Join Video', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
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
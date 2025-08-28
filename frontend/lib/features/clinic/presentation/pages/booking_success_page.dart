import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/newdashboard.dart';

class BookingSuccessPage extends StatefulWidget {
  const BookingSuccessPage({Key? key}) : super(key: key);

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage> {
  String _selectedTreatment = 'skin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top half: background image fills the space
          Expanded(
            flex: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/success_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Text overlay removed as requested
              ],
            ),
          ),
          // Bottom half: treatment cards with gradient background
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE6F7FA), // Light teal
                    Color(0xFFF0F9F6), // Very light green
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Hello Mivan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Let us know how we can assist you',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _treatmentCard(
                          selected: _selectedTreatment == 'skin',
                          icon: 'assets/images/skin_icon.png',
                          label: 'Skin Treatment',
                          onTap: () {
                            setState(() => _selectedTreatment = 'skin');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const NewDashboardPage()),
                            );
                          },
                        ),
                        const SizedBox(width: 18),
                        _treatmentCard(
                          selected: _selectedTreatment == 'hair',
                          icon: 'assets/images/hair_icon.png',
                          label: 'Hair Treatment',
                          onTap: () {
                            setState(() => _selectedTreatment = 'hair');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const NewDashboardPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _treatmentCard({
    required bool selected,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double cardWidth = MediaQuery.of(context).size.width / 2 - 32; // 16 padding each side + 18 spacing
          final double imageHeight = cardWidth * 0.8;
          return Container(
            width: cardWidth,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? const Color(0xFF00BFAE) : Colors.black26,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        icon,
                        width: cardWidth,
                        height: imageHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 8,
                      child: selected
                          ? const Icon(Icons.check_circle, color: Color(0xFF00BFAE), size: 22)
                          : const Icon(Icons.circle, color: Colors.black26, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 
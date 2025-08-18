import 'package:flutter/material.dart';
import 'dart:math' as math;

const Color kTealGreen = Color(0xFF00796B);
const Color kTealLight = Color(0xFFE0F2F1);
const Color kTextDark = Color(0xFF1A4D4A);
const Color kGiftBackground = Color(0xFFF8F9FA);

class ConcernPage extends StatefulWidget {
  const ConcernPage({super.key});

  @override
  State<ConcernPage> createState() => _ConcernPageState();
}

class _ConcernPageState extends State<ConcernPage>
    with TickerProviderStateMixin {
  late AnimationController _curveController;
  late AnimationController _giftController;
  late AnimationController _scratchController;
  late AnimationController _ribbonController;
  
  late Animation<double> _curveAnimation;
  late Animation<double> _giftAnimation;
  late Animation<double> _scratchAnimation;
  late Animation<double> _ribbonAnimation;
  
  bool _showOffers = false;
  bool _showScratchCard = false;
  int _selectedGiftIndex = -1;
  double _scratchProgress = 0.0;
  
  final List<Map<String, dynamic>> _gifts = [
    {
      'reward': '50% Off on Consultation',
      'color': Color(0xFFFF6B6B),
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
    },
    {
      'reward': 'Buy 1 Consultation, Get 1 Free',
      'color': Color(0xFF4ECDC4),
      'gradient': [Color(0xFF11998e), Color(0xFF38ef7d)],
    },
    {
      'reward': '40% Off on Select Services',
      'color': Color(0xFFFFE66D),
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _curveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _giftController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scratchController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _ribbonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _curveAnimation = CurvedAnimation(
      parent: _curveController,
      curve: Curves.easeInOutCubic,
    );
    
    _giftAnimation = CurvedAnimation(
      parent: _giftController,
      curve: Curves.easeOutBack,
    );
    
    _scratchAnimation = CurvedAnimation(
      parent: _scratchController,
      curve: Curves.elasticOut,
    );
    
    _ribbonAnimation = CurvedAnimation(
      parent: _ribbonController,
      curve: Curves.easeOutBack,
    );
    
    // Start the curve animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _curveController.forward();
      }
    });
    
    // Start gift animations after curve animation
    _curveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showOffers = true);
        _giftController.forward();
      }
    });
  }

  @override
  void dispose() {
    _curveController.dispose();
    _giftController.dispose();
    _scratchController.dispose();
    _ribbonController.dispose();
    super.dispose();
  }

  void _openScratchCard(int giftIndex) {
    setState(() {
      _selectedGiftIndex = giftIndex;
      _showScratchCard = true;
      _scratchProgress = 0.0;
    });
    _scratchController.forward();
  }

  void _onScratchUpdate(double progress) {
    setState(() {
      _scratchProgress = progress;
    });
    
    if (progress > 0.7 && !_ribbonController.isCompleted) {
      _ribbonController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Dashboard Background
          _buildDashboardBackground(),
          
          // S-Curve Partition with Offers
          AnimatedBuilder(
            animation: _curveAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, 200 * (1 - _curveAnimation.value)),
                  child: _buildSCurvePartition(),
                ),
              );
            },
          ),
          
          // Scratch Card Dialog
          if (_showScratchCard) _buildScratchCard(),
        ],
      ),
    );
  }

  Widget _buildDashboardBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kTealGreen, Colors.white],
          stops: [0.0, 0.6],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'What Is Your Concern?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            
            // Main Content Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.medical_services,
                      size: 80,
                      color: kTealGreen,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tell us about your health concern',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We\'ll help you find the right specialist and get the care you need',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // This would typically navigate to a form or selection page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kTealGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start Consultation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSCurvePartition() {
    return Container(
      height: 250,
      decoration: const BoxDecoration(
        color: kGiftBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // S-Curve Decoration
          Container(
            height: 40,
            child: CustomPaint(
              size: const Size(double.infinity, 40),
              painter: SCurvePainter(),
            ),
          ),
          
          // Offers Section
          if (_showOffers) 
            Expanded(child: _buildOffersSection())
          else
            const Expanded(
              child: Center(
                child: Text(
                  'Loading offers...',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOffersSection() {
    return AnimatedBuilder(
      animation: _giftAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _giftAnimation.value,
          child: Opacity(
            opacity: _giftAnimation.value,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Special Offers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_gifts.length, (index) {
                        return _buildGiftCard(index);
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGiftCard(int index) {
    final gift = _gifts[index];
    return GestureDetector(
      onTap: () => _openScratchCard(index),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: gift['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gift['color'].withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use a gift icon instead of image asset
            Icon(
              Icons.card_giftcard,
              size: 32,
              color: gift['color'],
            ),
            const SizedBox(height: 4),
            Text(
              'Tap!',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: gift['color'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScratchCard() {
    if (_selectedGiftIndex == -1) return const SizedBox.shrink();
    
    final gift = _gifts[_selectedGiftIndex];
    
    return AnimatedBuilder(
      animation: _scratchAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scratchAnimation.value,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(40),
                width: 280,
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gift['gradient'],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Scratch Card Content
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _buildScratchCardContent(gift),
                      ),
                    ),
                    
                    // Ribbons Animation
                    if (_ribbonController.isCompleted)
                      _buildRibbons(),
                    
                    // Close Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () {
                          _scratchController.reverse().then((_) {
                            setState(() {
                              _showScratchCard = false;
                              _selectedGiftIndex = -1;
                            });
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScratchCardContent(Map<String, dynamic> gift) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Simulate scratching effect
        _onScratchUpdate(_scratchProgress + 0.1);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gift['gradient'],
          ),
        ),
        child: Stack(
          children: [
            // Scratch overlay
            if (_scratchProgress < 0.7)
              Positioned.fill(
                child: Container(
                  color: Colors.grey.withOpacity(0.8),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Scratch to Reveal!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Reward content
            if (_scratchProgress > 0.3)
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _ribbonAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _ribbonAnimation.value,
                            child: const Icon(
                              Icons.card_giftcard,
                              color: Colors.white,
                              size: 64,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: _ribbonAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _ribbonAnimation.value,
                            child: const Text(
                              '🎉 Congratulations!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _ribbonAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _ribbonAnimation.value,
                            child: Text(
                              gift['reward'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      AnimatedBuilder(
                        animation: _ribbonAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _ribbonAnimation.value,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle claim reward
                                _scratchController.reverse().then((_) {
                                  setState(() {
                                    _showScratchCard = false;
                                    _selectedGiftIndex = -1;
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: gift['gradient'][0],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Claim Reward',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRibbons() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top ribbon
          Positioned(
            top: 20,
            left: 20,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          // Bottom ribbon
          Positioned(
            bottom: 20,
            right: 20,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          // Left ribbon
          Positioned(
            left: 20,
            top: 50,
            child: Transform.rotate(
              angle: math.pi / 2,
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          // Right ribbon
          Positioned(
            right: 20,
            bottom: 50,
            child: Transform.rotate(
              angle: -math.pi / 2,
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kGiftBackground
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create S-curve shape
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    
    // Top curve
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.3,
    );
    
    // Bottom curve
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.1,
      size.width,
      size.height * 0.5,
    );
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 
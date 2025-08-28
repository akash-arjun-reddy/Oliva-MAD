import 'package:flutter/material.dart';
import '../../../features/authentication/presentation/pages/introduction_page.dart';
import '../../../features/dashboard/presentation/pages/main_dashboard.dart';
import '../../../services/session_service.dart';
import 'dart:async'; // Added for Timer

const Color kTextDark = Color(0xFF1A4D4A);
const Color kTealColor = Color(0xFF20B2AA); // Teal color for the logo

class OlivaSplashPage extends StatefulWidget {
  const OlivaSplashPage({Key? key}) : super(key: key);

  @override
  State<OlivaSplashPage> createState() => _OlivaSplashPageState();
}

class _OlivaSplashPageState extends State<OlivaSplashPage>
    with TickerProviderStateMixin {
  late AnimationController _zoomController;
  late AnimationController _logoController;
  bool _isLoading = false;
  late Animation<double> _zoomAnimation;
  late Animation<Alignment> _positionAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize zoom animation controller - optimized for speed
    _zoomController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Initialize logo animation controller
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Create zoom animation from 0.3 to 1.0 (small to full size)
    _zoomAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeOutCubic,
    ));

    // Create position animation from bottom to center, but positioned lower
    _positionAnimation = Tween<Alignment>(
      begin: const Alignment(0.0, 1.0), // Bottom center
      end: const Alignment(0.0, 0.7), // Positioned much lower to eliminate gap
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeOutCubic,
    ));

    // Create logo opacity animation - fade in and blend
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.85, // More transparent for better blending
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // Create logo scale animation - subtle zoom effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Start the animations
    _zoomController.forward();
    _logoController.forward();

    // Check session and navigate after 2 seconds (much faster)
    Timer(const Duration(seconds: 2), () async {
      if (mounted) {
        try {
          // Show loading indicator
          setState(() {
            _isLoading = true;
          });
          
          // Check if user should stay logged in
          final shouldStayLoggedIn = await SessionService.shouldStayLoggedIn();
          
          if (shouldStayLoggedIn) {
            // User is already logged in, go to main app
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainDashboard()),
            );
          } else {
            // User needs to login, go to introduction
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const IntroductionPage()),
            );
          }
        } catch (e) {
          // If there's an error, go to introduction page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const IntroductionPage()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE1F5FE), // Colors.lightBlue[50] - Very light blue
              Color(0xFFB3E5FC), // Colors.lightBlue[100] - Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section with animated logo
              SizedBox(
                height: 200, // Smaller container for medium logo
                child: AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40.0), // Less padding for better positioning
                      child: Center(
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: Image.asset(
                              'assets/images/oliva_logo.png',
                              height: 120, // Medium-small size with wow factor
                              fit: BoxFit.contain,
                              color: kTealColor.withOpacity(1.0), // Full opacity for maximum clarity
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom section with animated girl image - positioned at the very bottom
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.bottomCenter, // Position at the very bottom
                  child: AnimatedBuilder(
                    animation: _zoomController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _zoomAnimation.value,
                        child: Container(
                          width: double.infinity,
                          height: 400, // Increased height to show full face
                          margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Image.asset(
                            'assets/images/girl_1.png',
                            fit: BoxFit.contain, // Changed back to contain to show full image
                            alignment: Alignment.bottomCenter, // Align to bottom of image
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Loading indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kTealColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

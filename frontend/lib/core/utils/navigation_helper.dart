import 'package:flutter/material.dart';
import '../../../features/shop/presentation/pages/shop_page.dart';
import '../../../features/consultation/presentation/pages/consultation_type_page.dart';
import '../../../features/dashboard/presentation/pages/explore_screen.dart';

/// Global navigation helper for managing tab navigation
class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Navigate to a specific tab in the bottom navigation
  static void navigateToTab(BuildContext context, int tabIndex) {
    // Pop all routes until we reach the main dashboard
    Navigator.of(context).popUntil((route) {
      return route.isFirst || route.settings.name == '/';
    });
    
    // Use a post-frame callback to ensure navigation happens after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerTabNavigation(context, tabIndex);
    });
  }
  
  /// Trigger tab navigation by simulating a tap on the bottom navigation
  static void _triggerTabNavigation(BuildContext context, int tabIndex) {
    // Find the NewDashboardPage and update its selected index
    final navigator = Navigator.of(context);
    
    // Navigate to the appropriate screen based on tab index
    switch (tabIndex) {
      case 0: // Home
        // Already on home, do nothing
        break;
      case 1: // Shop
        navigator.push(
          MaterialPageRoute(
            builder: (context) => const ShopPage(),
          ),
        );
        break;
      case 2: // Consult
        navigator.push(
          MaterialPageRoute(
            builder: (context) => const ConsultationTypePage(),
          ),
        );
        break;
      case 3: // Scan
        // TODO: Navigate to Scan page when implemented
        break;
      case 4: // Explore
        navigator.push(
          MaterialPageRoute(
            builder: (context) => ExploreScreen(),
          ),
        );
        break;
    }
  }
  
  /// Navigate to Explore tab specifically
  static void navigateToExplore(BuildContext context) {
    navigateToTab(context, 4);
  }
  
  /// Navigate to Shop tab specifically
  static void navigateToShop(BuildContext context) {
    navigateToTab(context, 1);
  }
  
  /// Navigate to Consult tab specifically
  static void navigateToConsult(BuildContext context) {
    navigateToTab(context, 2);
  }
}

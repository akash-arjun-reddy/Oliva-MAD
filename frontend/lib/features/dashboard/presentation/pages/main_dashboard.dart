import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'home_page.dart';
import '../../../consultation/presentation/pages/doctor_selection_page.dart';
import '../../../consultation/presentation/pages/appointments_page.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const DoctorSelectionPage(),
    const AppointmentsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oliva Clinic'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle floating action button press
        },
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.bug_report,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
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
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.shopping_bag, 'Shop', 1),
                _buildNavItem(Icons.favorite, 'Consult', 2),
                _buildNavItem(Icons.medical_services, 'Doctors', 3),
                _buildNavItem(Icons.grid_view, 'Explore', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
                await authService.logout();
                // The AuthWrapper will automatically navigate to login page
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

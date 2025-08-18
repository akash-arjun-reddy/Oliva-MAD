import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import '../../../consultation/routes/consultation_routes.dart';
import '../../../dashboard/presentation/pages/main_dashboard.dart';

class ConsultationTypePage extends StatefulWidget {
  const ConsultationTypePage({Key? key}) : super(key: key);

  @override
  State<ConsultationTypePage> createState() => _ConsultationTypePageState();
}

class _ConsultationTypePageState extends State<ConsultationTypePage> {
  ConsultationType _selectedType = ConsultationType.online;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Choose Consultation Type',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'How would you like to consult?',
                    style: AppTextStyles.heading.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose between online video consultation or visit our clinic for in-person consultation.',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Consultation Type Selection
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Online Consultation Card
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = ConsultationType.online;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: _selectedType == ConsultationType.online
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedType == ConsultationType.online
                                ? AppColors.primary
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _selectedType == ConsultationType.online
                                    ? AppColors.primary
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.video_call,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Online Consultation',
                                    style: AppTextStyles.subheading.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedType == ConsultationType.online
                                          ? AppColors.primary
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Video call from anywhere',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedType == ConsultationType.online)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Offline Consultation Card
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = ConsultationType.offline;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: _selectedType == ConsultationType.offline
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedType == ConsultationType.offline
                                ? AppColors.primary
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _selectedType == ConsultationType.offline
                                    ? AppColors.primary
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Offline Consultation',
                                    style: AppTextStyles.subheading.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedType == ConsultationType.offline
                                          ? AppColors.primary
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Visit our clinic',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedType == ConsultationType.offline)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedType == ConsultationType.online) {
                            _showOnlineConsultation(context);
                          } else {
                            _showOfflineConsultation(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOnlineConsultation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOnlineConsultation(),
    );
  }

  void _showOfflineConsultation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOfflineConsultation(),
    );
  }

  Widget _buildOnlineConsultation() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.video_call,
                color: AppColors.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Online Consultation',
              style: AppTextStyles.heading.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connect with our experts via video call for personalized consultation from the comfort of your home.',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainDashboard(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Book Online Consultation',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineConsultation() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Offline Consultation',
              style: AppTextStyles.heading.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Visit our nearest clinic for in-person consultation with our experienced doctors.',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainDashboard(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Find Nearest Clinic',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ConsultationType {
  online,
  offline,
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class EmailTemplates {
  /// Appointment Confirmation Email Template
  static Widget buildAppointmentConfirmationEmail({
    required String patientName,
    required String appointmentDate,
    required String appointmentTime,
    required String doctorName,
    required String concern,
    required String meetingLink,
    required String passcode,
    required VoidCallback onJoinMeeting,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Header
          _buildEmailHeader(),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    'Dear $patientName,',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your appointment has been confirmed successfully!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Appointment Details Card
                  _buildAppointmentDetailsCard(
                    appointmentDate: appointmentDate,
                    appointmentTime: appointmentTime,
                    doctorName: doctorName,
                    concern: concern,
                    meetingLink: meetingLink,
                    passcode: passcode,
                  ),
                  const SizedBox(height: 24),
                  
                  // Instructions Section
                  _buildInstructionsSection(),
                  const SizedBox(height: 24),
                  
                  // Tips Section
                  _buildTipsSection(),
                  const SizedBox(height: 24),
                  
                  // Join Meeting Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onJoinMeeting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Join Meeting',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign off
                  Text(
                    'Best regards,',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Oliva Skin & Hair Clinic',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This email contains a calendar invite for your convenience.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  /// Meeting Invitation Email Template
  static Widget buildMeetingInvitationEmail({
    required String patientName,
    required String doctorName,
    required String meetingLink,
    required String passcode,
    required VoidCallback onJoinMeeting,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Header
          _buildEmailHeader(),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meeting Link Section
                  _buildMeetingLinkSection(
                    meetingLink: meetingLink,
                    passcode: passcode,
                  ),
                  const SizedBox(height: 24),
                  
                  // Instructions Section
                  _buildInstructionsSection(),
                  const SizedBox(height: 24),
                  
                  // Tips Section
                  _buildTipsSection(),
                  const SizedBox(height: 24),
                  
                  // Important Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Note:',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'If you need to reschedule or cancel, please contact us at least 24 hours in advance.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Join Meeting Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onJoinMeeting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Join Meeting',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign off
                  Text(
                    'Best regards,',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Oliva Skin & Hair Clinic',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This email contains a calendar invite for your convenience.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  /// Email Header with navigation icons
  static Widget _buildEmailHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back),
            iconSize: 24,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download),
            iconSize: 20,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline),
            iconSize: 20,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.archive),
            iconSize: 20,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  /// Appointment Details Card
  static Widget _buildAppointmentDetailsCard({
    required String appointmentDate,
    required String appointmentTime,
    required String doctorName,
    required String concern,
    required String meetingLink,
    required String passcode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Appointment Details',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Date', appointmentDate),
          _buildDetailRow('Time', appointmentTime),
          _buildDetailRow('Doctor', doctorName),
          _buildDetailRow('Concern', concern),
          _buildDetailRow('Meeting Link', meetingLink, isLink: true),
          _buildDetailRow('Passcode', passcode),
        ],
      ),
    );
  }

  /// Meeting Link Section
  static Widget _buildMeetingLinkSection({
    required String meetingLink,
    required String passcode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meeting Link:',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _launchUrl(meetingLink),
          child: Text(
            meetingLink,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Passcode: $passcode',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  /// Instructions Section
  static Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.assignment,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Instructions',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildNumberedInstruction(
          1,
          'Click the meeting link 5 minutes before your appointment',
        ),
        _buildNumberedInstruction(
          2,
          'Allow camera and microphone access when prompted',
        ),
        _buildNumberedInstruction(
          3,
          'Wait for the doctor to join the call',
        ),
      ],
    );
  }

  /// Tips Section
  static Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tips for the best experience',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTipItem('Use a stable internet connection'),
        _buildTipItem('Test your camera and microphone before joining'),
        _buildTipItem('Find a quiet, well-lit location'),
        _buildTipItem('Have your medical history ready if needed'),
      ],
    );
  }

  /// Bottom Navigation Bar
  static Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.reply),
              label: const Text('Reply'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.forward),
              label: const Text('Forward'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.emoji_emotions_outlined),
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  /// Helper method to build detail rows
  static Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: isLink
                ? GestureDetector(
                    onTap: () => _launchUrl(value),
                    child: Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: AppTextStyles.bodyMedium,
                  ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build numbered instructions
  static Widget _buildNumberedInstruction(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build tip items
  static Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to launch URLs
  static Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}


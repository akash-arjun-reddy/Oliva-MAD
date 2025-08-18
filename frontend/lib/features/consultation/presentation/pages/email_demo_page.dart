import 'package:flutter/material.dart';
import '../widgets/email_templates.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class EmailDemoPage extends StatefulWidget {
  const EmailDemoPage({super.key});

  @override
  State<EmailDemoPage> createState() => _EmailDemoPageState();
}

class _EmailDemoPageState extends State<EmailDemoPage> {
  int _selectedEmailType = 0;

  final List<String> _emailTypes = [
    'Appointment Confirmation',
    'Meeting Invitation',
  ];

  void _onJoinMeeting() {
    // Simulate joining meeting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening meeting link...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Templates Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedEmailType = _emailTypes.indexOf(value);
              });
            },
            itemBuilder: (context) => _emailTypes
                .map((type) => PopupMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Email Type Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Email Type: ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _emailTypes[_selectedEmailType],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedEmailType = (_selectedEmailType + 1) % _emailTypes.length;
                    });
                  },
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Switch Email Type',
                ),
              ],
            ),
          ),
          
          // Email Content
          Expanded(
            child: _buildEmailContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailContent() {
    switch (_selectedEmailType) {
      case 0:
        return EmailTemplates.buildAppointmentConfirmationEmail(
          patientName: 'John Doe',
          appointmentDate: 'January 15, 2025',
          appointmentTime: '10:00 AM',
          doctorName: 'Dr. Mythree Koyyana',
          concern: 'Skin consultation',
          meetingLink: 'https://meet.jit.si/Oliva_Mythree_Koyyana_John_Doe_20250808_093930_38jm5y',
          passcode: 'IVZ5ZT',
          onJoinMeeting: _onJoinMeeting,
        );
      case 1:
        return EmailTemplates.buildMeetingInvitationEmail(
          patientName: 'John Doe',
          doctorName: 'Dr. Mythree Koyyana',
          meetingLink: 'https://meet.jit.si/Oliva_Mythree_Koyyana_John_Doe_20250808_093930_38jm5y',
          passcode: 'IVZ5ZT',
          onJoinMeeting: _onJoinMeeting,
        );
      default:
        return const Center(
          child: Text('Select an email type'),
        );
    }
  }
}


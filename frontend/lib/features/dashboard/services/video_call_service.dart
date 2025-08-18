import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class VideoCallService {
  static Future<void> joinVideoCall(String videoCallLink, BuildContext context) async {
    try {
      final Uri url = Uri.parse(videoCallLink);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Show error dialog if URL cannot be launched
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Unable to open video call link. Please check your internet connection.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to join video call: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  static Future<void> joinVideoCallWithConfirmation(String videoCallLink, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Video Call'),
          content: const Text('Are you sure you want to join the video consultation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                joinVideoCall(videoCallLink, context);
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }
} 
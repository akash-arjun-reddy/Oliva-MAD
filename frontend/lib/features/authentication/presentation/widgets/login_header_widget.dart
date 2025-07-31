import 'package:flutter/material.dart';

class LoginHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAsset;

  const LoginHeaderWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Column(
      children: [
        // Top image with rounded top corners and proper alignment
        Container(
          width: double.infinity,
          height: screenHeight * 0.35,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              imageAsset,
              width: double.infinity,
              height: screenHeight * 0.35,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 
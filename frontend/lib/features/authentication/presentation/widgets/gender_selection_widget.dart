import 'package:flutter/material.dart';

class GenderSelectionWidget extends StatelessWidget {
  final String gender;
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderSelectionWidget({
    Key? key,
    required this.gender,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFF00BFAE) : Colors.black26,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(40),
              color: Colors.white,
            ),
            child: Image.asset(
              assetPath,
              width: 48,
              height: 48,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            gender,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00BFAE) : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 
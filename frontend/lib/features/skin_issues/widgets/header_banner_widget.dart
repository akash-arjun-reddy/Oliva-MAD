import 'package:flutter/material.dart';

class HeaderBannerWidget extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;

  const HeaderBannerWidget({
    Key? key,
    required this.title,
    this.backgroundColor = const Color(0xFF38A89E),
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';

class CurvedImageWidget extends StatelessWidget {
  final String imageAsset;
  final double height;
  final Color? overlayColor;

  const CurvedImageWidget({
    Key? key,
    required this.imageAsset,
    this.height = 0.5,
    this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return SizedBox(
      height: screenHeight * height,
      child: ClipPath(
        clipper: _BottomCurveClipper(),
        child: Stack(
          children: [
            Image.asset(
              imageAsset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            if (overlayColor != null)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: overlayColor!.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
} 
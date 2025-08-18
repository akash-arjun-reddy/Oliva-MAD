import 'package:flutter/material.dart';

class NearbyClinicPopupPage extends StatelessWidget {
  const NearbyClinicPopupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Nearby Clinic Popup'),
      ),
    );
  }
}

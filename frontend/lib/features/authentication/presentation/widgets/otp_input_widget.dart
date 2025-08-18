import 'package:flutter/material.dart';

class OtpInputWidget extends StatelessWidget {
  final List<TextEditingController> controllers;
  final FocusNode focusNode;
  final Function(int, String) onOtpChanged;
  final int otpLength;

  const OtpInputWidget({
    Key? key,
    required this.controllers,
    required this.focusNode,
    required this.onOtpChanged,
    this.otpLength = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(otpLength, (idx) {
          return Container(
            width: 40,
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: controllers[idx],
              focusNode: idx == 0 ? focusNode : null,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00BFAE), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                onOtpChanged(idx, value);
              },
            ),
          );
        }),
      ),
    );
  }
} 
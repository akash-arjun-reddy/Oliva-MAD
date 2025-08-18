import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class TealPhoneInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String hintText;
  final Color borderColor;

  const TealPhoneInputWidget({
    Key? key,
    required this.controller,
    this.onChanged,
    this.validator,
    this.hintText = 'Phone number',
    this.borderColor = const Color(0xFF00BFAE),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16, color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
      ),
      initialCountryCode: 'IN',
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      dropdownTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      onChanged: onChanged,
      validator: validator ?? (value) {
        if (value == null || value.number.isEmpty) {
          return 'Enter phone number';
        }
        return null;
      },
    );
  }
} 
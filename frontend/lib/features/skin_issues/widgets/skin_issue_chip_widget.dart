import 'package:flutter/material.dart';

class SkinIssueChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final Color selectedColor;
  final Color backgroundColor;

  const SkinIssueChipWidget({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.selectedColor = const Color(0xFF00B2B8),
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      selected: isSelected,
      selectedColor: selectedColor,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isSelected ? selectedColor : Colors.black26,
          width: 1.2,
        ),
      ),
      onSelected: onSelected,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    );
  }
} 
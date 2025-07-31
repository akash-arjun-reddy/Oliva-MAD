import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSlotsWidget extends StatelessWidget {
  final List<String> timeSlots;
  final int? selectedSlotIndex;
  final Function(int) onSlotSelected;

  const TimeSlotsWidget({
    Key? key,
    required this.timeSlots,
    this.selectedSlotIndex,
    required this.onSlotSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Time Slots',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final isSelected = selectedSlotIndex == index;
            return GestureDetector(
              onTap: () => onSlotSelected(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1766A0)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1766A0)
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    timeSlots[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 
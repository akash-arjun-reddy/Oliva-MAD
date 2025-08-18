import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime currentMonth;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;

  const CalendarWidget({
    Key? key,
    required this.selectedDate,
    required this.currentMonth,
    required this.onDateSelected,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _currentMonth = widget.currentMonth;
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedDate = widget.selectedDate;
    _currentMonth = widget.currentMonth;
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];
    
    // Add days from previous month to fill first week
    final firstWeekday = firstDay.weekday;
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }
    
    // Add days of current month
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    
    // Add days from next month to fill last week
    final lastWeekday = lastDay.weekday;
    for (int i = 1; i <= 7 - lastWeekday; i++) {
      days.add(lastDay.add(Duration(days: i)));
    }
    
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    final currentMonth = DateTime(_currentMonth.year, _currentMonth.month);
    
    return Column(
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final newMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                setState(() {
                  _currentMonth = newMonth;
                });
                widget.onMonthChanged(newMonth);
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(_currentMonth),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final newMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                setState(() {
                  _currentMonth = newMonth;
                });
                widget.onMonthChanged(newMonth);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Weekday headers
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isCurrentMonth = day.month == currentMonth.month;
            final isSelected = day.year == _selectedDate.year &&
                day.month == _selectedDate.month &&
                day.day == _selectedDate.day;
            final isToday = day.year == DateTime.now().year &&
                day.month == DateTime.now().month &&
                day.day == DateTime.now().day;

            return GestureDetector(
              onTap: () {
                if (isCurrentMonth) {
                  setState(() {
                    _selectedDate = day;
                  });
                  widget.onDateSelected(day);
                }
              },
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1766A0)
                      : isToday
                          ? const Color(0xFF1766A0).withOpacity(0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : isCurrentMonth
                              ? Colors.black
                              : Colors.grey,
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
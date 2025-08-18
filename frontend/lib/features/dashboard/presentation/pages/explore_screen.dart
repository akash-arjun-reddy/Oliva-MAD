import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as Math;

// Placeholder confirmation page
class ConfirmAppointmentPage extends StatelessWidget {
  final DateTime selectedDateTime;
  final String selectedTime;
  const ConfirmAppointmentPage({
    required this.selectedDateTime,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top curvy section with image
          ClipPath(
            clipper: CurvedBottomClipper(),
            child: Container(
              height: size.height * 0.42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3CB371), Color(0xFF1766A0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                    'assets/images/doctor.jpg',
                  ), // Replace with your image
                ),
              ),
            ),
          ),
          // Bottom details section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 48),
                  Text(
                    'Appointment Confirmed!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Date: ${DateFormat('EEE, MMM d, yyyy').format(selectedDateTime)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text('Time: ${selectedTime}', style: TextStyle(fontSize: 16)),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        'Book Appointment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Color(0xFF1766A0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  DateTime _selectedDateTime = DateTime.now();
  int? _selectedSlotIndex;
  DateTime _calendarMonth = DateTime.now();

  List<String> get _timeSlots {
    final slots = <String>[];
    final start = DateTime(0, 0, 0, 8, 0);
    final end = DateTime(0, 0, 0, 20, 0);
    var current = start;
    while (!current.isAfter(end)) {
      slots.add(DateFormat.jm().format(current));
      current = current.add(Duration(minutes: 15));
    }
    return slots;
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
      _selectedSlotIndex = null;
    });
  }

  void _onSlotSelected(int index) {
    final slotTime = _timeSlots[index];

    final parsed = DateFormat.jm().parse(slotTime);
    setState(() {
      _selectedSlotIndex = index;
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        parsed.hour,
        parsed.minute,
      );
    });
  }

  void _onTodayPressed() {
    final today = DateTime.now();
    setState(() {
      _selectedDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
      _selectedSlotIndex = null;
    });
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _calendarMonth = newMonth;
      // Optionally reset selected date to first of month or keep as is
      if (_selectedDateTime.year != newMonth.year ||
          _selectedDateTime.month != newMonth.month) {
        _selectedDateTime = DateTime(newMonth.year, newMonth.month, 1);
        _selectedSlotIndex = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final purple = Color(0xFF7C4DFF);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Bar
            _TopBar(
              selectedDate: _selectedDateTime,
              selectedSlotIndex: _selectedSlotIndex,
              timeSlots: _timeSlots,
              onTodayPressed: _onTodayPressed,
            ),
            // Scrollable content below
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 0, bottom: 24),
                children: [
                  // Month Calendar
                  _MonthCalendar(
                    selectedDate: _selectedDateTime,
                    onDateChanged: _onDateChanged,
                    onMonthChanged: _onMonthChanged,
                  ),
                  // Move Time Slots label and grid closer to calendar
                  SizedBox(height: 12),
                  // Floating selected slot (if any)
                  if (_selectedSlotIndex != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 18,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3CB371), Color(0xFF1766A0)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1766A0).withOpacity(0.18),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Selected: ${DateFormat('EEE, MMM d').format(_selectedDateTime)} at ${_timeSlots[_selectedSlotIndex!]}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ConfirmAppointmentPage(
                                          selectedDateTime: _selectedDateTime,
                                          selectedTime:
                                              _timeSlots[_selectedSlotIndex!],
                                        ),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Time Slots',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  // Time slots as a grid (2 columns)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: _timeSlots.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedSlotIndex == index;
                        // Gradient palette for unselected slots
                        final gradients = [
                          [Color(0xFFFFB6B9), Color(0xFFFAE3D9)], // pink
                          [Color(0xFFA18CD1), Color(0xFFFBC2EB)], // purple
                          [Color(0xFFA1C4FD), Color(0xFFC2E9FB)], // blue
                          [Color(0xFFFBC2EB), Color(0xFFA6C1EE)], // peach
                          [
                            Color(0xFFD4FC79),
                            Color(0xFF96E6A1),
                          ], // lavender/green
                          [
                            Color(0xFFFFDEE9),
                            Color(0xFFB5FFFC),
                          ], // light pink/blue
                        ];
                        final gradient = gradients[index % gradients.length];
                        return GestureDetector(
                          onTap: () => _onSlotSelected(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        Color(0xFF3CB371),
                                        Color(0xFF1766A0),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    )
                                  : LinearGradient(
                                      colors: gradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              color: isSelected ? null : null,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFF1766A0)
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(
                                          0xFF1766A0,
                                        ).withOpacity(0.18),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _timeSlots[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialClockPicker extends StatelessWidget {
  final int hour;
  final int minute;
  final bool isPm;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final ValueChanged<bool> onAmPmChanged;
  final Color accentColor;
  const _MaterialClockPicker({
    required this.hour,
    required this.minute,
    required this.isPm,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onAmPmChanged,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Time display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$hour',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            Text(':', style: TextStyle(fontSize: 32, color: accentColor)),
            Text(
              minute.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: CircleBorder(),
                padding: EdgeInsets.all(8),
                elevation: 0,
              ),
              onPressed: () => onAmPmChanged(!isPm),
              child: Text(
                isPm ? 'PM' : 'AM',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        // Clock face
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Clock circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.12),
                ),
              ),
              // Minute marks
              ...List.generate(12, (i) {
                final angle = (i * 30.0 - 90) * Math.pi / 180;
                final x = 60 * Math.cos(angle);
                final y = 60 * Math.sin(angle);
                return Positioned(
                  left: 70 + x - 10,
                  top: 70 + y - 10,
                  child: Text(
                    '${i * 5}',
                    style: TextStyle(
                      color: accentColor.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
              // Clock hand
              Transform.rotate(
                angle: ((minute / 60) * 2 * Math.pi) - Math.pi / 2,
                child: Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Center dot
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              // Minute drag gesture
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  final local = (context.findRenderObject() as RenderBox?)
                      ?.globalToLocal(details.globalPosition);
                  if (local != null) {
                    final dx = local.dx - 70;
                    final dy = local.dy - 70;
                    final angle = Math.atan2(dy, dx);
                    int newMinute =
                        ((angle + Math.pi / 2) / (2 * Math.pi) * 60).round() %
                        60;
                    if (newMinute < 0) newMinute += 60;
                    onMinuteChanged(newMinute);
                  }
                },
                child: Container(
                  width: 140,
                  height: 140,
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Hour selection
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: List.generate(12, (i) {
            final h = i + 1;
            return ChoiceChip(
              label: Text(h.toString()),
              selected: hour == h,
              selectedColor: accentColor,
              labelStyle: TextStyle(
                color: hour == h ? Colors.white : accentColor,
              ),
              onSelected: (_) => onHourChanged(
                isPm ? (h == 12 ? 12 : h + 12) : (h == 12 ? 0 : h),
              ),
              backgroundColor: accentColor.withOpacity(0.08),
            );
          }),
        ),
      ],
    );
  }
}

class _InlineMonthDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final double iconSize;
  final double fontSize;
  const _InlineMonthDatePicker({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.iconSize,
    required this.fontSize,
  }) : super(key: key);

  List<DateTime> _getMonthDaysFromToday(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(date.year, date.month, i + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _getMonthDaysFromToday(selectedDate);
    const accentColor = Color(0xFF1766A0);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: days.length,
      itemBuilder: (context, idx) {
        final date = days[idx];
        final isSelected =
            date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
        return GestureDetector(
          onTap: () => onDateChanged(date),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date).substring(0, 1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? accentColor : Colors.grey,
                    fontSize: fontSize,
                  ),
                ),
                SizedBox(height: 2),
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.transparent,
                    border: Border.all(color: accentColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : accentColor,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnalogClock extends StatelessWidget {
  final int hour;
  final int minute;
  final bool isPm;
  final Color accentColor;
  final double size;
  const _AnalogClock({
    Key? key,
    required this.hour,
    required this.minute,
    required this.isPm,
    required this.accentColor,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double center = size / 2;
    final double radius = size / 2 - 16;
    final hourAngle =
        ((hour % 12 + minute / 60) * 30 - 90) * 3.1415926535 / 180;
    final minuteAngle = (minute * 6 - 90) * 3.1415926535 / 180;
    return Container(
      width: size,
      height: size + 40,
      child: Column(
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${hour % 12 == 0 ? 12 : hour % 12}:${minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isPm ? 'PM' : 'AM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _ClockPainter(
                hourAngle: hourAngle,
                minuteAngle: minuteAngle,
                accentColor: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;
  final Color accentColor;
  _ClockPainter({
    required this.hourAngle,
    required this.minuteAngle,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    final paintCircle = Paint()
      ..color = Color(0xFFF3EFFF)
      ..style = PaintingStyle.fill;
    final paintBorder = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final paintHour = Paint()
      ..color = accentColor
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final paintMinute = Paint()
      ..color = accentColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    // Draw clock face
    canvas.drawCircle(center, radius, paintCircle);
    canvas.drawCircle(center, radius, paintBorder);
    // Draw hour hand
    final hourHand = Offset(
      center.dx + 0.5 * radius * Math.cos(hourAngle),
      center.dy + 0.5 * radius * Math.sin(hourAngle),
    );
    canvas.drawLine(center, hourHand, paintHour);
    // Draw minute hand
    final minuteHand = Offset(
      center.dx + 0.8 * radius * Math.cos(minuteAngle),
      center.dy + 0.8 * radius * Math.sin(minuteAngle),
    );
    canvas.drawLine(center, minuteHand, paintMinute);
    // Draw center dot
    canvas.drawCircle(center, 8, paintHour);
    // Draw hour marks
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * 3.1415926535 / 180;
      final p1 = Offset(
        center.dx + 0.85 * radius * Math.cos(angle),
        center.dy + 0.85 * radius * Math.sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * Math.cos(angle),
        center.dy + radius * Math.sin(angle),
      );
      canvas.drawLine(p1, p2, paintBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Top Bar Widget
class _TopBar extends StatelessWidget {
  final DateTime selectedDate;
  final int? selectedSlotIndex;
  final List<String> timeSlots;
  final VoidCallback onTodayPressed;

  const _TopBar({
    required this.selectedDate,
    required this.selectedSlotIndex,
    required this.timeSlots,
    required this.onTodayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;
    return ClipPath(
      clipper: CurvedBottomClipper(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.only(
          top: 18,
          left: 18,
          right: 18,
          bottom: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d').format(selectedDate),
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${DateFormat('EEE').format(selectedDate)}  ${DateFormat('MMM yyyy').format(selectedDate)}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Spacer(),
            selectedSlotIndex == null
                ? GestureDetector(
                    onTap: onTodayPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isToday ? Color(0xFFD6F5E6) : Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color: isToday ? Color(0xFF3CB371) : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3CB371), Color(0xFF1766A0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      timeSlots[selectedSlotIndex!],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20, // control point
      size.width,
      size.height - 20, // end point
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Month Calendar Widget
class _MonthCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final void Function(DateTime)? onMonthChanged;
  const _MonthCalendar({
    required this.selectedDate,
    required this.onDateChanged,
    this.onMonthChanged,
  });

  List<List<DateTime?>> _monthGrid(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;
    List<List<DateTime?>> grid = [];
    int day = 1 - (firstWeekday - 1);
    for (int w = 0; w < 6; w++) {
      List<DateTime?> week = [];
      for (int d = 0; d < 7; d++) {
        if (day > 0 && day <= daysInMonth) {
          week.add(DateTime(month.year, month.month, day));
        } else {
          week.add(null);
        }
        day++;
      }
      grid.add(week);
    }
    return grid;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final grid = _monthGrid(selectedDate);
    // Month navigation logic
    void goToPrevMonth() {
      final prev = DateTime(selectedDate.year, selectedDate.month - 1, 1);
      if (onMonthChanged != null) onMonthChanged!(prev);
    }

    void goToNextMonth() {
      final next = DateTime(selectedDate.year, selectedDate.month + 1, 1);
      if (onMonthChanged != null) onMonthChanged!(next);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [Color(0xFFF8FFFC), Color(0xFFE0F7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, size: 28),
                onPressed: goToPrevMonth,
              ),
              Text(
                '${selectedDate.year} - ${selectedDate.month.toString().padLeft(2, '0')}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 28),
                onPressed: goToNextMonth,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 8),
          // Month grid
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: grid.map((week) {
              return TableRow(
                children: week.map((date) {
                  final isSelected =
                      date != null &&
                      date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;
                  final isToday =
                      date != null &&
                      date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                  return GestureDetector(
                    onTap: date == null ? null : () => onDateChanged(date),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xFFFF835C)
                              : isToday
                              ? Color(0xFFD6F5E6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          date?.day.toString() ?? '',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? Color(0xFF3CB371)
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

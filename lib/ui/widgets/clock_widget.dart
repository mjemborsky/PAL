import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/widget_config.dart';

class ClockWidget extends StatefulWidget {
  final StandbyWidgetConfig config;

  const ClockWidget({super.key, required this.config});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    final dayName = DateFormat('EEEE').format(_now).toUpperCase();
    final dateString = DateFormat('MMMM d, yyyy').format(_now);

    // DIGITAL DISPLAY
    if (!widget.config.isAnalog) {
      final timePattern = widget.config.use24HourTime
          ? (widget.config.showSeconds ? 'HH:mm:ss' : 'HH:mm')
          : (widget.config.showSeconds ? 'h:mm:ss' : 'h:mm');

      final timeString = DateFormat(timePattern).format(_now);
      final amPm =
          widget.config.use24HourTime ? '' : DateFormat('a').format(_now);

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: widget.config.showSeconds ? 86 : 108,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                    height: 1.0,
                  ),
                ),
                if (amPm.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text(
                    amPm,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
            if (widget.config.showCalendar) ...[
              const SizedBox(height: 16),
              Text(
                '$dayName, $dateString',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // ANALOG DISPLAY
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: _AnalogClockPainter(
                dateTime: _now,
                isDark: isDark,
                accentColor: theme.colorScheme.primary,
                showSeconds: widget.config.showSeconds,
              ),
            ),
          ),
          if (widget.config.showCalendar) ...[
            const SizedBox(width: 48),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateString,
                  style: TextStyle(
                    fontSize: 22,
                    color: primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime dateTime;
  final bool isDark;
  final Color accentColor;
  final bool showSeconds;

  _AnalogClockPainter({
    required this.dateTime,
    required this.isDark,
    required this.accentColor,
    required this.showSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final facePaint = Paint()
      ..color = isDark ? const Color(0xFF1E1E1E) : Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius, facePaint);
    canvas.drawCircle(center, radius, borderPaint);

    final tickPaint = Paint()
      ..color = isDark ? Colors.grey.shade600 : Colors.grey.shade400
      ..strokeWidth = 2.0;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final p1 = Offset(
        center.dx + (radius - 16) * math.cos(angle),
        center.dy + (radius - 16) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - 8) * math.cos(angle),
        center.dy + (radius - 8) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    final handColor = isDark ? Colors.white : Colors.black87;

    // Hour Hand
    final hourAngle =
        ((dateTime.hour % 12 + dateTime.minute / 60) * 30 - 90) * math.pi / 180;
    final hourHandPaint = Paint()
      ..color = handColor
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.45) * math.cos(hourAngle),
        center.dy + (radius * 0.45) * math.sin(hourAngle),
      ),
      hourHandPaint,
    );

    // Minute Hand
    final minuteAngle =
        ((dateTime.minute + dateTime.second / 60) * 6 - 90) * math.pi / 180;
    final minuteHandPaint = Paint()
      ..color = handColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.65) * math.cos(minuteAngle),
        center.dy + (radius * 0.65) * math.sin(minuteAngle),
      ),
      minuteHandPaint,
    );

    // Second Hand
    if (showSeconds) {
      final secondAngle = (dateTime.second * 6 - 90) * math.pi / 180;
      final secondHandPaint = Paint()
        ..color = accentColor
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center,
        Offset(
          center.dx + (radius * 0.8) * math.cos(secondAngle),
          center.dy + (radius * 0.8) * math.sin(secondAngle),
        ),
        secondHandPaint,
      );
    }

    final pinPaint = Paint()..color = accentColor;
    canvas.drawCircle(center, 5.0, pinPaint);
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) => true;
}

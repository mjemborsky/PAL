import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/widget_config.dart';

/// Clock Display with Analog & Digital modes optimized for 800x480
class ClockWidget extends StatelessWidget {
  final StandbyWidgetConfig config;

  const ClockWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        config.showSeconds
            ? const Duration(seconds: 1)
            : const Duration(seconds: 10),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();

        return Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Center(
            child: config.isAnalog
                ? _buildAnalogLayout(now)
                : _buildDigitalLayout(now),
          ),
        );
      },
    );
  }

  /// Analog Mode: Side-by-Side Row layout with optional calendar on the right
  Widget _buildAnalogLayout(DateTime now) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: _buildAnalogClockFace(now),
          ),
        ),
        if (config.showCalendar) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Center(
              child: _buildCalendarDisplay(now, isStacked: false),
            ),
          ),
        ],
      ],
    );
  }

  /// Digital Mode: Stacked Column layout with large time and left-aligned date below
  Widget _buildDigitalLayout(DateTime now) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDigitalClockFace(now),
        if (config.showCalendar) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: _buildCalendarDisplay(now, isStacked: true),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalogClockFace(DateTime now) {
    return SizedBox(
      width: 340,
      height: 340,
      child: CustomPaint(
        painter: AnalogClockPainter(
          now: now,
          showSeconds: config.showSeconds,
        ),
      ),
    );
  }

  Widget _buildDigitalClockFace(DateTime now) {
    final formatPattern = config.use24HourTime
        ? (config.showSeconds ? 'HH:mm:ss' : 'HH:mm')
        : (config.showSeconds ? 'hh:mm:ss' : 'hh:mm');

    final timeString = DateFormat(formatPattern).format(now);
    final periodString =
        config.use24HourTime ? '' : DateFormat('a').format(now);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          timeString,
          style: TextStyle(
            fontSize: config.showCalendar ? 120 : 140,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -2,
            height: 1.0,
          ),
        ),
        if (periodString.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(
            periodString,
            style: TextStyle(
              fontSize: config.showCalendar ? 38 : 44,
              fontWeight: FontWeight.w600,
              color: Colors.cyanAccent,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCalendarDisplay(DateTime now, {required bool isStacked}) {
    final dayOfWeek = DateFormat('EEEE').format(now);
    final fullDate = DateFormat('MMMM d, yyyy').format(now);

    if (isStacked) {
      // Left-aligned compact date under digital clock
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$dayOfWeek, $fullDate'.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.cyanAccent,
              letterSpacing: 1.5,
            ),
          ),
        ],
      );
    }

    // Detailed layout next to analog clock face
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dayOfWeek.toUpperCase(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          fullDate,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}

/// CustomPainter drawing the analog clock face
class AnalogClockPainter extends CustomPainter {
  final DateTime now;
  final bool showSeconds;

  AnalogClockPainter({required this.now, required this.showSeconds});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Dial Ring
    final dialPaint = Paint()
      ..color = Colors.grey.shade900
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, dialPaint);

    final borderPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Tick Marks
    final tickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 3.0;

    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * (pi / 180);
      final outerX = center.dx + radius * 0.90 * cos(angle);
      final outerY = center.dy + radius * 0.90 * sin(angle);
      final innerX = center.dx + radius * 0.80 * cos(angle);
      final innerY = center.dy + radius * 0.80 * sin(angle);
      canvas.drawLine(
          Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
    }

    // Hour Hand
    final hourAngle =
        ((now.hour % 12) + now.minute / 60) * 30 * (pi / 180) - (pi / 2);
    final hourHandPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.48 * cos(hourAngle),
          center.dy + radius * 0.48 * sin(hourAngle)),
      hourHandPaint,
    );

    // Minute Hand
    final minuteAngle =
        (now.minute + now.second / 60) * 6 * (pi / 180) - (pi / 2);
    final minuteHandPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.70 * cos(minuteAngle),
          center.dy + radius * 0.70 * sin(minuteAngle)),
      minuteHandPaint,
    );

    // Second Hand
    if (showSeconds) {
      final secondAngle = now.second * 6 * (pi / 180) - (pi / 2);
      final secondHandPaint = Paint()
        ..color = Colors.cyanAccent
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * 0.82 * cos(secondAngle),
            center.dy + radius * 0.82 * sin(secondAngle)),
        secondHandPaint,
      );
    }

    // Center Pivot Pin
    final centerPinPaint = Paint()..color = Colors.cyanAccent;
    canvas.drawCircle(center, 6.5, centerPinPaint);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) {
    return oldDelegate.now.second != now.second ||
        oldDelegate.showSeconds != showSeconds;
  }
}

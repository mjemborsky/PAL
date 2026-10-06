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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Center(
            child: config.showCalendar
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: config.isAnalog
                              ? _buildAnalogClockFace(now)
                              : _buildDigitalClockFace(now),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Center(
                          child: _buildCalendarDisplay(now),
                        ),
                      ),
                    ],
                  )
                : (config.isAnalog
                    ? _buildAnalogClockFace(now)
                    : _buildDigitalClockFace(now)),
          ),
        );
      },
    );
  }

  Widget _buildAnalogClockFace(DateTime now) {
    return SizedBox(
      width: 250,
      height: 250,
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          timeString,
          style: TextStyle(
            fontSize: config.showCalendar ? 68 : 96,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        if (periodString.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(
            periodString,
            style: TextStyle(
              fontSize: config.showCalendar ? 24 : 32,
              fontWeight: FontWeight.w600,
              color: Colors.cyanAccent,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCalendarDisplay(DateTime now) {
    final dayOfWeek = DateFormat('EEEE').format(now);
    final fullDate = DateFormat('MMMM d, yyyy').format(now);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dayOfWeek.toUpperCase(),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          fullDate,
          style: TextStyle(
            fontSize: 20,
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
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Tick Marks
    final tickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2.5;

    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * (pi / 180);
      final outerX = center.dx + radius * 0.88 * cos(angle);
      final outerY = center.dy + radius * 0.88 * sin(angle);
      final innerX = center.dx + radius * 0.78 * cos(angle);
      final innerY = center.dy + radius * 0.78 * sin(angle);
      canvas.drawLine(
          Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
    }

    // Hour Hand
    final hourAngle =
        ((now.hour % 12) + now.minute / 60) * 30 * (pi / 180) - (pi / 2);
    final hourHandPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.45 * cos(hourAngle),
          center.dy + radius * 0.45 * sin(hourAngle)),
      hourHandPaint,
    );

    // Minute Hand
    final minuteAngle =
        (now.minute + now.second / 60) * 6 * (pi / 180) - (pi / 2);
    final minuteHandPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.65 * cos(minuteAngle),
          center.dy + radius * 0.65 * sin(minuteAngle)),
      minuteHandPaint,
    );

    // Second Hand
    if (showSeconds) {
      final secondAngle = now.second * 6 * (pi / 180) - (pi / 2);
      final secondHandPaint = Paint()
        ..color = Colors.cyanAccent
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * 0.8 * cos(secondAngle),
            center.dy + radius * 0.8 * sin(secondAngle)),
        secondHandPaint,
      );
    }

    // Center Pivot Pin
    final centerPinPaint = Paint()..color = Colors.cyanAccent;
    canvas.drawCircle(center, 5, centerPinPaint);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) {
    return oldDelegate.now.second != now.second ||
        oldDelegate.showSeconds != showSeconds;
  }
}

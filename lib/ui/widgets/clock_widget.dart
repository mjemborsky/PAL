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
      stream:
          Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: config.isAnalog
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(
                          painter: AnalogClockPainter(
                              now: now, showSeconds: config.showSeconds),
                        ),
                      ),
                      const SizedBox(width: 48),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('hh:mm').format(now),
                            style: const TextStyle(
                              fontSize: 88,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat('EEEE, MMMM d').format(now),
                            style: TextStyle(
                                fontSize: 26, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ],
                  )
                : _buildDigitalClock(now),
          ),
        );
      },
    );
  }

  Widget _buildDigitalClock(DateTime now) {
    final formatPattern = config.use24HourTime
        ? (config.showSeconds ? 'HH:mm:ss' : 'HH:mm')
        : (config.showSeconds ? 'hh:mm:ss' : 'hh:mm');

    final timeString = DateFormat(formatPattern).format(now);
    final periodString =
        config.use24HourTime ? '' : DateFormat('a').format(now);
    final dateString = DateFormat('EEEE, MMMM d').format(now);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              timeString,
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -2,
              ),
            ),
            if (periodString.isNotEmpty) ...[
              const SizedBox(width: 16),
              Text(
                periodString,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.cyanAccent,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          dateString,
          style: TextStyle(
            fontSize: 28,
            letterSpacing: 1.5,
            color: Colors.grey.shade400,
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
      ..strokeWidth = 8
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
      ..strokeWidth = 5
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
        ..strokeWidth = 2.5
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
    canvas.drawCircle(center, 6, centerPinPaint);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) {
    return oldDelegate.now.second != now.second ||
        oldDelegate.showSeconds != showSeconds;
  }
}

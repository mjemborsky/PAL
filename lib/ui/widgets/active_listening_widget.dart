import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

class ActiveListeningWidget extends StatefulWidget {
  final ActiveListeningConfig config;

  const ActiveListeningWidget({super.key, required this.config});

  @override
  State<ActiveListeningWidget> createState() => _ActiveListeningWidgetState();
}

class _ActiveListeningWidgetState extends State<ActiveListeningWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (widget.config.style == ActiveListeningStyle.vinyl) {
          return _buildVinylView(_controller.value);
        }
        return _buildMilkdropView(_controller.value);
      },
    );
  }

  Widget _buildMilkdropView(double animValue) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _MilkdropPainter(
            animValue: animValue,
            sensitivity: widget.config.sensitivity,
          ),
        ),
        Positioned(
          left: 20,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.graphic_eq,
                      color: Colors.cyanAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'MILKDROP VISUALIZER',
                    style: TextStyle(
                      color: Colors.cyanAccent.withValues(alpha: 0.8),
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Hypnotic Ambient Stream',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (widget.config.showFPS)
          Positioned(
            top: 24,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '60 FPS',
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 10,
                    fontFamily: 'monospace'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVinylView(double animValue) {
    final rotationAngle =
        widget.config.rotateVinyl ? animValue * 2 * math.pi : 0.0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Centered Vinyl Disc for 720x720 layout
          Transform.rotate(
            angle: rotationAngle,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade900,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
                border: Border.all(color: Colors.white10, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.cyanAccent,
                    ),
                    child: const Icon(
                      Icons.album,
                      color: Colors.black87,
                      size: 48,
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Metadata block
          const Text(
            'Resonance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'HOME • Odyssey',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          if (widget.config.showProgressBar) ...[
            const SizedBox(height: 18),
            LinearProgressIndicator(
              value: (animValue * 3) % 1.0,
              backgroundColor: Colors.white12,
              color: Colors.cyanAccent,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1:42',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                Text('3:32',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MilkdropPainter extends CustomPainter {
  final double animValue;
  final double sensitivity;

  _MilkdropPainter({required this.animValue, required this.sensitivity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (int i = 0; i < 5; i++) {
      final progress = (animValue + (i * 0.2)) % 1.0;
      final currentRadius = radius * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      paint.color = HSVColor.fromAHSV(
        opacity,
        (animValue * 360 + (i * 40)) % 360,
        0.8,
        1.0,
      ).toColor();

      final path = Path();
      const points = 80;
      for (int j = 0; j <= points; j++) {
        final angle = (j / points) * 2 * math.pi;
        final distortion =
            math.sin(angle * 6 + animValue * 10 + i) * (12 * sensitivity);
        final r = currentRadius + distortion;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MilkdropPainter oldDelegate) => true;
}

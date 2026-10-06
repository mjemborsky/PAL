import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

class ActiveListeningWidget extends StatefulWidget {
  final ActiveListeningConfig config;
  final VoidCallback? onDismiss;
  final VoidCallback? onReveal;

  const ActiveListeningWidget({
    super.key,
    required this.config,
    this.onDismiss,
    this.onReveal,
  });

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

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (!widget.config.isEnabled) return;

    final velocityY = details.primaryVelocity ?? 0.0;
    const velocityThreshold = 200.0;

    // Direct swipe direction detection regardless of touch coordinates
    if (velocityY < -velocityThreshold) {
      // Swiped UP -> Hide visualizer
      widget.onDismiss?.call();
    } else if (velocityY > velocityThreshold) {
      // Swiped DOWN -> Show visualizer
      widget.onReveal?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (widget.config.style == ActiveListeningStyle.vinyl) {
            return _buildVinylView(_controller.value);
          }
          return _buildMilkdropView(_controller.value);
        },
      ),
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
          left: 32,
          bottom: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.graphic_eq,
                      color: Colors.cyanAccent, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'MILKDROP VISUALIZER',
                    style: TextStyle(
                      color: Colors.cyanAccent.withValues(alpha: 0.8),
                      fontSize: 14,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Hypnotic Ambient Stream',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (widget.config.showFPS)
          Positioned(
            top: 24,
            left: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '60 FPS',
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Column: Larger Vinyl Disc
          Expanded(
            flex: 5,
            child: Center(
              child: Transform.rotate(
                angle: rotationAngle,
                child: Container(
                  width: 310,
                  height: 310,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade900,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(color: Colors.white10, width: 3),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12, width: 1.5),
                        ),
                      ),
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12, width: 1.5),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyanAccent,
                        ),
                        child: const Icon(
                          Icons.album,
                          color: Colors.black87,
                          size: 60,
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 36),
          // Right Column: Scaled Track Details
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.music_note,
                        color: Colors.cyanAccent, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: Colors.cyanAccent.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Resonance',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'HOME • Odyssey',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.grey.shade400,
                  ),
                ),
                if (widget.config.showProgressBar) ...[
                  const SizedBox(height: 28),
                  LinearProgressIndicator(
                    value: (animValue * 3) % 1.0,
                    backgroundColor: Colors.white12,
                    color: Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1:42',
                          style: TextStyle(
                              fontSize: 15, color: Colors.grey.shade500)),
                      Text('3:32',
                          style: TextStyle(
                              fontSize: 15, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ],
            ),
          ),
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
    final radius = math.min(size.width, size.height) * 0.45;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

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
            math.sin(angle * 6 + animValue * 10 + i) * (14 * sensitivity);
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

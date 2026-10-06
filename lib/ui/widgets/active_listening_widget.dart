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

    if (velocityY < -velocityThreshold) {
      widget.onDismiss?.call();
    } else if (velocityY > velocityThreshold) {
      widget.onReveal?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? Colors.black : theme.scaffoldBackgroundColor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: _handleVerticalDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (widget.config.style == ActiveListeningStyle.vinyl) {
              return _buildVinylView(_controller.value, theme, isDark);
            }
            return _buildMilkdropView(_controller.value, theme, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildMilkdropView(double animValue, ThemeData theme, bool isDark) {
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _MilkdropPainter(
            animValue: animValue,
            sensitivity: widget.config.sensitivity,
            isDark: isDark,
            backgroundColor:
                isDark ? Colors.black : theme.scaffoldBackgroundColor,
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
                  Icon(Icons.graphic_eq,
                      color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'MILKDROP VISUALIZER',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Hypnotic Ambient Stream',
                style: TextStyle(
                  color: primaryTextColor,
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
                color: isDark
                    ? Colors.black54
                    : Colors.white.withValues(alpha: 0.87),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: const Text(
                '60 FPS',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVinylView(double animValue, ThemeData theme, bool isDark) {
    final rotationAngle =
        widget.config.rotateVinyl ? animValue * 2 * math.pi : 0.0;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade800,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                        width: 3),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                      ),
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
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
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.music_note,
                        color: theme.colorScheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Resonance',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'HOME • Odyssey',
                  style: TextStyle(
                    fontSize: 22,
                    color: subtitleColor,
                  ),
                ),
                if (widget.config.showProgressBar) ...[
                  const SizedBox(height: 28),
                  LinearProgressIndicator(
                    value: (animValue * 3) % 1.0,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1:42',
                          style: TextStyle(fontSize: 15, color: subtitleColor)),
                      Text('3:32',
                          style: TextStyle(fontSize: 15, color: subtitleColor)),
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
  final bool isDark;
  final Color backgroundColor;

  _MilkdropPainter({
    required this.animValue,
    required this.sensitivity,
    required this.isDark,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = backgroundColor,
    );

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
        isDark ? 0.8 : 0.9,
        isDark ? 1.0 : 0.7,
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

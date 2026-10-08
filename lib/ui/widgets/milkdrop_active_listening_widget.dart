import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/widget_config.dart';
import '../../../services/mock_playback_service.dart';

class MilkdropActiveListeningWidget extends StatefulWidget {
  final ActiveListeningConfig config;
  final VoidCallback? onDismiss;
  final VoidCallback? onReveal;

  const MilkdropActiveListeningWidget({
    super.key,
    required this.config,
    this.onDismiss,
    this.onReveal,
  });

  @override
  State<MilkdropActiveListeningWidget> createState() =>
      _MilkdropActiveListeningWidgetState();
}

class _MilkdropActiveListeningWidgetState
    extends State<MilkdropActiveListeningWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _visualizerController;

  @override
  void initState() {
    super.initState();
    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _visualizerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playbackService = context.watch<MockPlaybackService>();
    final currentTrack = playbackService.currentTrack;

    return ClipRect(
      child: Container(
        width: 800,
        height: 480,
        color: const Color(0xFF0A0A0C),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragEnd: (details) {
            final velocityY = details.primaryVelocity ?? 0.0;
            if (velocityY < -200) widget.onDismiss?.call();
            if (velocityY > 200) widget.onReveal?.call();
          },
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Visualizer Canvas Layer
              Positioned.fill(
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _visualizerController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _MilkdropPlaceholderPainter(
                          progress: _visualizerController.value,
                          isPlaying: playbackService.isPlaying,
                          sensitivity: widget.config.sensitivity,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Minimalist Overlay Metadata Banner
              Positioned(
                left: 24,
                bottom: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.equalizer, color: Colors.cyanAccent),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentTrack.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currentTrack.artist,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Optional FPS Counter Overlay
              if (widget.config.showFPS)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '60 FPS',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MilkdropPlaceholderPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final double sensitivity;

  _MilkdropPlaceholderPainter({
    required this.progress,
    required this.isPlaying,
    required this.sensitivity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Restrict all canvas painting operations strictly to widget bounds
    canvas.clipRect(Offset.zero & size);

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) * sensitivity;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 5; i++) {
      final radius = ((progress + (i * 0.2)) % 1.0) * maxRadius;
      paint.color = HSVColor.fromAHSV(
        (1.0 - (radius / maxRadius)).clamp(0.0, 1.0),
        (progress * 360 + (i * 60)) % 360,
        0.8,
        0.9,
      ).toColor();

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MilkdropPlaceholderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.sensitivity != sensitivity;
  }
}

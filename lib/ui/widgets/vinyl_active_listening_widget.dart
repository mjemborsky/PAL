import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../../../models/widget_config.dart';
import '../../../services/mock_playback_service.dart';

class VinylActiveListeningWidget extends StatefulWidget {
  final ActiveListeningConfig config;
  final VoidCallback? onDismiss;
  final VoidCallback? onReveal;

  const VinylActiveListeningWidget({
    super.key,
    required this.config,
    this.onDismiss,
    this.onReveal,
  });

  @override
  State<VinylActiveListeningWidget> createState() =>
      _VinylActiveListeningWidgetState();
}

class _VinylActiveListeningWidgetState extends State<VinylActiveListeningWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  PaletteGenerator? _palette;
  String? _lastTrackUrl;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final playbackService = context.watch<MockPlaybackService>();
    final newUrl = playbackService.currentTrack.albumArtUrl;

    if (_lastTrackUrl != newUrl) {
      _lastTrackUrl = newUrl;
      _updatePalette(newUrl);
    }
  }

  Future<void> _updatePalette(String imageUrl) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        maximumColorCount: 8,
      );
      if (mounted) {
        setState(() {
          _palette = palette;
        });
      }
    } catch (_) {}
  }

  Color _computeVinylWaxColor(Color fallbackPrimary) {
    final extracted = _palette?.vibrantColor?.color ??
        _palette?.dominantColor?.color ??
        _palette?.darkVibrantColor?.color ??
        fallbackPrimary;

    return Color.lerp(const Color(0xFF141518), extracted, 0.60) ??
        const Color(0xFF22242A);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final playbackService = context.watch<MockPlaybackService>();
    final currentTrack = playbackService.currentTrack;

    final mainTextColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleTextColor =
        isDark ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF4A4A4A);
    final scrimColor = isDark
        ? Colors.black.withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.78);

    final dominantColor =
        _palette?.dominantColor?.color ?? theme.colorScheme.primary;
    final accentColor = _palette?.vibrantColor?.color ??
        _palette?.lightVibrantColor?.color ??
        theme.colorScheme.secondary;
    final vinylWaxColor = _computeVinylWaxColor(theme.colorScheme.primary);

    final currentPos = playbackService.currentPosition;
    final totalDuration = currentTrack.duration;
    final progressValue = totalDuration.inSeconds > 0
        ? (currentPos.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      color: isDark ? Colors.black : const Color(0xFFF0F0F2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          final velocityY = details.primaryVelocity ?? 0.0;
          if (velocityY < -200) widget.onDismiss?.call();
          if (velocityY > 200) widget.onReveal?.call();
        },
        child: Stack(
          children: [
            // Full-Bleed 800x480 Background Artwork
            Positioned.fill(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: Image.network(
                        currentTrack.albumArtUrl,
                        key: ValueKey(currentTrack.albumArtUrl),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                      child: Container(color: scrimColor),
                    ),
                  ],
                ),
              ),
            ),

            // Foreground Vinyl Disc & Metadata Layout
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final rotationAngle =
                    (widget.config.rotateVinyl && playbackService.isPlaying)
                        ? _controller.value * 2 * math.pi
                        : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 20.0),
                  child: Row(
                    children: [
                      // Vinyl Disc Area
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: TweenAnimationBuilder<Color?>(
                            duration: const Duration(milliseconds: 600),
                            tween: ColorTween(end: vinylWaxColor),
                            builder: (context, animatedWaxColor, _) {
                              return TweenAnimationBuilder<Color?>(
                                duration: const Duration(milliseconds: 600),
                                tween: ColorTween(end: accentColor),
                                builder: (context, animatedAccentColor, _) {
                                  final safeWax =
                                      animatedWaxColor ?? vinylWaxColor;
                                  final safeAccent =
                                      animatedAccentColor ?? accentColor;

                                  return Container(
                                    width: 360,
                                    height: 360,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: safeAccent.withValues(
                                              alpha: 0.15),
                                          blurRadius: 20,
                                          spreadRadius: 1,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                              alpha: isDark ? 0.5 : 0.20),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // 1. ROTATING RECORD BODY
                                        Transform.rotate(
                                          angle: rotationAngle,
                                          child: SizedBox(
                                            width: 360,
                                            height: 360,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                CustomPaint(
                                                  size: const Size(360, 360),
                                                  painter: _VinylDiscPainter(
                                                    waxColor: safeWax,
                                                    isDark: isDark,
                                                  ),
                                                ),
                                                Container(
                                                  width: 125,
                                                  height: 125,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: RadialGradient(
                                                      colors: [
                                                        safeAccent,
                                                        dominantColor,
                                                      ],
                                                    ),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.85),
                                                      width: 2.5,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.35),
                                                        blurRadius: 6,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            7.0),
                                                    child: ClipOval(
                                                      child: AnimatedSwitcher(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    400),
                                                        layoutBuilder:
                                                            (child, previous) {
                                                          return Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              ...previous,
                                                              if (child != null)
                                                                child,
                                                            ],
                                                          );
                                                        },
                                                        child: Image.network(
                                                          currentTrack
                                                              .albumArtUrl,
                                                          key: ValueKey(
                                                              currentTrack
                                                                  .albumArtUrl),
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (_, __, ___) =>
                                                                  Icon(
                                                            Icons.music_note,
                                                            color:
                                                                mainTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 16,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        const Color(0xFF080808),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.4),
                                                      width: 1.2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // 2. STATIONARY SPECULAR GLARE
                                        IgnorePointer(
                                          child: CustomPaint(
                                            size: const Size(360, 360),
                                            painter:
                                                const _VinylSpecularGlarePainter(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),

                      // Metadata & Controls Area
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.music_note,
                                    color: accentColor, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'NOW PLAYING',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.5,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 450),
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              layoutBuilder: (child, previous) {
                                return Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    ...previous,
                                    if (child != null) child,
                                  ],
                                );
                              },
                              child: Column(
                                key: ValueKey(currentTrack.id),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentTrack.title,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: mainTextColor,
                                      height: 1.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${currentTrack.artist} • ${currentTrack.album}',
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: subtitleTextColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (widget.config.showProgressBar) ...[
                              const SizedBox(height: 28),
                              LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor:
                                    mainTextColor.withValues(alpha: 0.15),
                                color: accentColor,
                                borderRadius: BorderRadius.circular(4),
                                minHeight: 8,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(currentPos),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtitleTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(totalDuration),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtitleTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _VinylDiscPainter extends CustomPainter {
  final Color waxColor;
  final bool isDark;

  _VinylDiscPainter({required this.waxColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    const labelRadius = 62.5;
    const runOutRadius = 78.0;

    final waxPaint = Paint()
      ..color = waxColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, waxPaint);

    final groovePaint = Paint()..style = PaintingStyle.stroke;
    final trackBandGaps = [0.88, 0.74, 0.61, 0.48];
    const totalSteps = 45;

    for (int i = 0; i < totalSteps; i++) {
      final factor = i / totalSteps;
      final currentRadius =
          runOutRadius + (outerRadius - 6 - runOutRadius) * factor;

      final isSongGap = trackBandGaps.any(
        (gap) => (factor - gap).abs() < 0.015,
      );

      if (isSongGap) {
        groovePaint.color = Colors.black.withValues(alpha: 0.50);
        groovePaint.strokeWidth = 1.8;
      } else {
        groovePaint.color =
            Colors.white.withValues(alpha: (i % 2 == 0) ? 0.09 : 0.04);
        groovePaint.strokeWidth = 0.65;
      }

      canvas.drawCircle(center, currentRadius, groovePaint);
    }

    final spiralPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final spiralPath = Path();
    const spiralTurns = 2.5;
    const points = 120;

    for (int p = 0; p <= points; p++) {
      final t = p / points;
      final angle = t * spiralTurns * 2 * math.pi;
      final r = runOutRadius - (runOutRadius - labelRadius - 4) * t;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (p == 0) {
        spiralPath.moveTo(x, y);
      } else {
        spiralPath.lineTo(x, y);
      }
    }
    canvas.drawPath(spiralPath, spiralPaint);
  }

  @override
  bool shouldRepaint(covariant _VinylDiscPainter oldDelegate) {
    return oldDelegate.waxColor != waxColor || oldDelegate.isDark != isDark;
  }
}

class _VinylSpecularGlarePainter extends CustomPainter {
  const _VinylSpecularGlarePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    final glarePaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.22, 0.5, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius, glarePaint);

    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, outerRadius - 1.2, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _VinylSpecularGlarePainter oldDelegate) => false;
}

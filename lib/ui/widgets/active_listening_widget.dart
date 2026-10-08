import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../../models/widget_config.dart';
import '../../services/mock_playback_service.dart';

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
  PaletteGenerator? _palette;
  String? _lastTrackUrl;

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
    } catch (_) {
      // Fall back silently if offline or image fails to load
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final playbackService = context.watch<MockPlaybackService>();
    final currentTrack = playbackService.currentTrack;

    // Extract dynamic colors with theme fallbacks
    final dominantColor =
        _palette?.dominantColor?.color ?? theme.colorScheme.primary;
    final accentColor = _palette?.vibrantColor?.color ??
        _palette?.lightVibrantColor?.color ??
        theme.colorScheme.secondary;

    return Container(
      color: Colors.black,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          final velocityY = details.primaryVelocity ?? 0.0;
          if (velocityY < -200) widget.onDismiss?.call();
          if (velocityY > 200) widget.onReveal?.call();
        },
        child: Stack(
          children: [
            // LAYER 1: Full Album Background with Gaussian Blur (Isolated via ClipRect)
            Positioned.fill(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      currentTrack.albumArtUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.black),
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // LAYER 2: Foreground Controls & Spinning Vinyl
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                if (widget.config.style == ActiveListeningStyle.vinyl) {
                  return _buildVinylView(
                    _controller.value,
                    theme,
                    isDark,
                    playbackService,
                    dominantColor,
                    accentColor,
                  );
                }
                return _buildMilkdropView(
                  _controller.value,
                  theme,
                  isDark,
                  playbackService,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVinylView(
    double animValue,
    ThemeData theme,
    bool isDark,
    MockPlaybackService playbackService,
    Color dominantColor,
    Color accentColor,
  ) {
    final currentTrack = playbackService.currentTrack;
    final currentPos = playbackService.currentPosition;
    final totalDuration = currentTrack.duration;

    final progressValue = totalDuration.inSeconds > 0
        ? (currentPos.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    final rotationAngle =
        (widget.config.rotateVinyl && playbackService.isPlaying)
            ? animValue * 2 * math.pi
            : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Row(
        children: [
          // Spinning Record Disc Area
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
                    color: const Color(0xFF121212), // Deep vinyl wax color
                    boxShadow: [
                      // Ambient Glow based on extracted album accent color
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 15,
                        spreadRadius: 4,
                      ),
                    ],
                    // High-contrast rim outline guarantees separation from dark background art
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 2.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Vinyl Groove Line
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12, width: 1.5),
                        ),
                      ),
                      // Inner Vinyl Groove Line
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12, width: 1.5),
                        ),
                      ),

                      // DYNAMIC CENTER LABEL STICKER
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accentColor,
                              dominantColor,
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 2.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.network(
                              currentTrack.albumArtUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Center Spindle Hole
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(color: Colors.white30, width: 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 36),

          // Metadata & Controls Area
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.music_note, color: accentColor, size: 22),
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
                Text(
                  currentTrack.title,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${currentTrack.artist} • ${currentTrack.album}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.config.showProgressBar) ...[
                  const SizedBox(height: 28),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.white24,
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(currentPos),
                        style: const TextStyle(
                            fontSize: 15, color: Colors.white70),
                      ),
                      Text(
                        _formatDuration(totalDuration),
                        style: const TextStyle(
                            fontSize: 15, color: Colors.white70),
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
  }

  Widget _buildMilkdropView(
    double animValue,
    ThemeData theme,
    bool isDark,
    MockPlaybackService playbackService,
  ) {
    return const Center(
      child: Text('Milkdrop View', style: TextStyle(color: Colors.white)),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum FishState { wandering, gliding, fleeing, curious }

class KoiPattern {
  final Color bodyColor;
  final Color spotColor;
  final Color secondarySpotColor;

  const KoiPattern({
    required this.bodyColor,
    required this.spotColor,
    required this.secondarySpotColor,
  });
}

class KoiFish {
  Offset position;
  double angle; // radians
  double speed;
  double targetSpeed;
  final KoiPattern pattern;
  double scale;
  FishState state = FishState.wandering;

  // Steering & Dynamic Spine Physics
  Offset? targetDestination;
  double tailPhase = 0.0;
  double currentTurnRate = 0.0;
  double smoothedTurnBend = 0.0; // Low-pass filter for smooth curve bending

  // Timers & Spatial Perception
  int stateTimer = 0;
  int noticeDelayTimer = 0;

  KoiFish({
    required this.position,
    required this.angle,
    required this.pattern,
    this.scale = 1.0,
    this.speed = 0.8,
    this.targetSpeed = 0.8,
  }) {
    tailPhase = math.Random().nextDouble() * math.pi * 2;
    stateTimer = math.Random().nextInt(200) + 100;
  }
}

class WaterRipple {
  final Offset location;
  double radius;
  double opacity;
  final double maxRadius;

  WaterRipple({
    required this.location,
    this.radius = 2.0,
    this.opacity = 0.8,
    this.maxRadius = 70.0,
  });
}

class KoiPondWidget extends StatefulWidget {
  final VoidCallback? onDismiss;

  const KoiPondWidget({super.key, this.onDismiss});

  @override
  State<KoiPondWidget> createState() => _KoiPondWidgetState();
}

class _KoiPondWidgetState extends State<KoiPondWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  final List<KoiFish> _fishList = [];
  final List<WaterRipple> _ripples = [];

  // Gesture tracking
  Offset? _touchPosition;
  Timer? _holdTimer;
  bool _isHolding = false;

  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initFish();

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _ticker.addListener(_updatePhysics);
  }

  void _initFish() {
    final patterns = [
      const KoiPattern(
        bodyColor: Color(0xFFF7F4EF),
        spotColor: Color(0xFFD32F2F),
        secondarySpotColor: Colors.transparent,
      ),
      const KoiPattern(
        bodyColor: Color(0xFFFAF8F5),
        spotColor: Color(0xFFE64A19),
        secondarySpotColor: Color(0xFF212121),
      ),
      const KoiPattern(
        bodyColor: Color(0xFFFFB300),
        spotColor: Color(0xFFFFE082),
        secondarySpotColor: Colors.transparent,
      ),
      const KoiPattern(
        bodyColor: Color(0xFF1C1A1A),
        spotColor: Color(0xFFF57C00),
        secondarySpotColor: Color(0xFFEEEEEE),
      ),
      const KoiPattern(
        bodyColor: Color(0xFFECEFF1),
        spotColor: Color(0xFFCFD8DC),
        secondarySpotColor: Colors.transparent,
      ),
    ];

    for (int i = 0; i < 6; i++) {
      _fishList.add(
        KoiFish(
          position: Offset(
            120 + _random.nextDouble() * 560,
            100 + _random.nextDouble() * 280,
          ),
          angle: _random.nextDouble() * math.pi * 2,
          pattern: patterns[i % patterns.length],
          scale: 0.85 + _random.nextDouble() * 0.35,
          speed: 0.6 + _random.nextDouble() * 0.3,
          targetSpeed: 0.6 + _random.nextDouble() * 0.3,
        ),
      );
    }
  }

  void _updatePhysics() {
    const pondWidth = 800.0;
    const pondHeight = 480.0;

    // 1. Update Water Ripples
    for (int i = _ripples.length - 1; i >= 0; i--) {
      final r = _ripples[i];
      r.radius += 1.4;
      r.opacity -= 0.012;
      if (r.opacity <= 0 || r.radius >= r.maxRadius) {
        _ripples.removeAt(i);
      }
    }

    // 2. Update Fish AI & Natural Kinematics
    for (int i = 0; i < _fishList.length; i++) {
      final fish = _fishList[i];

      // Tail phase linked smoothly to swimming speed
      fish.tailPhase += (fish.speed * 0.09).clamp(0.02, 0.18);
      fish.stateTimer--;

      if (_isHolding && _touchPosition != null) {
        final distToTouch = (fish.position - _touchPosition!).distance;

        if (distToTouch < 380) {
          if (fish.noticeDelayTimer > 0) {
            fish.noticeDelayTimer--;
          } else {
            fish.state = FishState.curious;
            if (distToTouch < 60) {
              fish.targetSpeed = 0.22;
              fish.targetDestination = null;
            } else {
              fish.targetDestination = _touchPosition;
              fish.targetSpeed = 0.70;
            }
          }
        }
      } else if (fish.targetDestination != null &&
          fish.state == FishState.fleeing) {
        final distToDanger = (fish.position - fish.targetDestination!).distance;
        if (distToDanger > 280) {
          fish.state = FishState.wandering;
          fish.targetDestination = null;
        }
      } else {
        if (fish.stateTimer <= 0) {
          if (fish.state == FishState.gliding) {
            fish.state = FishState.wandering;
            fish.stateTimer = _random.nextInt(180) + 120;
            fish.targetDestination = Offset(
              90 + _random.nextDouble() * (pondWidth - 180),
              90 + _random.nextDouble() * (pondHeight - 180),
            );
          } else {
            fish.state = FishState.gliding;
            fish.stateTimer = _random.nextInt(120) + 60;
            fish.targetSpeed = 0.10;
          }
        }

        if (fish.state == FishState.wandering) {
          fish.targetSpeed = 0.45 + _random.nextDouble() * 0.25;
        }
      }

      // Smooth Speed Interpolation
      fish.speed += (fish.targetSpeed - fish.speed) * 0.04;

      // --- STEERING CALCULATION ---
      double desiredAngle = fish.angle;

      if (fish.targetDestination != null) {
        Offset desiredVector;
        if (fish.state == FishState.fleeing) {
          desiredVector = fish.position - fish.targetDestination!;
        } else {
          desiredVector = fish.targetDestination! - fish.position;
        }

        if (desiredVector.distance > 8) {
          desiredAngle = math.atan2(desiredVector.dy, desiredVector.dx);
        }
      }

      // --- SOFT FISH-TO-FISH SEPARATION ---
      Offset separationVector = Offset.zero;
      for (int j = 0; j < _fishList.length; j++) {
        if (i == j) continue;
        final other = _fishList[j];
        final diff = fish.position - other.position;
        final distance = diff.distance;

        const minDistance = 75.0;
        if (distance < minDistance && distance > 0) {
          final pushStrength = (minDistance - distance) / minDistance;
          separationVector += (diff / distance) * pushStrength;
        }
      }

      if (separationVector != Offset.zero) {
        final separationAngle =
            math.atan2(separationVector.dy, separationVector.dx);
        desiredAngle = _blendAngles(desiredAngle, separationAngle, 0.35);
      }

      // --- SMOOTH CURVED WALL AVOIDANCE ---
      const wallMargin = 100.0;
      Offset wallAvoidance = Offset.zero;

      if (fish.position.dx < wallMargin) {
        wallAvoidance += Offset(wallMargin - fish.position.dx, 0);
      } else if (fish.position.dx > pondWidth - wallMargin) {
        wallAvoidance += Offset((pondWidth - wallMargin) - fish.position.dx, 0);
      }

      if (fish.position.dy < wallMargin) {
        wallAvoidance += Offset(0, wallMargin - fish.position.dy);
      } else if (fish.position.dy > pondHeight - wallMargin) {
        wallAvoidance +=
            Offset(0, (pondHeight - wallMargin) - fish.position.dy);
      }

      if (wallAvoidance != Offset.zero) {
        final wallAngle = math.atan2(wallAvoidance.dy, wallAvoidance.dx);
        desiredAngle = _blendAngles(desiredAngle, wallAngle, 0.65);
      }

      // --- SPEED-COUPLED ANGULAR TURNING (MUST SWIM TO TURN) ---
      double angleDiff = desiredAngle - fish.angle;
      while (angleDiff < -math.pi) {
        angleDiff += math.pi * 2;
      }
      while (angleDiff > math.pi) {
        angleDiff -= math.pi * 2;
      }

      // Turn capacity scales with forward speed (no spinning in place)
      final speedFactor = (fish.speed / 0.75).clamp(0.12, 1.0);
      final maxTurnRate =
          (fish.state == FishState.fleeing ? 0.030 : 0.016) * speedFactor;
      final clampedTurn = angleDiff.clamp(-maxTurnRate, maxTurnRate);

      fish.angle += clampedTurn;
      fish.currentTurnRate = clampedTurn;

      // Low-pass filter to smooth spine curve bending
      fish.smoothedTurnBend += (clampedTurn - fish.smoothedTurnBend) * 0.08;

      // Forward position update along head direction
      final velocity = Offset(
        math.cos(fish.angle) * fish.speed,
        math.sin(fish.angle) * fish.speed,
      );
      fish.position += velocity;

      // Safety perimeter clamp
      fish.position = Offset(
        fish.position.dx.clamp(35.0, pondWidth - 35.0),
        fish.position.dy.clamp(35.0, pondHeight - 35.0),
      );
    }

    setState(() {});
  }

  double _blendAngles(double angleA, double angleB, double weight) {
    double diff = angleB - angleA;
    while (diff < -math.pi) {
      diff += math.pi * 2;
    }
    while (diff > math.pi) {
      diff -= math.pi * 2;
    }
    return angleA + (diff * weight);
  }

  void _onPointerDown(PointerDownEvent event) {
    _touchPosition = event.localPosition;

    const maxNoticeRadius = 380.0;
    for (final fish in _fishList) {
      final distance = (fish.position - event.localPosition).distance;
      if (distance < maxNoticeRadius) {
        fish.noticeDelayTimer = ((distance / maxNoticeRadius) * 110).round();
      }
    }

    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(milliseconds: 550), () {
      if (mounted) {
        setState(() {
          _isHolding = true;
        });
      }
    });

    _triggerSpatialScareRipple(event.localPosition);
  }

  void _onPointerMove(PointerMoveEvent event) {
    _touchPosition = event.localPosition;
  }

  void _onPointerUp(PointerUpEvent event) {
    _holdTimer?.cancel();
    _isHolding = false;
    _touchPosition = null;

    for (final fish in _fishList) {
      fish.noticeDelayTimer = 0;
      if (fish.state == FishState.curious) {
        fish.state = FishState.wandering;
        fish.targetDestination = null;
      }
    }
  }

  void _triggerSpatialScareRipple(Offset tapPosition) {
    _ripples.add(WaterRipple(location: tapPosition, maxRadius: 80.0));
    _ripples.add(WaterRipple(
        location: tapPosition, maxRadius: 45.0, radius: 1.0, opacity: 0.8));

    const scareRadius = 280.0;

    for (final fish in _fishList) {
      final distance = (fish.position - tapPosition).distance;

      if (distance < scareRadius) {
        fish.state = FishState.fleeing;
        fish.targetDestination = tapPosition;

        final distanceFactor = (1.0 - (distance / scareRadius)).clamp(0.0, 1.0);
        fish.targetSpeed = 1.8 + (2.5 * distanceFactor);
      }
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 480,
      color: const Color(0xFF143840),
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragEnd: (details) {
            final velocityY = details.primaryVelocity ?? 0.0;
            if (velocityY < -300) widget.onDismiss?.call();
          },
          child: CustomPaint(
            size: const Size(800, 480),
            painter: _KoiPondPainter(
              fishList: _fishList,
              ripples: _ripples,
              touchPosition: _touchPosition,
              isHolding: _isHolding,
            ),
          ),
        ),
      ),
    );
  }
}

class _KoiPondPainter extends CustomPainter {
  final List<KoiFish> fishList;
  final List<WaterRipple> ripples;
  final Offset? touchPosition;
  final bool isHolding;

  _KoiPondPainter({
    required this.fishList,
    required this.ripples,
    required this.touchPosition,
    required this.isHolding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sunlit Teal Water Gradient Background
    const pondGradient = RadialGradient(
      center: Alignment(-0.2, -0.3),
      radius: 1.1,
      colors: [
        Color(0xFF2E6F7E),
        Color(0xFF17434D),
      ],
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = pondGradient.createShader(Offset.zero & size),
    );

    // 2. Draw Water Ripples
    for (final r in ripples) {
      final ripplePaint = Paint()
        ..color =
            Colors.white.withValues(alpha: (r.opacity * 0.7).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(r.location, r.radius, ripplePaint);
    }

    // 3. Food Pulse Indicator (when holding)
    if (isHolding && touchPosition != null) {
      final foodGlow = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(touchPosition!, 16.0, foodGlow);

      final foodCore = Paint()..color = const Color(0xFFFFF8E1);
      canvas.drawCircle(touchPosition!, 3.5, foodCore);
    }

    // 4. Draw Koi Fish
    for (final fish in fishList) {
      _drawKoi(canvas, fish);
    }

    // 5. Draw Lily Pads
    _drawLilyPads(canvas, size);
  }

  void _drawKoi(Canvas canvas, KoiFish fish) {
    canvas.save();
    canvas.translate(fish.position.dx, fish.position.dy);
    canvas.rotate(fish.angle);
    canvas.scale(fish.scale);

    // Translucent Depth Shadow
    canvas.save();
    canvas.translate(14, 16);
    _paintFishBody(
      canvas,
      fish,
      Paint()..color = Colors.black.withValues(alpha: 0.18),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
      Paint()..color = Colors.black.withValues(alpha: 0.06),
    );
    canvas.restore();

    // Main Body Paints
    final mainPaint = Paint()
      ..color = fish.pattern.bodyColor
      ..style = PaintingStyle.fill;
    final spotPaint = Paint()
      ..color = fish.pattern.spotColor
      ..style = PaintingStyle.fill;
    final secSpotPaint = Paint()
      ..color = fish.pattern.secondarySpotColor
      ..style = PaintingStyle.fill;
    final finPaint = Paint()
      ..color = mainPaint.color.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    _paintFishBody(canvas, fish, mainPaint, spotPaint, secSpotPaint, finPaint);

    canvas.restore();
  }

  void _paintFishBody(
    Canvas canvas,
    KoiFish fish,
    Paint mainPaint,
    Paint spotPaint,
    Paint secSpotPaint,
    Paint finPaint,
  ) {
    final phase = fish.tailPhase;

    // NOSE ANCHORED COORDINATE SYSTEM (Origin X=0 is Nose)
    // Spine offsets: Swimming wave + Parabolic turn arc bending (d^1.3)
    double getSpineY(double distBack) {
      final swimAmp = (distBack / 80.0) * (distBack / 80.0) * 9.5;
      final swimWave = math.sin(phase - (distBack * 0.042)) * swimAmp;

      final turnArc =
          (fish.smoothedTurnBend * 130.0) * math.pow(distBack / 80.0, 1.3);

      return swimWave + turnArc;
    }

    const noseX = 0.0;
    const shoulderX = -18.0;
    const shoulderW = 15.0;
    const midX = -38.0;
    const midW = 12.0;
    const tailStemX = -58.0;
    const tailStemW = 4.5;
    const tailTipX = -80.0;

    final shoulderY = getSpineY(18.0);
    final midY = getSpineY(38.0);
    final tailStemY = getSpineY(58.0);
    final tailTipY = getSpineY(80.0);

    // DYNAMIC TORSO PATH
    final bodyPath = Path()..moveTo(noseX, 0.0);

    // Upper Flank
    bodyPath.cubicTo(
      shoulderX + 6,
      shoulderY - shoulderW,
      midX + 4,
      midY - midW,
      tailStemX,
      tailStemY - tailStemW,
    );
    bodyPath.lineTo(tailStemX - 2, tailStemY);

    // Lower Flank
    bodyPath.cubicTo(
      midX + 4,
      midY + midW,
      shoulderX + 6,
      shoulderY + shoulderW,
      noseX,
      0.0,
    );
    bodyPath.close();

    canvas.drawPath(bodyPath, mainPaint);

    // DORSAL BACK FIN
    final dorsalFinPath = Path()
      ..moveTo(shoulderX - 2, shoulderY)
      ..quadraticBezierTo(midX + 2, midY - 4.5, tailStemX + 6, tailStemY)
      ..quadraticBezierTo(midX + 2, midY - 1.0, shoulderX - 2, shoulderY);
    canvas.drawPath(dorsalFinPath, finPaint);

    // SPOTS
    canvas.save();
    canvas.translate(shoulderX + 2, shoulderY);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 16, height: 12), spotPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(midX, midY);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 10), spotPaint);
    if (secSpotPaint.color != Colors.transparent) {
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 8, height: 6),
          secSpotPaint);
    }
    canvas.restore();

    // PECTORAL FINS (Attached at shoulder flanks)
    final leftFinBaseY = shoulderY - shoulderW + 2;
    final leftFin = Path()
      ..moveTo(shoulderX + 4, leftFinBaseY)
      ..quadraticBezierTo(
          shoulderX + 2, leftFinBaseY - 14, shoulderX - 14, leftFinBaseY - 12)
      ..quadraticBezierTo(
          shoulderX - 8, leftFinBaseY - 3, shoulderX - 2, leftFinBaseY);
    canvas.drawPath(leftFin, finPaint);

    final rightFinBaseY = shoulderY + shoulderW - 2;
    final rightFin = Path()
      ..moveTo(shoulderX + 4, rightFinBaseY)
      ..quadraticBezierTo(
          shoulderX + 2, rightFinBaseY + 14, shoulderX - 14, rightFinBaseY + 12)
      ..quadraticBezierTo(
          shoulderX - 8, rightFinBaseY - 3, shoulderX - 2, rightFinBaseY);
    canvas.drawPath(rightFin, finPaint);

    // FLOWING TAIL FIN
    final tailFinPath = Path()
      ..moveTo(tailStemX, tailStemY)
      ..quadraticBezierTo(
          tailStemX - 12, tailStemY - 10, tailTipX, tailTipY - 15)
      ..quadraticBezierTo(tailStemX - 10, tailTipY, tailTipX, tailTipY + 15)
      ..quadraticBezierTo(tailStemX - 12, tailStemY + 10, tailStemX, tailStemY);

    canvas.drawPath(tailFinPath, finPaint);
  }

  void _drawLilyPads(Canvas canvas, Size size) {
    final padPaint = Paint()
      ..color = const Color(0xFF2D7D46)
      ..style = PaintingStyle.fill;

    final padHighlight = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pads = [
      const Offset(90, 80),
      const Offset(125, 110),
      const Offset(710, 380),
    ];

    for (final pos in pads) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      final path = Path()
        ..addArc(
          Rect.fromCircle(center: Offset.zero, radius: 32),
          0.35,
          5.5,
        )
        ..lineTo(0, 0)
        ..close();

      canvas.drawPath(path, padPaint);
      canvas.drawPath(path, padHighlight);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _KoiPondPainter oldDelegate) => true;
}

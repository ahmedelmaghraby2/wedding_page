import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:wedding/core/motion/reveal.dart';
import 'package:wedding/core/theme/app_colors.dart';

/// A slim gold rule with a centred diamond motif.
class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key, this.width = 220, this.thickness = 1});

  final double width;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 18,
      child: CustomPaint(
        painter: _GoldDividerPainter(thickness: thickness),
      ),
    );
  }
}

class _GoldDividerPainter extends CustomPainter {
  _GoldDividerPainter({required this.thickness});

  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final line = Paint()
      ..color = AppColors.champagne
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    const gap = 16.0;
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(center.dx - gap, center.dy),
      line,
    );
    canvas.drawLine(
      Offset(center.dx + gap, center.dy),
      Offset(size.width, center.dy),
      line,
    );

    final diamond = Path()
      ..moveTo(center.dx, center.dy - 7)
      ..lineTo(center.dx + 7, center.dy)
      ..lineTo(center.dx, center.dy + 7)
      ..lineTo(center.dx - 7, center.dy)
      ..close();
    canvas.drawPath(
      diamond,
      Paint()..color = AppColors.goldDeep,
    );

    final petal = Paint()
      ..color = AppColors.rose.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - gap + 3, center.dy), 2.2, petal);
    canvas.drawCircle(Offset(center.dx + gap - 3, center.dy), 2.2, petal);
  }

  @override
  bool shouldRepaint(covariant _GoldDividerPainter old) =>
      old.thickness != thickness;
}

/// A small leafy sprig used to flank section headings.
class FloralSprig extends StatelessWidget {
  const FloralSprig({
    super.key,
    this.size = 34,
    this.flip = false,
    this.color = AppColors.champagne,
  });

  final double size;
  final bool flip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: flip,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _SprigPainter(color)),
      ),
    );
  }
}

class _SprigPainter extends CustomPainter {
  _SprigPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final stem = Path()
      ..moveTo(size.width * 0.05, size.height * 0.95)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.75,
        size.width * 0.85,
        size.height * 0.2,
      );
    canvas.drawPath(stem, stroke);

    final leaf = Paint()..color = color.withValues(alpha: 0.55);
    for (var i = 0; i < 4; i++) {
      final t = 0.15 + i * 0.2;
      final p = _quadPoint(
        Offset(size.width * 0.05, size.height * 0.95),
        Offset(size.width * 0.45, size.height * 0.75),
        Offset(size.width * 0.85, size.height * 0.2),
        t,
      );
      final side = i.isEven ? 1.0 : -1.0;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(side * -0.7);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(6 * side, 0),
          width: 16,
          height: 8,
        ),
        leaf,
      );
      canvas.restore();
    }
  }

  Offset _quadPoint(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return Offset(
      u * u * a.dx + 2 * u * t * b.dx + t * t * c.dx,
      u * u * a.dy + 2 * u * t * b.dy + t * t * c.dy,
    );
  }

  @override
  bool shouldRepaint(covariant _SprigPainter old) => old.color != color;
}

/// A framed monogram badge, e.g. "A & R".
class MonogramBadge extends StatelessWidget {
  const MonogramBadge({
    super.key,
    this.size = 56,
    this.label = 'A&R',
    this.dark = false,
  });

  final double size;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final ring = dark ? AppColors.goldSoft : AppColors.champagne;
    final textColor = dark ? AppColors.cream : AppColors.espresso;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(ring),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: size * 0.34,
              height: 1,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 1.5;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final inner = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi * 0.85,
      math.pi * 1.5,
      false,
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.color != color;
}

/// Slow, subtle drifting petals for the hero background.
///
/// Disabled automatically for reduced-motion visitors and can be turned off
/// entirely for small screens via [enabled].
class PetalField extends StatefulWidget {
  const PetalField({super.key, this.count = 14, this.enabled = true});

  final int count;
  final bool enabled;

  @override
  State<PetalField> createState() => _PetalFieldState();
}

class _PetalFieldState extends State<PetalField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  );
  late final List<_Petal> _petals = _buildPetals(widget.count);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.enabled && !prefersReducedMotion(context)) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Petal> _buildPetals(int count) {
    final rng = math.Random(7);
    return List.generate(count, (i) {
      return _Petal(
        x: rng.nextDouble(),
        size: 6 + rng.nextDouble() * 8,
        speed: 0.6 + rng.nextDouble() * 0.7,
        sway: rng.nextDouble() * math.pi * 2,
        swayAmount: 0.02 + rng.nextDouble() * 0.05,
        color: i.isEven
            ? AppColors.blushDeep.withValues(alpha: 0.5)
            : AppColors.champagne.withValues(alpha: 0.35),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || prefersReducedMotion(context)) {
      return const SizedBox.shrink();
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _PetalPainter(_petals, _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Petal {
  const _Petal({
    required this.x,
    required this.size,
    required this.speed,
    required this.sway,
    required this.swayAmount,
    required this.color,
  });

  final double x;
  final double size;
  final double speed;
  final double sway;
  final double swayAmount;
  final Color color;
}

class _PetalPainter extends CustomPainter {
  _PetalPainter(this.petals, this.t);

  final List<_Petal> petals;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final progress = (t * p.speed + p.sway) % 1.0;
      final y = progress * (size.height + 60) - 30;
      final x = p.x * size.width +
          math.sin(t * math.pi * 2 + p.sway) * p.swayAmount * size.width;
      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(math.sin(t * math.pi * 2 + p.sway));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 1.5,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter old) => old.t != t;
}

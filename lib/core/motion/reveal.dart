import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Returns true when the visitor has asked the platform to reduce motion.
bool prefersReducedMotion(BuildContext context) {
  final media = MediaQuery.maybeOf(context);
  if (media != null && media.disableAnimations) return true;
  return PlatformDispatcher.instance.accessibilityFeatures.disableAnimations;
}

/// A gentle fade + slide entrance used for on-mount reveals (hero, gate).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.offset = const Offset(0, 24),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  double _t = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted) return;
    if (prefersReducedMotion(context)) {
      setState(() => _t = 1);
      return;
    }
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
      if (!mounted) return;
    }
    setState(() => _t = 1);
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context) && _t == 0) _t = 1;
    final curve = CurvedAnimation(
      parent: AlwaysStoppedAnimation(_t),
      curve: widget.curve,
    ).value;
    return Opacity(
      opacity: curve.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(
          widget.offset.dx * (1 - curve),
          widget.offset.dy * (1 - curve),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Reveals its child once when it scrolls into view.
class RevealOnScroll extends StatefulWidget {
  const RevealOnScroll({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 650),
    this.offset = const Offset(0, 30),
    this.curve = Curves.easeOutCubic,
    this.visibleFraction = 0.12,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;
  final double visibleFraction;

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );
  bool _triggered = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_triggered) return;
    if (info.visibleFraction < widget.visibleFraction) return;
    _triggered = true;
    if (prefersReducedMotion(context)) {
      _controller.value = 1;
      return;
    }
    if (widget.delay > Duration.zero) {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) {
          final v = _curve.value;
          return Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(
                widget.offset.dx * (1 - v),
                widget.offset.dy * (1 - v),
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

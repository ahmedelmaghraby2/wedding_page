import 'dart:math' as math;
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
  final Key _visibilityKey = UniqueKey();
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    // Safety net for the first layout: a section that is already on screen must
    // never stay hidden, even if the visibility detector's first callback is
    // coalesced away. The detector still drives reveals on later scrolls.
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealIfOnScreen());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Pixels of [childHeight] that must be visible before the entrance plays.
  ///
  /// The threshold is a fraction of the *smaller* of the child and the viewport
  /// so that a section taller than the viewport (a long wishes list, for
  /// example) can still reach it once its top edge scrolls into view. Gating on
  /// a pure `visibleFraction` of the child made such sections unreachable.
  double _thresholdFor(double childHeight, double viewportHeight) {
    final reference = math.min(childHeight, viewportHeight);
    return widget.visibleFraction * reference;
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted || _triggered) return;
    final viewportHeight =
        MediaQuery.maybeOf(context)?.size.height ?? info.size.height;
    if (info.visibleBounds.height <
        _thresholdFor(info.size.height, viewportHeight)) {
      return;
    }
    _reveal();
  }

  /// Reveals when the widget's own geometry overlaps the viewport enough.
  ///
  /// This does not depend on the detector and runs once after the first frame,
  /// so on-screen content is guaranteed to become visible.
  void _revealIfOnScreen() {
    if (!mounted || _triggered) return;
    final media = MediaQuery.maybeOf(context);
    final box = context.findRenderObject();
    if (media == null || box is! RenderBox || !box.hasSize || !box.attached) {
      return;
    }
    final bounds = box.localToGlobal(Offset.zero) & box.size;
    final onScreen = bounds.intersect(Offset.zero & media.size);
    if (onScreen.isEmpty) return;
    if (onScreen.height < _thresholdFor(box.size.height, media.size.height)) {
      return;
    }
    _reveal();
  }

  void _reveal() {
    if (_triggered) return;
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
      key: _visibilityKey,
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

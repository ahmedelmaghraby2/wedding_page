import 'dart:async';

import 'package:flutter/material.dart';

import 'package:wedding/core/motion/reveal.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/section.dart';

/// Wedding moment expressed as a fixed instant.
///
/// The local event time is 16/10/2026 20:00 (Africa/Cairo, UTC+3 during
/// daylight saving). Adjust [cairoOffsetHours] if the timezone rules change.
const int cairoOffsetHours = 3;
final DateTime weddingInstant = DateTime.utc(
  2026,
  10,
  16,
  20 - cairoOffsetHours,
  0,
  0,
);

class CountdownSection extends StatefulWidget {
  const CountdownSection({super.key, required this.isMobile});

  final bool isMobile;

  @override
  State<CountdownSection> createState() => _CountdownSectionState();
}

class _CountdownSectionState extends State<CountdownSection> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final diff = weddingInstant.difference(DateTime.now().toUtc());
    if (!mounted) return;
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final passed = weddingInstant
        .difference(DateTime.now().toUtc())
        .isNegative;

    return Column(
      children: [
        SectionHeading(title: l10n.countdownTitle),
        const SizedBox(height: 36),
        if (passed)
          Text(
            l10n.countdownToday,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.goldDeep,
            ),
            textAlign: TextAlign.center,
          )
        else
          Wrap(
            alignment: WrapAlignment.center,
            spacing: widget.isMobile ? 10 : 28,
            runSpacing: 16,
            children: [
              _CountdownTile(
                value: _remaining.inDays,
                label: l10n.countdownDays,
                isMobile: widget.isMobile,
              ),
              _CountdownTile(
                value: _remaining.inHours % 24,
                label: l10n.countdownHours,
                isMobile: widget.isMobile,
              ),
              _CountdownTile(
                value: _remaining.inMinutes % 60,
                label: l10n.countdownMinutes,
                isMobile: widget.isMobile,
              ),
              _CountdownTile(
                value: _remaining.inSeconds % 60,
                label: l10n.countdownSeconds,
                isMobile: widget.isMobile,
              ),
            ],
          ),
      ],
    );
  }
}

class _CountdownTile extends StatelessWidget {
  const _CountdownTile({
    required this.value,
    required this.label,
    required this.isMobile,
  });

  final int value;
  final String label;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final size = isMobile ? 70.0 : 96.0;
    final reduce = prefersReducedMotion(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.espresso.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: reduce
                ? Duration.zero
                : const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              key: ValueKey(value),
              style: (isMobile ? text.headlineSmall : text.headlineMedium)
                  ?.copyWith(color: AppColors.goldDeep, height: 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: text.labelSmall?.copyWith(
              color: AppColors.taupe,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

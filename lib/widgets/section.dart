import 'package:flutter/material.dart';

import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/widgets/ornaments.dart';

/// A centred section heading with a small eyebrow, sprigs and a gold rule.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.onDark = false,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final titleColor = onDark ? AppColors.cream : AppColors.espresso;
    final subColor = onDark ? AppColors.goldSoft : AppColors.taupe;

    return Column(
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            textAlign: TextAlign.center,
            style: text.labelLarge?.copyWith(
              color: onDark ? AppColors.goldSoft : AppColors.goldDeep,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FloralSprig(size: 26, flip: true),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(color: titleColor),
              ),
            ),
            const SizedBox(width: 10),
            const FloralSprig(size: 26),
          ],
        ),
        const SizedBox(height: 16),
        GoldDivider(width: 180, thickness: onDark ? 0.8 : 1),
        if (subtitle != null) ...[
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: subColor, height: 1.8),
            ),
          ),
        ],
      ],
    );
  }
}

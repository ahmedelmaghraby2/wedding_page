import 'package:flutter/material.dart';

import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/ornaments.dart';

class ClosingSection extends StatelessWidget {
  const ClosingSection({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final wedding = context.wedding;
    final locale = context.localeCode;
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 48 : 72,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cream, AppColors.blush],
        ),
      ),
      child: Column(
        children: [
          MonogramBadge(size: 72, label: wedding.monogramLabel),
          const SizedBox(height: 26),
          Text(
            l10n.closingTitle,
            textAlign: TextAlign.center,
            style: text.headlineMedium?.copyWith(color: AppColors.espresso),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              l10n.closingMessage,
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(
                color: AppColors.taupe,
                height: 1.9,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const GoldDivider(width: 220),
          const SizedBox(height: 24),
          Text(
            '${wedding.groom.resolve(locale)}  &  ${wedding.bride.resolve(locale)}',
            style: TextStyle(
              fontFamily: 'GreatVibes',
              fontSize: isMobile ? 34 : 44,
              height: 1.2,
              color: AppColors.goldDeep,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            wedding.event.date.resolve(locale),
            style: text.labelMedium?.copyWith(
              color: AppColors.taupe,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FloralSprig(size: 20, flip: true),
              const SizedBox(width: 12),
              Text(
                '${l10n.footerNote} · ${wedding.developer.resolve(locale)}',
                style: text.labelSmall?.copyWith(
                  color: AppColors.taupeLight,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 12),
              const FloralSprig(size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

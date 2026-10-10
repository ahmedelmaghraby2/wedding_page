import 'package:flutter/material.dart';

import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/section.dart';

class DetailsSection extends StatelessWidget {
  const DetailsSection({
    super.key,
    required this.onOpenMaps,
    required this.isMobile,
  });

  final VoidCallback onOpenMaps;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final wedding = context.wedding;
    final locale = context.localeCode;
    final l10n = AppLocalizations.of(context);
    final details = wedding.event;

    return Column(
      children: [
        SectionHeading(
          eyebrow: l10n.weddingInvitation,
          title: l10n.weddingDetails,
        ),
        const SizedBox(height: 36),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 40,
            vertical: isMobile ? 28 : 40,
          ),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.espresso.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: isMobile ? 28 : 56,
                runSpacing: 28,
                children: [
                  _DetailItem(
                    icon: Icons.event_outlined,
                    label: l10n.detailDate,
                    value: details.date.resolve(locale),
                  ),
                  _DetailItem(
                    icon: Icons.access_time,
                    label: l10n.detailTime,
                    value: details.time.resolve(locale),
                  ),
                  _DetailItem(
                    icon: Icons.home_work_outlined,
                    label: l10n.detailVenue,
                    value: details.venue.resolve(locale),
                  ),
                  _DetailItem(
                    icon: Icons.map_outlined,
                    label: l10n.detailLocation,
                    value: details.city.resolve(locale),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              FilledButton.icon(
                onPressed: onOpenMaps,
                icon: const Icon(Icons.location_on_outlined, size: 18),
                label: Text(l10n.openInGoogleMaps),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blush.withValues(alpha: 0.55),
              border: Border.all(color: AppColors.champagne),
            ),
            child: Icon(icon, size: 24, color: AppColors.goldDeep),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: text.labelSmall?.copyWith(
              color: AppColors.taupeLight,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: text.titleMedium?.copyWith(color: AppColors.espresso),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_outline,
            size: 36,
            color: AppColors.blushDeep,
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context).noComments,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.taupe),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

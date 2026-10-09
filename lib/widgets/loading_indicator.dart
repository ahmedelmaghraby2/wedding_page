import 'package:flutter/material.dart';

import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.champagne,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).loadingWishes,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.taupe),
          ),
        ],
      ),
    );
  }
}


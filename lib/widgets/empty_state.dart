import 'package:flutter/material.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          AppLocalizations.of(context).noComments,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

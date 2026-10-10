import 'package:flutter/material.dart';

import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/ornaments.dart';

/// The full-screen landing experience. The "Open Invitation" tap is the user
/// gesture that unlocks audio playback.
class InvitationGate extends StatelessWidget {
  const InvitationGate({
    super.key,
    required this.onOpen,
    required this.opacity,
    required this.isMobile,
  });

  final VoidCallback onOpen;
  final Animation<double> opacity;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final wedding = context.wedding;
    final locale = context.localeCode;
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: opacity,
      builder: (context, child) {
        final v = opacity.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: IgnorePointer(
            ignoring: v < 0.02,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.ivoryGradient,
                ),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: child,
              ),
            ),
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MonogramBadge(size: 84, label: wedding.monogramLabel),
              const SizedBox(height: 28),
              Text(
                l10n.gateEyebrow,
                textAlign: TextAlign.center,
                style: text.labelLarge,
              ),
              const SizedBox(height: 18),
              Text(
                wedding.groom.resolve(locale),
                style: (isMobile ? text.displayMedium : text.displayLarge)
                    ?.copyWith(color: AppColors.espresso),
              ),
              Text(
                '&',
                style: TextStyle(
                  fontFamily: 'GreatVibes',
                  fontSize: isMobile ? 40 : 56,
                  height: 1,
                  color: AppColors.goldDeep,
                ),
              ),
              Text(
                wedding.bride.resolve(locale),
                style: (isMobile ? text.displayMedium : text.displayLarge)
                    ?.copyWith(color: AppColors.espresso),
              ),
              const SizedBox(height: 22),
              const GoldDivider(width: 200),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.mail_outline, size: 18),
                label: Text(l10n.openInvitation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

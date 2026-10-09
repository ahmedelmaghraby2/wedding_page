import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/music_button.dart';
import 'package:wedding/widgets/ornaments.dart';

class SiteHeader extends StatelessWidget {
  const SiteHeader({
    super.key,
    required this.musicController,
    required this.onToggleLocale,
    required this.onNavigate,
    required this.isMobile,
    required this.scrolled,
    required this.onHome,
  });

  final MusicController musicController;
  final VoidCallback onToggleLocale;
  final void Function(String section) onNavigate;
  final bool isMobile;
  final bool scrolled;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: scrolled ? 12 : 0,
          sigmaY: scrolled ? 12 : 0,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
          decoration: BoxDecoration(
            color: scrolled
                ? AppColors.ivory.withValues(alpha: 0.82)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: scrolled ? AppColors.line : Colors.transparent,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 68,
              child: Row(
                children: [
                  _Brand(onTap: onHome, showName: !isMobile),
                  const Spacer(),
                  if (!isMobile) ...[
                    _navItem(context, l10n.navDetails, () => onNavigate('details')),
                    _navItem(context, l10n.navStory, () => onNavigate('story')),
                    _navItem(context, l10n.navWishes, () => onNavigate('wishes')),
                    const SizedBox(width: 8),
                  ],
                  Tooltip(
                    message: l10n.changeLanguage,
                    child: TextButton(
                      onPressed: onToggleLocale,
                      child: Text(isArabic ? 'English' : 'العربية'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MusicButton(
                    controller: musicController,
                    tooltip: musicController.isPlaying
                        ? l10n.pauseMusic
                        : l10n.playMusic,
                  ),
                  const SizedBox(width: 8),
                  _MuteButton(controller: musicController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.espresso,
          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            letterSpacing: 1.5,
            color: AppColors.espresso,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.controller});

  final MusicController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final muted = controller.isMuted;
        return Tooltip(
          message: muted ? l10n.unmuteMusic : l10n.muteMusic,
          child: IconButton(
            onPressed: controller.toggleMute,
            iconSize: 20,
            color: AppColors.goldDeep,
            icon: Icon(
              muted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
            ),
          ),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.onTap, required this.showName});

  final VoidCallback onTap;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            const MonogramBadge(size: 40, label: 'A&R'),
            if (showName) ...[
              const SizedBox(width: 12),
              Text(
                'Adel & Rahma',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.espresso,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

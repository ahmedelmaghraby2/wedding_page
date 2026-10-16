import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/features/wedding/presentation/controllers/cubits/music/music_cubit.dart';
import 'package:wedding/core/l10n/generated/app_localizations.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/music_button.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/ornaments.dart';

class SiteHeader extends StatelessWidget {
  const SiteHeader({
    super.key,
    required this.music,
    required this.onToggleLocale,
    required this.onNavigate,
    required this.isMobile,
    required this.scrolled,
    required this.onHome,
  });

  final MusicCubit music;
  final VoidCallback onToggleLocale;
  final void Function(String section) onNavigate;
  final bool isMobile;
  final bool scrolled;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final wedding = context.wedding;
    final l10n = AppLocalizations.of(context);
    final isArabic = context.localeCode == 'ar';

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Decide what fits from the *unscaled* width, so a larger text
                  // scale (accessibility) drops optional items instead of
                  // overflowing the bar. `constraints.maxWidth` is the space left
                  // inside the bar's horizontal padding.
                  final scale = MediaQuery.textScalerOf(context).scale(1);
                  final unscaled = scale <= 0
                      ? constraints.maxWidth
                      : constraints.maxWidth / scale;
                  final showNav = !isMobile && unscaled >= 960;
                  final showBrandName = unscaled >= 1100;
                  // The decorative monogram is the first thing to go when the
                  // controls alone need the whole bar (tiny screens at a large
                  // text scale).
                  final showBrandMark = unscaled >= 280;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // The brand is the only shrinkable region: it yields and
                      // ellipsizes before anything overflows, and the trailing
                      // controls always keep their intrinsic size.
                      Flexible(
                        child: showBrandMark
                            ? _Brand(onTap: onHome, showName: showBrandName)
                            : const SizedBox.shrink(),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showNav) ...[
                            _navItem(
                              context,
                              l10n.navDetails,
                              () => onNavigate('details'),
                            ),
                            if (wedding.hasStory)
                              _navItem(
                                context,
                                l10n.navStory,
                                () => onNavigate('story'),
                              ),
                            if (wedding.showComments)
                              _navItem(
                                context,
                                l10n.navWishes,
                                () => onNavigate('wishes'),
                              ),
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
                            cubit: music,
                            tooltip: music.state.isPlaying
                                ? l10n.pauseMusic
                                : l10n.playMusic,
                          ),
                          const SizedBox(width: 8),
                          _MuteButton(cubit: music),
                        ],
                      ),
                    ],
                  );
                },
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
          textStyle: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(letterSpacing: 1.5, color: AppColors.espresso),
        ),
        child: Text(label),
      ),
    );
  }
}

class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.cubit});

  final MusicCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<MusicCubit, MusicState>(
      bloc: cubit,
      builder: (context, state) {
        final muted = state.muted;
        final label = muted ? l10n.unmuteMusic : l10n.muteMusic;
        return Semantics(
          button: true,
          label: label,
          child: IconButton(
            onPressed: cubit.toggleMute,
            iconSize: 20,
            color: AppColors.goldDeep,
            tooltip: label,
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
    final wedding = context.wedding;
    final locale = context.localeCode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MonogramBadge(size: 40, label: wedding.monogramLabel),
            if (showName) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '${wedding.groom.resolve(locale)} & ${wedding.bride.resolve(locale)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: AppColors.espresso, letterSpacing: 1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

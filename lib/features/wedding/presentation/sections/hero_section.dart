import 'package:flutter/material.dart';

import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/motion/reveal.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/ornaments.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.isMobile, required this.height});

  final bool isMobile;
  final double height;

  @override
  Widget build(BuildContext context) {
    final wedding = context.wedding;
    final locale = context.localeCode;
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final shadow = [
      Shadow(
        color: Colors.black.withValues(alpha: 0.45),
        blurRadius: 18,
        offset: const Offset(0, 4),
      ),
    ];
    final nameStyle = (isMobile ? text.displayMedium : text.displayLarge)
        ?.copyWith(color: AppColors.cream, shadows: shadow);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            wedding.heroImage,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.45),
                  AppColors.ivory,
                ],
                stops: const [0, 0.32, 0.82, 1],
              ),
            ),
          ),
          PetalField(enabled: !isMobile),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeSlideIn(
                      child: Text(
                        l10n.weddingInvitation,
                        style: text.labelLarge?.copyWith(
                          color: AppColors.goldSoft,
                          shadows: shadow,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      child: Text(
                        wedding.groom.resolve(locale),
                        style: nameStyle,
                      ),
                    ),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 250),
                      child: Text(
                        '&',
                        style: TextStyle(
                          fontFamily: 'GreatVibes',
                          fontSize: isMobile ? 40 : 54,
                          height: 1.1,
                          color: AppColors.goldSoft,
                          shadows: shadow,
                        ),
                      ),
                    ),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 350),
                      child: Text(
                        wedding.bride.resolve(locale),
                        style: nameStyle,
                      ),
                    ),
                    const SizedBox(height: 22),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 450),
                      child: const GoldDivider(width: 200),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 550),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Text(
                          wedding.caption.resolve(locale),
                          textAlign: TextAlign.center,
                          style: text.bodyLarge?.copyWith(
                            color: AppColors.cream,
                            shadows: shadow,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const FadeSlideIn(
                      delay: Duration(milliseconds: 700),
                      child: _ScrollHint(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollHint extends StatefulWidget {
  const _ScrollHint();

  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!prefersReducedMotion(context)) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.heroScrollHint,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.cream.withValues(alpha: 0.85),
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, 4 * _controller.value),
            child: child,
          ),
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.cream,
            size: 26,
          ),
        ),
      ],
    );
  }
}

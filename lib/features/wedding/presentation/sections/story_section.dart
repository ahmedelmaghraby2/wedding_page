import 'package:flutter/material.dart';

import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/ornaments.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final isArabic = l10n.localeName == 'ar';

    final collage = _PhotoCollage(isMobile: isMobile);
    final copy = Column(
      crossAxisAlignment:
          isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          l10n.storyTitle,
          style: text.headlineLarge?.copyWith(color: AppColors.espresso),
        ),
        const SizedBox(height: 18),
        const Align(alignment: AlignmentDirectional.centerStart, child: GoldDivider(width: 140)),
        const SizedBox(height: 22),
        Text(
          l10n.storyParagraph1,
          textAlign: isArabic ? TextAlign.right : TextAlign.start,
          style: text.bodyLarge?.copyWith(color: AppColors.taupe, height: 1.9),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.storyParagraph2,
          textAlign: isArabic ? TextAlign.right : TextAlign.start,
          style: text.bodyLarge?.copyWith(color: AppColors.taupe, height: 1.9),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: collage),
          const SizedBox(height: 40),
          copy,
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: collage),
              const SizedBox(height: 40),
              copy,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 440, child: collage),
            const SizedBox(width: 56),
            Expanded(child: copy),
          ],
        );
      },
    );
  }
}

class _PhotoCollage extends StatelessWidget {
  const _PhotoCollage({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 460.0;
        final width = maxWidth.clamp(260.0, isMobile ? 330.0 : 460.0);
        final height = width * (isMobile ? 1.18 : 1.04);
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: _FramedPhoto(
                  asset: 'assets/images/wedding2.jpeg',
                  width: width * 0.74,
                  height: height * 0.82,
                  angle: -0.035,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _FramedPhoto(
                  asset: 'assets/images/wedding3.jpeg',
                  width: width * 0.6,
                  height: height * 0.66,
                  angle: 0.05,
                ),
              ),
              Positioned(
                right: width * 0.02,
                top: height * 0.04,
                child: const MonogramBadge(size: 58),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FramedPhoto extends StatelessWidget {
  const _FramedPhoto({
    required this.asset,
    required this.width,
    required this.height,
    required this.angle,
  });

  final String asset;
  final double width;
  final double height;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cream,
          border: Border.all(color: AppColors.champagne, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.espresso.withValues(alpha: 0.16),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}

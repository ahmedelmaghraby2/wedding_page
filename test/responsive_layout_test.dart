import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wedding/core/config/wedding_config.dart';
import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/l10n/generated/app_localizations.dart';
import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/core/motion/reveal.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';
import 'package:wedding/features/wedding/presentation/controllers/cubits/comments/comments_cubit.dart';
import 'package:wedding/features/wedding/presentation/controllers/cubits/music/music_cubit.dart';
import 'package:wedding/features/wedding/presentation/ui/screens/wedding_invitation_page.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/comment_item.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/invitation_gate.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/sections/wishes_section.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/site_header.dart';

import 'support/fake_comments_repository.dart';

/// Regression coverage for the responsive-layout fixes:
///
/// * a section taller than the viewport must still reveal once it is on
///   screen (it used to sit at `Opacity(0)` forever and read as a blank page);
/// * the hero, the invitation gate and the site header must never overflow at
///   small viewports, in landscape, or under a 1.5x text scale.
WeddingConfig _config() => WeddingConfig.fromJson({
  'weddingId': 'ahmed-aya',
  'title': {'en': 'Ahmed & Aya Wedding', 'ar': 'دعوة'},
  'developer': {'en': 'Ahmed Elmaghraby', 'ar': 'أحمد'},
  'groom': {'en': 'Ahmed', 'ar': 'أحمد'},
  'bride': {'en': 'Aya', 'ar': 'آية'},
  'event': {
    'countdownDateTime': '2026-10-28T20:00:00+03:00',
    'display': {
      'date': {'en': '28/10/2026', 'ar': '28/10/2026'},
      'time': {'en': '8:00 PM', 'ar': '8:00 مساءً'},
      'venue': {'en': 'Maryal Hall B', 'ar': 'قاعة ماريال ب'},
      'city': {'en': 'Port Said, Egypt', 'ar': 'بورسعيد، مصر'},
    },
    'mapsUrl': 'https://maps.example.com/1',
  },
  'heroImage': 'assets/weddings/ahmed-aya/hero.jpg',
  'musicSource': 'assets/weddings/ahmed-aya/song.mp3',
  'caption': {
    'en': 'We invite you to share in our joy on this special day',
    'ar': 'ندعوكم لمشاركتنا فرحتنا في هذا اليوم المميز',
  },
  'story': {
    'en': [
      'It began with a simple hello, and grew into a love we never want to end.',
      'Now we are ready for the next chapter. Thank you for being part of our story.',
    ],
    'ar': ['بدأت بتحيّة بسيطة.', 'شكرًا لأنكم جزء من قصتنا.'],
  },
  'gallery': [
    'assets/weddings/ahmed-aya/story-1.jpeg',
    'assets/weddings/ahmed-aya/story-2.jpeg',
  ],
  'showComments': true,
});

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required Size size,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  FakeCommentsRepository? repository,
}) async {
  await _setViewport(tester, size);
  final fake = repository ?? FakeCommentsRepository();
  final comments = CommentsCubit(fake);
  final music = MusicCubit(controller: MusicController());
  addTearDown(() async {
    await comments.close();
    await music.close();
    await fake.closeStream();
  });
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: widget!,
      ),
      home: WeddingScope(
        config: _config(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<CommentsCubit>.value(value: comments),
            BlocProvider<MusicCubit>.value(value: music),
          ],
          child: WeddingInvitationPage(onToggleLocale: (_) {}, music: music),
        ),
      ),
    ),
  );
}

double _revealOpacity(WidgetTester tester, Finder reveal) {
  final opacity = tester.widget<Opacity>(
    find.descendant(of: reveal, matching: find.byType(Opacity)).first,
  );
  return opacity.opacity;
}

void main() {
  setUp(() {
    // Fire visibility callbacks through post-frame callbacks so no timers are
    // left pending when a test ends.
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });
  tearDown(() {
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 500,
    );
  });

  group('RevealOnScroll', () {
    Future<void> pumpReveal(
      WidgetTester tester, {
      required double childHeight,
      double leadingSpacer = 100,
    }) async {
      await _setViewport(tester, const Size(360, 640));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: leadingSpacer)),
                SliverToBoxAdapter(
                  child: RevealOnScroll(
                    child: Container(height: childHeight, color: Colors.red),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 2400)),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('reveals a section taller than 8x the viewport', (tester) async {
      await pumpReveal(tester, childHeight: 6400);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(_revealOpacity(tester, find.byType(RevealOnScroll)), 1.0);
    });

    testWidgets('reveals a section taller than 10x the viewport', (
      tester,
    ) async {
      await pumpReveal(tester, childHeight: 8000);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(_revealOpacity(tester, find.byType(RevealOnScroll)), 1.0);
    });

    testWidgets('reveals a section after scrolling it into view', (
      tester,
    ) async {
      // Just barely below the fold, so it is built but not visible enough to
      // reveal yet.
      await pumpReveal(tester, childHeight: 400, leadingSpacer: 620);
      expect(_revealOpacity(tester, find.byType(RevealOnScroll)), 0.0);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(_revealOpacity(tester, find.byType(RevealOnScroll)), 1.0);
    });
  });

  group('page layout overflows', () {
    const sizes = <String, Size>{
      'phone-320x568': Size(320, 568),
      'phone-360x640': Size(360, 640),
      'phone-landscape-740x360': Size(740, 360),
      'tablet-768x1024': Size(768, 1024),
      'desktop-1280x800': Size(1280, 800),
    };

    for (final entry in sizes.entries) {
      for (final locale in const [Locale('en'), Locale('ar')]) {
        for (final scale in const [1.0, 1.5]) {
          testWidgets('${entry.key} ${locale.languageCode} x$scale', (
            tester,
          ) async {
            await _pumpPage(
              tester,
              size: entry.value,
              locale: locale,
              textScale: scale,
            );
            await tester.pump(const Duration(seconds: 2));
            expect(tester.takeException(), isNull);
          });
        }
      }
    }

    testWidgets('many comments grow the page without overflow and still reveal', (
      tester,
    ) async {
      final fake = FakeCommentsRepository();
      final cubit = CommentsCubit(fake);
      final formKey = GlobalKey<FormState>();
      final name = TextEditingController();
      final comment = TextEditingController();
      final code = TextEditingController();
      addTearDown(() async {
        await cubit.close();
        await fake.closeStream();
        name.dispose();
        comment.dispose();
        code.dispose();
      });

      await tester.binding.setSurfaceSize(const Size(380, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<CommentsCubit>.value(
            value: cubit,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: RevealOnScroll(
                      child: WishesSection(
                        formKey: formKey,
                        nameController: name,
                        commentController: comment,
                        accessCodeController: code,
                        onSubmit: () {},
                        onEdit: (_) {},
                        onDelete: (_) {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      fake.emitComments([
        for (var i = 0; i < 60; i++)
          WeddingComment(
            id: '$i',
            fullName: 'Guest $i',
            comment:
                'Congratulations on your wedding! Wishing you a lifetime of '
                'love and happiness together.',
          ),
      ]);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      final reveal = find.ancestor(
        of: find.byType(WishesSection),
        matching: find.byType(RevealOnScroll),
      );
      expect(find.byType(CommentItem), findsNWidgets(60));
      expect(_revealOpacity(tester, reveal), 1.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('site header', () {
    Future<void> pumpHeader(
      WidgetTester tester, {
      required Size size,
      Locale locale = const Locale('en'),
      double textScale = 1.0,
      required bool isMobile,
    }) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final music = MusicCubit(controller: MusicController());
      addTearDown(music.close);
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: widget!,
          ),
          home: WeddingScope(
            config: _config(),
            child: Scaffold(
              body: SiteHeader(
                music: music,
                onToggleLocale: () {},
                onNavigate: (_) {},
                isMobile: isMobile,
                scrolled: false,
                onHome: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('no overflow at tablet widths', (tester) async {
      for (final size in const [
        Size(768, 200),
        Size(820, 200),
        Size(1024, 200),
      ]) {
        await pumpHeader(tester, size: size, isMobile: false);
        expect(tester.takeException(), isNull, reason: 'width ${size.width}');
      }
    });

    testWidgets('no overflow on tiny screens at 1.5x', (tester) async {
      for (final size in const [Size(320, 200), Size(360, 200)]) {
        await pumpHeader(
          tester,
          size: size,
          isMobile: true,
          textScale: 1.5,
        );
        expect(tester.takeException(), isNull, reason: 'width ${size.width}');
      }
    });

    testWidgets('keeps nav and brand name on wide screens', (tester) async {
      await pumpHeader(tester, size: const Size(1280, 200), isMobile: false);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Ahmed & Aya'), findsOneWidget);
    });
  });

  group('invitation gate', () {
    Future<void> pumpGate(
      WidgetTester tester, {
      required Size size,
      double textScale = 1.0,
      bool isMobile = true,
    }) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: widget!,
          ),
          home: WeddingScope(
            config: _config(),
            child: Scaffold(
              body: InvitationGate(
                onOpen: () {},
                opacity: const AlwaysStoppedAnimation<double>(1),
                isMobile: isMobile,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('no overflow on a short viewport at 1.5x', (tester) async {
      await pumpGate(tester, size: const Size(320, 568), textScale: 1.5);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow in landscape', (tester) async {
      await pumpGate(
        tester,
        size: const Size(740, 360),
        isMobile: false,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

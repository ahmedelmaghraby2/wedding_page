import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/core/config/wedding_config.dart';
import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/features/wedding/presentation/controllers/cubits/comments/comments_cubit.dart';
import 'package:wedding/features/wedding/presentation/controllers/cubits/music/music_cubit.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/sections/closing_section.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/sections/wishes_section.dart';
import 'package:wedding/core/l10n/generated/app_localizations.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/comment_form.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/comment_item.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/invitation_gate.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/music_button.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/site_header.dart';

import 'support/fake_comments_repository.dart';

// --- WCAG contrast helpers (relative luminance per WCAG 2.x) ----------------

double _channel(double c) {
  final v = c / 255.0;
  return v <= 0.03928
      ? v / 12.92
      : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color c) =>
    0.2126 * _channel(c.r * 255) +
    0.7152 * _channel(c.g * 255) +
    0.0722 * _channel(c.b * 255);

double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(400, 2000),
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: widget!,
      ),
      home: Scaffold(body: child),
    ),
  );
}

WeddingConfig _config() => WeddingConfig.fromJson({
  'weddingId': 'test-couple',
  'title': {'en': 'Test Couple', 'ar': 'ثنائي الاختبار'},
  'developer': {'en': 'Studio EN', 'ar': 'استوديو'},
  'groom': {'en': 'Adam', 'ar': 'آدم'},
  'bride': {'en': 'Eve', 'ar': 'حواء'},
  'event': {
    'countdownDateTime': '2027-01-01T20:00:00+02:00',
    'display': {
      'date': {'en': '01/01/2027', 'ar': '٠١/٠١/٢٠٢٧'},
      'time': {'en': '8:00 PM', 'ar': '8:00 مساءً'},
      'venue': {'en': 'Halla', 'ar': 'قاعة'},
      'city': {'en': 'Cairo', 'ar': 'القاهرة'},
    },
    'mapsUrl': 'https://maps.example.com/1',
  },
  'heroImage': 'assets/weddings/test-couple/hero.jpg',
  'musicSource': 'assets/weddings/test-couple/song.mp3',
  'caption': {'en': 'Welcome', 'ar': 'أهلاً'},
});

Future<void> _pumpScoped(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(1200, 200),
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: widget!,
      ),
      home: WeddingScope(
        config: _config(),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('WCAG color contrast', () {
    test('body text meets AA (>= 4.5:1) on every light surface', () {
      for (final surface in const [
        AppColors.ivory,
        AppColors.cream,
        AppColors.beige,
      ]) {
        expect(
          contrastRatio(AppColors.espresso, surface),
          greaterThanOrEqualTo(4.5),
          reason: 'espresso on $surface',
        );
        expect(
          contrastRatio(AppColors.taupe, surface),
          greaterThanOrEqualTo(4.5),
          reason: 'taupe on $surface',
        );
      }
    });

    test('accent + muted text meets AA (>= 4.5:1) on ivory/cream', () {
      for (final surface in const [AppColors.ivory, AppColors.cream]) {
        expect(
          contrastRatio(AppColors.goldDeep, surface),
          greaterThanOrEqualTo(4.5),
          reason: 'goldDeep on $surface',
        );
        expect(
          contrastRatio(AppColors.taupeLight, surface),
          greaterThanOrEqualTo(4.5),
          reason: 'taupeLight on $surface',
        );
      }
    });

    test('goldDeep on the beige countdown band meets large-text AA', () {
      expect(
        contrastRatio(AppColors.goldDeep, AppColors.beige),
        greaterThanOrEqualTo(3.0),
      );
    });

    test('button label (white) on the gold accent meets AA', () {
      expect(
        contrastRatio(Colors.white, AppColors.goldDeep),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('error icon meets non-text contrast (>= 3:1) on cream', () {
      expect(
        contrastRatio(AppColors.rose, AppColors.cream),
        greaterThanOrEqualTo(3.0),
      );
    });
  });

  group('music control semantics', () {
    testWidgets('exposes a semantic label for play and mute', (tester) async {
      final handle = tester.ensureSemantics();
      final music = MusicCubit(controller: MusicController());
      addTearDown(music.close);

      await _pumpScoped(
        tester,
        SiteHeader(
          music: music,
          onToggleLocale: () {},
          onNavigate: (_) {},
          isMobile: false,
          scrolled: false,
          onHome: () {},
        ),
      );

      expect(find.bySemanticsLabel('Play music'), findsOneWidget);
      expect(find.bySemanticsLabel('Mute music'), findsOneWidget);
      handle.dispose();
    });
  });

  group('touch targets', () {
    testWidgets('music play/pause target is at least 44x44', (tester) async {
      final music = MusicCubit(controller: MusicController());
      addTearDown(music.close);
      await _pump(tester, MusicButton(cubit: music));
      final size = tester.getSize(
        find.descendant(
          of: find.byType(MusicButton),
          matching: find.byType(InkWell),
        ),
      );
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('mute button meets the 48x48 material minimum', (tester) async {
      final music = MusicCubit(controller: MusicController());
      addTearDown(music.close);
      await _pumpScoped(
        tester,
        SiteHeader(
          music: music,
          onToggleLocale: () {},
          onNavigate: (_) {},
          isMobile: false,
          scrolled: false,
          onHome: () {},
        ),
      );
      final size = tester.getSize(
        find.descendant(
          of: find.byType(SiteHeader),
          matching: find.byType(IconButton),
        ),
      );
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });

  group('text scaling (1.5x) has no layout overflow', () {
    testWidgets('comment form', (tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: CommentForm(
            formKey: GlobalKey<FormState>(),
            nameController: TextEditingController(),
            commentController: TextEditingController(),
            accessCodeController: TextEditingController(),
            isSubmitting: false,
            submitMessage: null,
            submitSuccess: false,
            onSubmit: () {},
          ),
        ),
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('wishes section with a long comment', (tester) async {
      final fake = FakeCommentsRepository();
      final cubit = CommentsCubit(fake);
      addTearDown(() async {
        await cubit.close();
        await fake.closeStream();
      });
      await _pump(
        tester,
        BlocProvider<CommentsCubit>.value(
          value: cubit,
          child: SingleChildScrollView(
            child: WishesSection(
              formKey: GlobalKey<FormState>(),
              nameController: TextEditingController(),
              commentController: TextEditingController(),
              accessCodeController: TextEditingController(),
              onSubmit: () {},
              onEdit: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
        textScale: 1.5,
      );
      fake.emitComments(const [
        WeddingComment(
          id: '1',
          fullName: 'Alexandria Catherine Montgomery',
          comment:
              'Wishing you a lifetime of love, laughter and every happiness '
              'in the world. Congratulations to you both!',
        ),
      ]);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('closing section', (tester) async {
      await _pumpScoped(
        tester,
        const SingleChildScrollView(child: ClosingSection(isMobile: true)),
        size: const Size(400, 2000),
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('long content does not overflow', () {
    testWidgets('comment item wraps a very long single-token name', (
      tester,
    ) async {
      await _pump(
        tester,
        const CommentItem(
          comment: WeddingComment(
            id: '1',
            fullName: 'Alexandriacatherinemontgomery',
            comment: 'Best wishes to you both on this wonderful day.',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('gate renders very long bilingual names without overflow', (
      tester,
    ) async {
      final config = WeddingConfig.fromJson({
        'weddingId': 'test',
        'title': {'en': 'Test'},
        'developer': {'en': 'Studio'},
        'groom': {'en': 'Bartholomew Maximilian', 'ar': 'بارثولوميو'},
        'bride': {'en': 'Alexandrina Catherine', 'ar': 'ألكسندرينا'},
        'event': {
          'countdownDateTime': '2027-01-01T20:00:00+02:00',
          'display': {
            'date': {'en': '01/01/2027'},
            'time': {'en': '8:00 PM'},
            'venue': {'en': 'Halla'},
            'city': {'en': 'Cairo'},
          },
          'mapsUrl': 'https://maps.example.com/1',
        },
        'heroImage': 'assets/weddings/test/hero.jpg',
        'musicSource': 'assets/weddings/test/song.mp3',
        'caption': {'en': 'Welcome'},
      });
      await _pump(
        tester,
        WeddingScope(
          config: config,
          child: InvitationGate(
            onOpen: () {},
            opacity: const AlwaysStoppedAnimation<double>(1),
            isMobile: true,
          ),
        ),
        size: const Size(360, 800),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

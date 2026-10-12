import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/core/config/wedding_config.dart';
import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/features/wedding/application/music_cubit.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/music_button.dart';
import 'package:wedding/widgets/site_header.dart';

WeddingConfig _config({bool story = true, bool comments = true}) {
  return WeddingConfig.fromJson({
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
    if (story) 'story': {
      'en': ['Once upon a time'],
    },
    'showComments': comments,
  });
}

Future<void> pumpHeader(
  WidgetTester tester,
  WeddingConfig config, {
  Locale locale = const Locale('en'),
}) async {
  final cubit = MusicCubit(controller: MusicController());
  addTearDown(cubit.close);
  await tester.binding.setSurfaceSize(const Size(1200, 200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WeddingScope(
        config: config,
        child: Scaffold(
          body: SiteHeader(
            music: cubit,
            onToggleLocale: () {},
            onNavigate: (_) {},
            isMobile: false,
            scrolled: false,
            onHome: () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows every nav item when the sections are enabled', (
    tester,
  ) async {
    await pumpHeader(tester, _config());

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Our Story'), findsOneWidget);
    expect(find.text('Wishes'), findsOneWidget);
  });

  testWidgets('hides nav items for disabled sections', (tester) async {
    await pumpHeader(tester, _config(story: false, comments: false));

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Our Story'), findsNothing);
    expect(find.text('Wishes'), findsNothing);
  });

  testWidgets('renders the couple names resolved for the locale', (
    tester,
  ) async {
    await pumpHeader(tester, _config());
    expect(find.text('Adam & Eve'), findsOneWidget);
  });

  testWidgets('renders localized couple names under Arabic', (tester) async {
    await pumpHeader(tester, _config(), locale: const Locale('ar'));
    expect(find.text('آدم & حواء'), findsOneWidget);
  });

  testWidgets('includes the background-music control', (tester) async {
    await pumpHeader(tester, _config());
    expect(find.byType(MusicButton), findsOneWidget);
  });
}

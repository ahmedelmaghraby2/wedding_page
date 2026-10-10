import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/core/config/wedding_config.dart';
import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/features/wedding/presentation/sections/closing_section.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/invitation_gate.dart';

/// A config with distinct English and Arabic names so rendering can be
/// asserted per locale.
WeddingConfig _bilingualConfig() => WeddingConfig.fromJson({
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

Future<void> _pump(WidgetTester tester, Widget child, Locale locale) async {
  await tester.binding.setSurfaceSize(const Size(1200, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WeddingScope(
        config: _bilingualConfig(),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('InvitationGate localized names', () {
    testWidgets('renders English names under the English locale', (
      tester,
    ) async {
      await _pump(
        tester,
        InvitationGate(
          onOpen: () {},
          opacity: const AlwaysStoppedAnimation<double>(1),
          isMobile: false,
        ),
        const Locale('en'),
      );

      expect(find.text('Adam'), findsOneWidget);
      expect(find.text('Eve'), findsOneWidget);
      expect(find.text('آدم'), findsNothing);
      expect(find.text('حواء'), findsNothing);
    });

    testWidgets('renders Arabic names under the Arabic locale', (tester) async {
      await _pump(
        tester,
        InvitationGate(
          onOpen: () {},
          opacity: const AlwaysStoppedAnimation<double>(1),
          isMobile: false,
        ),
        const Locale('ar'),
      );

      expect(find.text('آدم'), findsOneWidget);
      expect(find.text('حواء'), findsOneWidget);
      expect(find.text('Adam'), findsNothing);
      expect(find.text('Eve'), findsNothing);
    });
  });

  group('ClosingSection localized credit and names', () {
    testWidgets('shows the English developer credit under English', (
      tester,
    ) async {
      await _pump(
        tester,
        const ClosingSection(isMobile: true),
        const Locale('en'),
      );

      expect(find.textContaining('Studio EN'), findsOneWidget);
      expect(find.textContaining('استوديو'), findsNothing);
    });

    testWidgets('shows the Arabic developer credit under Arabic', (
      tester,
    ) async {
      await _pump(
        tester,
        const ClosingSection(isMobile: true),
        const Locale('ar'),
      );

      expect(find.textContaining('استوديو'), findsOneWidget);
      expect(find.textContaining('Studio EN'), findsNothing);
    });
  });
}

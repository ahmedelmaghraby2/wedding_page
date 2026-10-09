import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('English locale resolves to LTR English strings', (
    tester,
  ) async {
    late AppLocalizations l10n;
    late TextDirection direction;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            direction = Directionality.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(l10n.weddingInvitation, 'Wedding Invitation');
    expect(direction, TextDirection.ltr);
  });

  testWidgets('Arabic locale resolves to RTL Arabic strings', (tester) async {
    late AppLocalizations l10n;
    late TextDirection direction;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            direction = Directionality.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(l10n.weddingInvitation, 'دعوة الزفاف');
    expect(direction, TextDirection.rtl);
  });
}

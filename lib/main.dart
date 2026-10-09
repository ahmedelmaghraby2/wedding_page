import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wedding/core/theme/app_theme.dart';
import 'package:wedding/features/wedding/presentation/wedding_invitation_page.dart';
import 'package:wedding/firebase_options.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Continue without Firebase if initialization fails
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = _localeFromPlatform();

  static Locale _localeFromPlatform() {
    final languageCode = PlatformDispatcher.instance.locale.languageCode;
    return languageCode == 'ar' ? const Locale('ar') : const Locale('en');
  }

  void _toggleLocale(String currentLanguageCode) {
    setState(() {
      _locale = currentLanguageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.elegantTheme,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WeddingInvitationPage(onToggleLocale: _toggleLocale),
    );
  }
}

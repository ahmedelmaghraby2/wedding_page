import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wedding/core/config/config_loader.dart';
import 'package:wedding/core/config/wedding_config.dart';
import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/core/theme/app_theme.dart';
import 'package:wedding/features/wedding/application/comments_cubit.dart';
import 'package:wedding/features/wedding/application/music_cubit.dart';
import 'package:wedding/features/wedding/data/firebase_comments_repository.dart';
import 'package:wedding/features/wedding/domain/comments_repository.dart';
import 'package:wedding/features/wedding/presentation/wedding_invitation_page.dart';
import 'package:wedding/firebase_options.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VisibilityDetectorController.instance.updateInterval = const Duration(
    milliseconds: 200,
  );

  WeddingConfig? config;
  String? error;
  try {
    config = await loadWeddingConfig();
  } on ConfigValidationException catch (exception) {
    error = exception.toString();
  } catch (exception) {
    error =
        'Unexpected error while loading the wedding configuration:\n'
        '$exception';
  }

  if (config == null) {
    assert(error != null);
    debugPrint(error);
    runApp(ConfigErrorApp(message: error!));
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (exception) {
    // Continue without Firebase: the comments feature degrades gracefully and
    // surfaces a clear "unavailable" state instead of crashing the page.
    debugPrint('Firebase initialization failed: $exception');
  }

  runApp(
    MyApp(
      config: config,
      music: MusicCubit(
        controller: MusicController(assetPath: config.musicAssetSource),
      ),
      commentsRepository: FirebaseCommentsRepository(
        weddingId: config.weddingId,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.config,
    required this.music,
    required this.commentsRepository,
  });

  final WeddingConfig config;
  final MusicCubit music;
  final CommentsRepository commentsRepository;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = _localeFromPlatform();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.music.warmUp();
    });
  }

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
  void dispose() {
    widget.music.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WeddingScope(
      config: widget.config,
      child: MultiBlocProvider(
        providers: [
          RepositoryProvider<CommentsRepository>.value(
            value: widget.commentsRepository,
          ),
          BlocProvider<CommentsCubit>(
            create: (context) =>
                CommentsCubit(context.read<CommentsRepository>()),
          ),
          BlocProvider<MusicCubit>.value(value: widget.music),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) =>
              context.wedding.pageTitleFor(context.localeCode),
          theme: AppTheme.build(_locale),
          locale: _locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WeddingInvitationPage(
            onToggleLocale: _toggleLocale,
            music: widget.music,
          ),
        ),
      ),
    );
  }
}

/// Shown when the wedding configuration is missing or invalid — a loud,
/// self-descriptive failure instead of a blank page.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: SelectableText(
                message,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

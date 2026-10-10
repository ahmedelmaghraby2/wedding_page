import 'dart:convert';

import 'package:flutter/services.dart';

import 'wedding_config.dart';

/// Asset key of the wedding configuration, overridable at build time:
/// `flutter build web --dart-define=WEDDING_CONFIG=config/wedding_demo.json`
const String kWeddingConfigAsset =
    String.fromEnvironment('WEDDING_CONFIG', defaultValue: 'config/wedding_config.json');

/// Loads and validates the wedding configuration from the app bundle.
///
/// [overridePath] is mainly used by tooling and tests; the app itself reads the
/// path baked in via --dart-define at build time.
Future<WeddingConfig> loadWeddingConfig({String? overridePath}) async {
  final path = overridePath ?? kWeddingConfigAsset;
  String source;
  try {
    source = await rootBundle.loadString(path);
  } on Exception {
    throw ConfigValidationException([
      'Could not load config asset "$path".',
      'Build with --dart-define=WEDDING_CONFIG=config/<your>.json',
    ]);
  }
  dynamic decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException catch (e) {
    throw ConfigValidationException(['"$path" is not valid JSON: ${e.message}']);
  }
  if (decoded is! Map<String, dynamic>) {
    throw ConfigValidationException(
      ['"$path" must contain a JSON object at the top level.'],
    );
  }
  return WeddingConfig.fromJson(decoded);
}
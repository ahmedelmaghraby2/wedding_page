// Command-line validation for wedding configurations.
//
// ignore_for_file: avoid_print — this is a CLI tool, stdout is its output.
//
// Usage (from the project root):
//   dart run tool/validate_config.dart
//   dart run tool/validate_config.dart config/wedding_demo.json
//   dart run tool/validate_config.dart config/wedding_config.json config/wedding_demo.json
//
// Checks:
//   1. Every listed config parses and passes WeddingConfig validation.
//   2. Every referenced asset (hero, song, gallery) exists on disk.
//      config/wedding_demo.json is an exemplar placeholder that is never
//      deployed, so its assets do not exist — validate it with
//      --ignore-missing-assets to check the schema only.
//   3. weddingId values are unique across the given configs.
//
// Exits with code 0 when everything is valid, 1 otherwise.

import 'dart:io';

import 'package:wedding/core/config/wedding_config.dart';

const _defaultConfigs = ['config/wedding_config.json'];

int main(List<String> args) {
  final ignoreMissingAssets = args.contains('--ignore-missing-assets');
  final configs = args.where((arg) => !arg.startsWith('--')).toList();
  final finalConfigs = configs.isEmpty ? _defaultConfigs : configs;
  final issues = <String>[];
  final seenIds = <String, String>{};

  for (final path in finalConfigs) {
    print('== Checking $path');

    WeddingConfig config;
    try {
      final source = File(path).readAsStringSync();
      config = WeddingConfig.fromJsonString(source, path: path);
    } catch (error) {
      issues.add('$path: $error');
      print('  FAILED');
      continue;
    }

    if (!ignoreMissingAssets) {
      final related = <String, String>{
        'heroImage': config.heroImage,
        'musicSource': config.musicSource,
        ...{
          for (var i = 0; i < config.gallery.length; i++)
            'gallery[$i]': config.gallery[i],
        },
      };
      for (final entry in related.entries) {
        if (!File(entry.value).existsSync()) {
          issues.add('$path: "${entry.key}" "${entry.value}" does not exist.');
        }
      }
    }

    final prior = seenIds[config.weddingId];
    if (prior != null && prior != path) {
      issues.add(
        'duplicate weddingId "${config.weddingId}" in "$path" and "$prior".',
      );
    } else {
      seenIds[config.weddingId] = path;
    }

    print(
      '  weddingId ${config.weddingId}'
      ' | ${config.groom.resolve('en')} & ${config.bride.resolve('en')}'
      ' | countdown ${config.showCountdown ? 'on' : 'off'}'
      ' | comments ${config.showComments ? 'on' : 'off'}'
      ' | story ${config.hasStory ? 'present' : 'absent'}'
      ' | ${config.gallery.length} gallery image(s)',
    );
    print('  OK');
  }

  if (issues.isNotEmpty) {
    stderr.writeln('\nValidation FAILED:');
    for (final issue in issues) {
      stderr.writeln('  - $issue');
    }
    exitCode = 1;
  } else {
    print('\nAll ${finalConfigs.length} config(s) valid.');
  }
  return exitCode;
}

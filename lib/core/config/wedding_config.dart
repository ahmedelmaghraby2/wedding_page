import 'dart:convert';

/// Thrown when a wedding configuration fails validation.
class ConfigValidationException implements Exception {
  const ConfigValidationException(this.issues);

  final List<String> issues;

  bool get isEmpty => issues.isEmpty;

  @override
  String toString() => [
    'Wedding configuration is invalid:',
    ...issues.map((e) => '  - $e'),
  ].join('\n');
}

/// A simple per-language string dictionary.
class LocalizedText {
  const LocalizedText(this.values);

  final Map<String, String> values;

  /// Fetches the value for [languageCode], falling back to English, then ''.
  String resolve(String languageCode) {
    final direct = values[languageCode];
    if (direct != null && direct.trim().isNotEmpty) return direct;
    final english = values['en'];
    if (english != null && english.trim().isNotEmpty) return english;
    return values.values.isEmpty ? '' : values.values.first;
  }

  bool isEmptyFor(String languageCode) => resolve(languageCode).isEmpty;

  static LocalizedText? maybeFromJson(
    Object? json,
    List<String> issues,
    String path,
  ) {
    if (json == null) return null;
    if (json is! Map<String, dynamic>) {
      issues.add('"$path" must be an object of language codes to strings.');
      return null;
    }
    final map = json.map((k, v) => MapEntry(k.toString(), v.toString()));
    if ((map['en'] ?? '').trim().isEmpty) {
      issues.add('"$path.en" is required.');
    }
    return LocalizedText(map);
  }
}

/// Wedding event details plus everything needed to render them.
class WeddingEvent {
  const WeddingEvent({
    required this.countdownDateTime,
    required this.date,
    required this.time,
    required this.venue,
    required this.city,
    required this.mapsUrl,
  });

  final DateTime? countdownDateTime;
  final LocalizedText date;
  final LocalizedText time;
  final LocalizedText venue;
  final LocalizedText city;
  final String mapsUrl;
}

/// Fully validated wedding configuration — the single source of truth.
class WeddingConfig {
  const WeddingConfig({
    required this.weddingId,
    required this.title,
    required this.developer,
    required this.groom,
    required this.bride,
    required this.event,
    required this.heroImage,
    required this.musicSource,
    required this.caption,
    required this.story,
    required this.gallery,
    required this.showCountdown,
    required this.showComments,
  });

  final String weddingId;

  /// Page/document title per language, e.g. "Ahmed & Aya Wedding".
  final LocalizedText title;

  /// Developer credit shown in the footer, per language.
  ///
  /// Accepts either a plain string (treated as the English value) or a
  /// `{"en": ..., "ar": ...}` map.
  final LocalizedText developer;

  /// Groom's name, per language. Resolved by locale wherever it is rendered.
  final LocalizedText groom;

  /// Bride's name, per language. Resolved by locale wherever it is rendered.
  final LocalizedText bride;
  final WeddingEvent event;

  /// Flutter asset key (starts with `assets/`).
  final String heroImage;

  /// Flutter asset key (starts with `assets/`). May point to any song.
  final String musicSource;
  final LocalizedText caption;

  /// `languageCode -> story paragraphs`.
  final Map<String, List<String>> story;
  final List<String> gallery;

  /// Whether the countdown and guest-wishes sections are built at all.
  final bool showCountdown;
  final bool showComments;

  String get monogramLabel {
    final g = groom.resolve('en').trim();
    final b = bride.resolve('en').trim();
    if (g.isEmpty || b.isEmpty) return '&';
    return '${g[0]}${b[0]}'.toUpperCase();
  }

  /// Browser/tab title for [languageCode].
  ///
  /// Falls back to the couple's names when no localized `title` exists.
  String pageTitleFor(String languageCode) {
    final resolvedTitle = title.resolve(languageCode);
    if (resolvedTitle.trim().isNotEmpty) return resolvedTitle;
    return '${groom.resolve('en')} & ${bride.resolve('en')}';
  }

  /// English page title, kept for callers without a locale (e.g. tooling).
  String get pageTitle => pageTitleFor('en');

  bool get hasStory => story.isNotEmpty;

  List<String> storyFor(String languageCode) {
    final resolved = story[languageCode];
    if (resolved != null && resolved.isNotEmpty) return resolved;
    final fallback = story['en'];
    return fallback ?? const [];
  }

  List<String> get galleryImages => gallery.isNotEmpty ? gallery : [heroImage];

  /// AudioPlayer's [AssetSource] expects the key relative to `assets/`.
  String get musicAssetSource => musicSource.startsWith('assets/')
      ? musicSource.substring('assets/'.length)
      : musicSource;

  factory WeddingConfig.fromJson(Map<String, dynamic> json) {
    final issues = <String>[];

    final weddingId = _requiredString(json, 'weddingId', issues)?.trim();
    if (weddingId != null &&
        !RegExp(r'^[a-z0-9][a-z0-9-]*$').hasMatch(weddingId)) {
      issues.add(
        '"weddingId" must be lowercase alphanumeric with dashes (e.g. ahmed-aya).',
      );
    }

    if (json['title'] == null) issues.add('"title" is required.');
    final title = LocalizedText.maybeFromJson(json['title'], issues, 'title');
    final developer = _requiredLocalizedText(
      json['developer'],
      issues,
      'developer',
    );
    final groom = _requiredLocalizedText(json['groom'], issues, 'groom');
    final bride = _requiredLocalizedText(json['bride'], issues, 'bride');
    if (json['caption'] == null) issues.add('"caption" is required.');
    final caption = LocalizedText.maybeFromJson(
      json['caption'],
      issues,
      'caption',
    );
    final heroImage = _requiredAsset(json, 'heroImage', issues);
    final musicSource = _requiredAsset(json, 'musicSource', issues);

    final eventJson = json['event'];
    if (eventJson is! Map<String, dynamic>) {
      issues.add('"event" must be an object.');
    }
    final event = eventJson is Map<String, dynamic>
        ? _parseEvent(eventJson, issues)
        : null;

    final story = _parseStory(json['story'], issues);
    final gallery = _parseGallery(json['gallery'], issues);

    final showCountdown = json['showCountdown'] as bool? ?? true;
    final showComments = json['showComments'] as bool? ?? true;

    if (issues.isNotEmpty) {
      throw ConfigValidationException(issues);
    }

    return WeddingConfig(
      weddingId: weddingId!,
      title: title!,
      developer: developer!,
      groom: groom!,
      bride: bride!,
      event: event!,
      heroImage: heroImage,
      musicSource: musicSource,
      caption: caption!,
      story: story,
      gallery: gallery,
      showCountdown: showCountdown,
      showComments: showComments,
    );
  }

  static WeddingEvent _parseEvent(
    Map<String, dynamic> json,
    List<String> issues,
  ) {
    final raw = (_asString(json, 'countdownDateTime') ?? '').trim();
    DateTime? instant;
    if (raw.isEmpty) {
      issues.add(
        '"event.countdownDateTime" is required (ISO-8601 with offset).',
      );
    } else {
      instant = DateTime.tryParse(raw);
      if (instant == null) {
        issues.add(
          '"event.countdownDateTime" must be ISO-8601, e.g. 2026-10-28T20:00:00+03:00.',
        );
      }
    }

    final display = json['display'];
    if (display is! Map<String, dynamic>) {
      issues.add('"event.display" must be an object.');
      return const WeddingEvent(
        countdownDateTime: null,
        date: LocalizedText({}),
        time: LocalizedText({}),
        venue: LocalizedText({}),
        city: LocalizedText({}),
        mapsUrl: '',
      );
    }
    final date = LocalizedText.maybeFromJson(
      display['date'],
      issues,
      'event.display.date',
    );
    final time = LocalizedText.maybeFromJson(
      display['time'],
      issues,
      'event.display.time',
    );
    final venue = LocalizedText.maybeFromJson(
      display['venue'],
      issues,
      'event.display.venue',
    );
    final city = LocalizedText.maybeFromJson(
      display['city'],
      issues,
      'event.display.city',
    );

    final mapsUrl = (_asString(json, 'mapsUrl') ?? '').trim();
    if (mapsUrl.isEmpty) {
      issues.add('"event.mapsUrl" is required.');
    } else if (!mapsUrl.startsWith('http://') &&
        !mapsUrl.startsWith('https://')) {
      issues.add('"event.mapsUrl" must start with http(s)://');
    }

    return WeddingEvent(
      countdownDateTime: instant,
      date: date ?? LocalizedText(const {}),
      time: time ?? LocalizedText(const {}),
      venue: venue ?? LocalizedText(const {}),
      city: city ?? LocalizedText(const {}),
      mapsUrl: mapsUrl,
    );
  }

  static Map<String, List<String>> _parseStory(
    Object? json,
    List<String> issues,
  ) {
    if (json == null) return const {};
    if (json is! Map<String, dynamic>) {
      issues.add(
        '"story" must be an object of language codes to string arrays.',
      );
      return const {};
    }
    final result = <String, List<String>>{};
    json.forEach((lang, raw) {
      if (raw is! List) {
        issues.add('"story.$lang" must be an array of paragraphs.');
        return;
      }
      final paragraphs = raw
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (paragraphs.isEmpty) {
        issues.add('"story.$lang" must contain at least one paragraph.');
        return;
      }
      result[lang] = paragraphs;
    });
    return result;
  }

  static List<String> _parseGallery(Object? json, List<String> issues) {
    if (json == null) return const [];
    if (json is! List) {
      issues.add('"gallery" must be an array of asset keys.');
      return const [];
    }
    final list = json.whereType<String>().toList();
    for (final key in list) {
      if (!key.trim().startsWith('assets/')) {
        issues.add('"gallery" entry "$key" must start with assets/.');
      }
    }
    return list;
  }

  static String? _requiredString(
    Map<String, dynamic> json,
    String key,
    List<String> issues,
  ) {
    final value = (_asString(json, key) ?? '').trim();
    if (value.isEmpty) issues.add('"$key" is required.');
    return value.isEmpty ? null : value;
  }

  /// Parses a required localized field.
  ///
  /// Accepts either a plain string — kept for backward compatibility and
  /// treated as the English value — or a `{"en": ..., "ar": ...}` map.
  /// Returns `null` (and records an issue) when the value is missing or of
  /// the wrong shape.
  static LocalizedText? _requiredLocalizedText(
    Object? value,
    List<String> issues,
    String path,
  ) {
    if (value == null) {
      issues.add('"$path" is required.');
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        issues.add('"$path" is required.');
        return null;
      }
      return LocalizedText({'en': trimmed});
    }
    if (value is Map<String, dynamic>) {
      final parsed = LocalizedText.maybeFromJson(value, issues, path);
      if (parsed == null) issues.add('"$path" is required.');
      return parsed;
    }
    issues.add(
      '"$path" must be a string or an object of language codes to strings.',
    );
    return null;
  }

  static String _requiredAsset(
    Map<String, dynamic> json,
    String key,
    List<String> issues,
  ) {
    final value = (_asString(json, key) ?? '').trim();
    if (value.isEmpty) {
      issues.add('"$key" is required.');
    } else if (!value.startsWith('assets/')) {
      issues.add('"$key" must be an assets key starting with "assets/".');
    }
    return value.isEmpty ? key : value;
  }

  static String? _asString(Map<String, dynamic> json, String key) {
    final v = json[key];
    return v is String ? v : null;
  }

  static WeddingConfig fromJsonString(String source, {String? path}) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw ConfigValidationException([
        '${path ?? 'Config'} must contain a JSON object at the top level.',
      ]);
    }
    return WeddingConfig.fromJson(decoded);
  }
}

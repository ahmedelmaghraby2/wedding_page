import 'package:flutter/widgets.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

import 'wedding_config.dart';

/// Exposes the active [WeddingConfig] to the whole widget tree.
class WeddingScope extends InheritedWidget {
  const WeddingScope({super.key, required this.config, required super.child});

  final WeddingConfig config;

  /// Resolves the config below [context]. Throws if missing.
  static WeddingConfig of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WeddingScope>();
    assert(scope != null, 'No WeddingScope found above this context.');
    return scope!.config;
  }

  /// Resolves the config below [context] without forcing a rebuild.
  static WeddingConfig ofTree(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<WeddingScope>();
    return scope?.config ?? WeddingScope.of(context);
  }

  @override
  bool updateShouldNotify(covariant WeddingScope oldWidget) =>
      oldWidget.config != config;
}

/// Convenience accessors available anywhere below a [WeddingScope].
extension WeddingContext on BuildContext {
  WeddingConfig get wedding => WeddingScope.of(this);

  AppLocalizations get l10n => AppLocalizations.of(this);

  /// "en", "ar", ... for the active locale.
  String get localeCode => Localizations.localeOf(this).languageCode;
}
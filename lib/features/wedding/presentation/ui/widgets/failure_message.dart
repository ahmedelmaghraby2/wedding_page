import 'package:wedding/features/wedding/domain/comment_failure.dart';
import 'package:wedding/core/l10n/generated/app_localizations.dart';

/// Maps a domain [CommentFailure] to a localized, user-facing message.
///
/// Lives in the presentation layer because it depends on `AppLocalizations`;
/// the application/domain layers stay localization-free.
String messageForFailure(AppLocalizations l10n, CommentFailure failure) {
  switch (failure) {
    case CommentFailure.invalidCode:
      return l10n.incorrectAccessCode;
    case CommentFailure.notFound:
      return l10n.commentNotFound;
    case CommentFailure.network:
      return l10n.networkError;
    case CommentFailure.permissionDenied:
      return l10n.permissionError;
    case CommentFailure.invalidData:
    case CommentFailure.conflict:
    case CommentFailure.firebaseUnavailable:
    case CommentFailure.unknown:
      return l10n.unknownError;
  }
}

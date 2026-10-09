import 'package:wedding/features/wedding/data/wedding_comment_repository.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

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

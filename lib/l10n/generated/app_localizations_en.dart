// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Adel & Rahma Wedding';

  @override
  String get weddingInvitation => 'Wedding Invitation';

  @override
  String get heroSubtitle =>
      'We invite you to share in our joy on this special day';

  @override
  String get weddingMessage =>
      'In the name of God, we begin the most beautiful story ❤️\n\nA moment long awaited, and a joy we wish becomes even more beautiful with you here with us.\n\nHappy to share our forever with you.\n\nAdel & Rahma';

  @override
  String get weddingDetails => 'Wedding Details';

  @override
  String get detailDate => 'Date';

  @override
  String get detailTime => 'Time';

  @override
  String get detailVenue => 'Venue';

  @override
  String get detailLocation => 'Location';

  @override
  String get weddingDate => '16/10/2026';

  @override
  String get weddingTime => '8:00 PM';

  @override
  String get venueName => 'Maryal Hall';

  @override
  String get weddingCity => 'Port Said, Egypt';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get mapsOpenFailed => 'Could not open Google Maps. Please try again.';

  @override
  String get guestWishes => 'Guest Wishes';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'Your full name';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get fullNameTooShort => 'Full name must be at least 2 characters';

  @override
  String get fullNameTooLong => 'Full name must be less than 50 characters';

  @override
  String get commentLabel => 'Comment';

  @override
  String get commentHint => 'Leave your congratulations...';

  @override
  String get commentRequired => 'Comment is required';

  @override
  String get commentTooLong => 'Comment must be less than 500 characters';

  @override
  String get addEmoji => 'Add emoji';

  @override
  String get sendYourWish => 'Send Your Wish';

  @override
  String get accessCodeLabel => 'Comment Access Code';

  @override
  String get accessCodeHint => 'e.g. A7m#K2p!';

  @override
  String get accessCodeRequired => 'Access code is required';

  @override
  String get accessCodeTooShort => 'Access code must be at least 8 characters';

  @override
  String get accessCodeInfoTitle => 'Keep this code safe';

  @override
  String get accessCodeInfoBody =>
      'This code is private. Keep it somewhere safe. You will need it if you want to edit or delete your comment later.';

  @override
  String get generateAccessCode => 'Generate a new access code';

  @override
  String get copyAccessCode => 'Copy access code';

  @override
  String get copiedToClipboard => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get close => 'Close';

  @override
  String get guest => 'Guest';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get editTooltip => 'Edit comment';

  @override
  String get deleteTooltip => 'Delete comment';

  @override
  String get enterAccessCodeTitle => 'Enter your Comment Access Code';

  @override
  String get accessCodeObscuredHint => 'Your private access code';

  @override
  String get verify => 'Verify';

  @override
  String get incorrectAccessCode => 'Incorrect access code.';

  @override
  String get editCommentTitle => 'Edit your comment';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteCommentTitle => 'Delete comment';

  @override
  String get deleteConfirmTitle => 'Delete this comment?';

  @override
  String get deleteConfirmBody => 'This cannot be undone.';

  @override
  String get commentAdded => 'Comment added successfully';

  @override
  String get commentUpdated => 'Comment updated successfully';

  @override
  String get commentDeleted => 'Comment deleted successfully';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get submitFailed =>
      'Something went wrong while submitting your wish. Please try again.';

  @override
  String get loadFailed =>
      'Something went wrong while loading wishes. Please try again.';

  @override
  String get loadingWishes => 'Loading wishes...';

  @override
  String get noComments => 'No wishes yet. Be the first to leave a wish!';

  @override
  String get commentNotFound => 'This comment no longer exists.';

  @override
  String get networkError =>
      'Network error. Please check your connection and try again.';

  @override
  String get permissionError => 'You do not have permission to do this.';

  @override
  String get unknownError => 'Something went wrong. Please try again.';

  @override
  String get changeLanguage => 'Change language';
}

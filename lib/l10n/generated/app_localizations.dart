import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Adel & Rahma Wedding'**
  String get appTitle;

  /// No description provided for @weddingInvitation.
  ///
  /// In en, this message translates to:
  /// **'Wedding Invitation'**
  String get weddingInvitation;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We invite you to share in our joy on this special day'**
  String get heroSubtitle;

  /// No description provided for @weddingMessage.
  ///
  /// In en, this message translates to:
  /// **'In the name of God, we begin the most beautiful story ❤️\n\nA moment long awaited, and a joy we wish becomes even more beautiful with you here with us.\n\nHappy to share our forever with you.\n\nAdel & Rahma'**
  String get weddingMessage;

  /// No description provided for @weddingDetails.
  ///
  /// In en, this message translates to:
  /// **'Wedding Details'**
  String get weddingDetails;

  /// No description provided for @detailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get detailDate;

  /// No description provided for @detailTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get detailTime;

  /// No description provided for @detailVenue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get detailVenue;

  /// No description provided for @detailLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get detailLocation;

  /// No description provided for @weddingDate.
  ///
  /// In en, this message translates to:
  /// **'16/10/2026'**
  String get weddingDate;

  /// No description provided for @weddingTime.
  ///
  /// In en, this message translates to:
  /// **'8:00 PM'**
  String get weddingTime;

  /// No description provided for @venueName.
  ///
  /// In en, this message translates to:
  /// **'Maryal Hall'**
  String get venueName;

  /// No description provided for @weddingCity.
  ///
  /// In en, this message translates to:
  /// **'Port Said, Egypt'**
  String get weddingCity;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @googleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get googleMaps;

  /// No description provided for @mapsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps. Please try again.'**
  String get mapsOpenFailed;

  /// No description provided for @guestWishes.
  ///
  /// In en, this message translates to:
  /// **'Guest Wishes'**
  String get guestWishes;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get fullNameHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @fullNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Full name must be at least 2 characters'**
  String get fullNameTooShort;

  /// No description provided for @fullNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Full name must be less than 50 characters'**
  String get fullNameTooLong;

  /// No description provided for @commentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentLabel;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Leave your congratulations...'**
  String get commentHint;

  /// No description provided for @commentRequired.
  ///
  /// In en, this message translates to:
  /// **'Comment is required'**
  String get commentRequired;

  /// No description provided for @commentTooLong.
  ///
  /// In en, this message translates to:
  /// **'Comment must be less than 500 characters'**
  String get commentTooLong;

  /// No description provided for @addEmoji.
  ///
  /// In en, this message translates to:
  /// **'Add emoji'**
  String get addEmoji;

  /// No description provided for @sendYourWish.
  ///
  /// In en, this message translates to:
  /// **'Send Your Wish'**
  String get sendYourWish;

  /// No description provided for @accessCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment Access Code'**
  String get accessCodeLabel;

  /// No description provided for @accessCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. A7m#K2p!'**
  String get accessCodeHint;

  /// No description provided for @accessCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Access code is required'**
  String get accessCodeRequired;

  /// No description provided for @accessCodeTooShort.
  ///
  /// In en, this message translates to:
  /// **'Access code must be at least 8 characters'**
  String get accessCodeTooShort;

  /// No description provided for @accessCodeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep this code safe'**
  String get accessCodeInfoTitle;

  /// No description provided for @accessCodeInfoBody.
  ///
  /// In en, this message translates to:
  /// **'This code is private. Keep it somewhere safe. You will need it if you want to edit or delete your comment later.'**
  String get accessCodeInfoBody;

  /// No description provided for @generateAccessCode.
  ///
  /// In en, this message translates to:
  /// **'Generate a new access code'**
  String get generateAccessCode;

  /// No description provided for @copyAccessCode.
  ///
  /// In en, this message translates to:
  /// **'Copy access code'**
  String get copyAccessCode;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit comment'**
  String get editTooltip;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get deleteTooltip;

  /// No description provided for @enterAccessCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your Comment Access Code'**
  String get enterAccessCodeTitle;

  /// No description provided for @accessCodeObscuredHint.
  ///
  /// In en, this message translates to:
  /// **'Your private access code'**
  String get accessCodeObscuredHint;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @incorrectAccessCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect access code.'**
  String get incorrectAccessCode;

  /// No description provided for @editCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your comment'**
  String get editCommentTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get deleteCommentTitle;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteConfirmBody;

  /// No description provided for @commentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added successfully'**
  String get commentAdded;

  /// No description provided for @commentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Comment updated successfully'**
  String get commentUpdated;

  /// No description provided for @commentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Comment deleted successfully'**
  String get commentDeleted;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @submitFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while submitting your wish. Please try again.'**
  String get submitFailed;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading wishes. Please try again.'**
  String get loadFailed;

  /// No description provided for @loadingWishes.
  ///
  /// In en, this message translates to:
  /// **'Loading wishes...'**
  String get loadingWishes;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No wishes yet. Be the first to leave a wish!'**
  String get noComments;

  /// No description provided for @commentNotFound.
  ///
  /// In en, this message translates to:
  /// **'This comment no longer exists.'**
  String get commentNotFound;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get networkError;

  /// No description provided for @permissionError.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do this.'**
  String get permissionError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknownError;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

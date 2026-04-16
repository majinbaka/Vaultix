import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// Password manager screen title
  ///
  /// In en, this message translates to:
  /// **'Password Manager'**
  String get pmTitle;

  /// Button to add a new account
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get pmAddAccount;

  /// Field label: site or app name
  ///
  /// In en, this message translates to:
  /// **'Site / App'**
  String get pmSiteName;

  /// Field label: username
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get pmUsername;

  /// Field label: password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get pmPassword;

  /// Button to save an account
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pmSave;

  /// Button to cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pmCancel;

  /// Button to delete an account
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pmDelete;

  /// Empty state hint for password manager
  ///
  /// In en, this message translates to:
  /// **'No accounts yet. Tap + to add one.'**
  String get pmEmptyHint;

  /// Master password screen title
  ///
  /// In en, this message translates to:
  /// **'Password Vault'**
  String get pmMasterTitle;

  /// Header when creating a new vault
  ///
  /// In en, this message translates to:
  /// **'Create Master Password'**
  String get pmMasterNewHeader;

  /// Header when unlocking existing vault
  ///
  /// In en, this message translates to:
  /// **'Unlock Vault'**
  String get pmMasterUnlockHeader;

  /// Master password field hint
  ///
  /// In en, this message translates to:
  /// **'Master password'**
  String get pmMasterHint;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get pmMasterConfirmHint;

  /// Button to create the vault
  ///
  /// In en, this message translates to:
  /// **'Create Vault'**
  String get pmMasterCreate;

  /// Button to unlock the vault
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get pmMasterUnlock;

  /// Validation: passwords mismatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get pmMasterMismatch;

  /// Error when wrong password entered
  ///
  /// In en, this message translates to:
  /// **'Wrong master password'**
  String get pmMasterWrong;

  /// Validation: password too short
  ///
  /// In en, this message translates to:
  /// **'Must be at least 8 characters'**
  String get pmMasterTooShort;

  /// Error shown during brute-force lockout with countdown
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Try again in {seconds}s.'**
  String pmLockedOut(int seconds);

  /// Security description on the master password screen
  ///
  /// In en, this message translates to:
  /// **'Your passwords are encrypted with AES-256-GCM.\nThe key is derived with Argon2id — only you can unlock them.'**
  String get pmEncryptionInfo;

  /// Snackbar message when password is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copiedToClipboard;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get pmTitle => 'Password Manager';

  @override
  String get pmAddAccount => 'Add Account';

  @override
  String get pmSiteName => 'Site / App';

  @override
  String get pmUsername => 'Username';

  @override
  String get pmPassword => 'Password';

  @override
  String get pmSave => 'Save';

  @override
  String get pmCancel => 'Cancel';

  @override
  String get pmDelete => 'Delete';

  @override
  String get pmEmptyHint => 'No accounts yet. Tap + to add one.';

  @override
  String get pmMasterTitle => 'Password Vault';

  @override
  String get pmMasterNewHeader => 'Create Master Password';

  @override
  String get pmMasterUnlockHeader => 'Unlock Vault';

  @override
  String get pmMasterHint => 'Master password';

  @override
  String get pmMasterConfirmHint => 'Confirm password';

  @override
  String get pmMasterCreate => 'Create Vault';

  @override
  String get pmMasterUnlock => 'Unlock';

  @override
  String get pmMasterMismatch => 'Passwords do not match';

  @override
  String get pmMasterWrong => 'Wrong master password';

  @override
  String get pmMasterTooShort => 'Must be at least 8 characters';

  @override
  String pmLockedOut(int seconds) {
    return 'Too many failed attempts. Try again in ${seconds}s.';
  }

  @override
  String get pmEncryptionInfo => 'Your passwords are encrypted with AES-256-GCM.\nThe key is derived with Argon2id — only you can unlock them.';

  @override
  String get copiedToClipboard => 'Copied!';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';
}

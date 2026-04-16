# Vaultix

A secure, cross-platform password manager built with Flutter.

## Features

- **AES-256-GCM encryption** — vault data encrypted with a per-vault key
- **Argon2id key derivation** — master password never stored; used only to derive a KEK
- **Hardware-backed vault key** — stored in OS keystore (Android Keystore / iOS Keychain)
- **Brute-force protection** — exponential lockout (3 fails → 5 s, doubles each attempt, capped at 1 h)
- **Idle auto-lock** — vault locks automatically after 5 minutes of inactivity
- **CRUD vault entries** — add, edit, delete accounts (site name, username, password)
- **Localized UI** — English and Vietnamese

## Security Model (v3)

| Layer | Detail |
|---|---|
| Vault key | 32-byte random key stored in OS keystore |
| KEK | Argon2id(masterPassword, salt) — 128 MiB / 3 iter on native; 16 MiB / 2 iter on Web |
| Wrap | AES-256-GCM(KEK, vaultKey) in SharedPreferences as `wrapped_key` |
| Data | AES-256-GCM(vaultKey, JSON accounts) in SharedPreferences as `box` |
| Password change | Re-wraps vault key only; data never re-encrypted (O(1)) |

## Tech Stack

- Flutter + Dart (SDK ^3.11.0)
- `cryptography` ^2.7.0 (Argon2id + AES-256-GCM)
- `sqflite_common_ffi` ^2.3.4+4
- `shared_preferences` ^2.3.5
- `flutter_secure_storage` ^9.2.4
- `google_fonts` ^6.2.1 (Inter)

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.0
- Dart SDK ^3.11.0

### Run

```bash
flutter pub get
flutter run
```

### Localization

```bash
flutter gen-l10n
```

## Architecture

Feature-first MVVM:

```
lib/
├── main.dart                        ← calls bootstrap() only
├── bootstrap.dart                   ← init → runApp
├── app/app.dart                     ← MaterialApp config
├── core/theme/                      ← AppPalette, AppTextStyles, AppThemeNotifier
├── l10n/                            ← ARB files + generated localizations
└── features/password_manager/
    ├── vault_service.dart           ← all crypto ops
    ├── master_password_screen.dart  ← create / unlock vault
    ├── password_manager_screen.dart ← account list
    ├── models/                      ← Account, VaultSession
    ├── presentation/viewmodels/     ← MasterPasswordViewModel, PasswordManagerViewModel
    └── widgets/                     ← AccountFormSheet, VaultTextFormField
```

## License

MIT

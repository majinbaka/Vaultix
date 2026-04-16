# Claude Code Instructions

## Project overview

**Vaultix** — Flutter password manager app.
The architecture follows **feature-first MVVM** with a clean bootstrap entry-point pattern.

**Stack:**
- Flutter + Dart (SDK ^3.11.0)
- Localization: `flutter_localizations` + `intl` (ARB-based, via `flutter gen-l10n`)
- Theming: `AppPalette` / `AppThemeProvider` / `AppThemeNotifier` (defined in `core/theme/theme_controller.dart`)
- Storage: `sqflite_common_ffi` ^2.3.4+4 (FFI on desktop), `shared_preferences` ^2.3.5, `flutter_secure_storage` ^9.2.4
- Encryption: `cryptography` ^2.7.0 — Argon2id (KDF) + AES-256-GCM (vault format v3)
- Fonts: `google_fonts` ^6.2.1 (Inter)
- Dev: `flutter_lints` ^6.0.0

---

## Architecture

```
lib/
├── main.dart                          ← calls bootstrap() only
├── bootstrap.dart                     ← init (bindings, sqflite FFI, theme) → runApp
├── app/app.dart                       ← MainApp widget + MaterialApp config
├── core/
│   └── theme/
│       ├── app_colors.dart            ← AppPalette (midnight, sky)
│       ├── app_feature_colors.dart    ← AppFeatureColors (semantic color helpers)
│       ├── app_styles.dart            ← AppTextStyles, AppDecorations, AppButtonStyles, AppFieldStyles, AppRadii
│       └── theme_controller.dart      ← AppThemeNotifier (ChangeNotifier) + AppThemeProvider (InheritedNotifier)
├── l10n/                              ← ARB files + generated localizations (en, vi)
└── features/
    └── password_manager/
        ├── vault_service.dart         ← VaultService (static) — all crypto ops (Argon2id + AES-256-GCM)
        ├── master_password_screen.dart ← first screen: vault creation or unlock
        ├── password_manager_screen.dart ← main vault screen (account list)
        ├── models/
        │   ├── account.dart           ← Account entity (id, siteName, username, password)
        │   └── vault_session.dart     ← VaultSession (holds in-memory vault key + decrypted accounts)
        ├── presentation/
        │   └── viewmodels/
        │       ├── master_password_viewmodel.dart  ← handles vault creation/unlock flow
        │       └── password_manager_viewmodel.dart ← idle timer, CRUD, debounced persist
        └── widgets/
            ├── account_form_sheet.dart    ← bottom sheet for add/edit account
            └── vault_text_form_field.dart ← styled text field for vault forms
```

### Vault security model (v3)

| Layer | Detail |
|---|---|
| **Vault key** | 32-byte random key; hardware-backed via OS keystore (Android Keystore / iOS Keychain) |
| **KEK** | Argon2id(masterPassword, salt) — 128 MiB / 3 iter / 1 par on native; 16 MiB / 2 iter on Web |
| **Wrap** | AES-256-GCM(KEK, vaultKey) stored in SharedPreferences as `wrapped_key` |
| **Data** | AES-256-GCM(vaultKey, JSON accounts) stored in SharedPreferences as `box` |
| **Brute-force** | Exponential lockout: 3 fails → 5 s, doubles each fail, cap 1 h |
| **Password change** | Re-wraps vault key only; data never re-encrypted (O(1)) |
| **Idle lock** | Auto-lock after 5 minutes of inactivity (PasswordManagerViewModel) |

### MVVM conventions

| Layer | Location | Rule |
|---|---|---|
| View | `*_screen.dart` at feature root or `presentation/views/` | UI only, no direct crypto/API calls |
| ViewModel | `presentation/viewmodels/*_viewmodel.dart` | State + business flow; extends `ChangeNotifier` |
| Model (data) | `models/*.dart` | Parse/serialize only |
| Service | `*_service.dart` | Platform API / crypto (e.g. `VaultService`) |
| Shared widget | `widgets/*.dart` | Reusable UI components scoped to the feature |

---

## Rules

> **Skills for common workflows:** use `/workflow` for the full 8-phase cycle, `/review` for performance & security checklists, `/flutter` to run analyze/test/l10n.

Rules below are **always-on constraints**.

---

### CODE QUALITY RULES

### Rule 2 — Keep files under 500 lines

Every Dart source file **must not exceed 500 lines**.

When a file approaches 500 lines:
- Split widgets into smaller sub-widgets in separate files
- Extract logic into dedicated files
- Break large classes into mixins or smaller collaborating classes

### Rule 3 — Always use i18n for every user-visible string

**Never** hardcode display text in widgets. Every user-visible string must come from the localization system.

**How to add a new string:**
1. Add key + English value to `lib/l10n/app_en.arb` with an `@key` metadata block
2. Add Vietnamese translation to `lib/l10n/app_vi.arb`
3. Run `flutter gen-l10n` — auto-generates:
   - `lib/l10n/app_localizations.dart`
   - `lib/l10n/app_localizations_en.dart`
   - `lib/l10n/app_localizations_vi.dart`
4. Use in widgets via `AppLocalizations.of(context)!.yourKey`

> **Never edit the generated `.dart` files manually.** The `.arb` files are the single source of truth.

```dart
// ✅ correct
Text(AppLocalizations.of(context)!.pmMasterTitle)

// ❌ wrong
Text('Vault')
```

### Rule 4 — Always use theme colors; never hardcode colors

All colors **must** come from `AppThemeProvider.of(context)` (returns an `AppPalette`).

For semantic UI colors use `AppFeatureColors` (backed by `AppPalette`). Do not define ad-hoc `Color` constants inside feature or widget files.

| Palette slot | Intended use |
|---|---|
| `primary` | App bar, nav bar, dark backgrounds |
| `secondary` | Cards, secondary surfaces |
| `accent` | Active/highlight states, CTAs |
| `surface` | Main content background, light text on dark |
| `error` | Error messages, destructive actions |

```dart
final palette = AppThemeProvider.of(context);

// ✅ correct
Container(color: palette.primary)
Text('...', style: AppTextStyles.ui(color: palette.surface))

// ❌ wrong
Container(color: Color(0xFF222831))
Text('...', style: TextStyle(color: Colors.white))
```

For opacity variants use `.withValues(alpha: 0.5)` on a palette color.

### Rule 5 — Adding new palette entries

If a new semantic color slot is needed:
1. Add the field to `AppPalette` in `lib/core/theme/app_colors.dart`
2. Supply values for **every** existing palette (`midnight`, `sky`)
3. Expose via `AppFeatureColors` if needed across widgets

### Rule 6 — Abstract classes, interfaces, and constants namespaces must live in their own files

Never define an abstract class, interface, or constants namespace inside the same file as a concrete implementation.

**Exception:** Private (`_`-prefixed) constants classes used only within a single file are acceptable only when the file is under 100 lines.

### Rule 7 — Security constraints (non-negotiable)

- Secrets (vault key, master password) **never** in `SharedPreferences` — use `flutter_secure_storage`
- SQL queries use `?` placeholders — never interpolate user input
- No async/await in `build()` — resolve in ViewModel or `initState`
- Dispose `Timer`, `TextEditingController`, `FocusNode`, `StreamSubscription` in `dispose()`
- Password fields must clear from memory after every submit attempt
- Never log or print sensitive data (passwords, vault keys)

**If a violation is found**, fix immediately and document in `.github/ISSUES.md`.

---

### PROCESS & DOCUMENTATION RULES

### Rule 8 — Always update docs and track issues after every change

| Document | Update when |
|---|---|
| `DOCUMENTATION.md` | Public-facing behavior, API contracts, or feature set changes |
| `CLAUDE.md` | Architecture, conventions, or rules change |
| `.github/ISSUES.md` | Any bug introduced, fixed, or status changed |
| `.github/investigation-notes/YYYY-MM-DD_<slug>.md` | Non-obvious finding or decision made |
| `.github/design-docs/YYYY-MM-DD_<slug>.md` | New feature or system designed |
| `.github/plans/YYYY-MM-DD_<slug>.md` | Implementation plan created or updated |

**ISSUES.md entry format:**
```
## [STATUS] Short title  (STATUS: OPEN | IN-PROGRESS | RESOLVED | WONT-FIX)
- **Date found:** YYYY-MM-DD
- **Date resolved:** YYYY-MM-DD (if applicable)
- **Affected files:** list of files
- **Description:** what the issue is
- **Root cause:** brief root-cause note
- **Fix / workaround:** what was done
```

**Document naming:** `YYYY-MM-DD_<short-kebab-slug>.md`. Append to existing files rather than creating duplicates. 600-line limit per file.

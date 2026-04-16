---
name: flutter
description: Flutter Dev Helper — run Flutter tasks (analyze, test, l10n, run, build, pub, clean, check).
argument-hint: <analyze|test|l10n|run|build|pub|clean|check>
---

# Flutter Dev Helper

Run the Flutter task specified in arguments. If no argument is provided, show the menu below and ask the user which task to run.

**Invocation:**
```
/flutter [task]
```

Arguments — one of: `analyze`, `test`, `l10n`, `run`, `build`, `pub`, `clean`, `check`.

---

## Available tasks

| Command | Description |
|---|---|
| `analyze` | Run `flutter analyze` and report all lint/type errors |
| `test` | Run `flutter test` and report results |
| `l10n` | Regenerate localizations via `flutter gen-l10n` after ARB changes |
| `run` | Run the app on Linux desktop (`flutter run -d linux`) |
| `build` | Build Linux release (`flutter build linux`) |
| `pub` | Run `flutter pub get` to refresh dependencies |
| `clean` | Run `flutter clean` then `flutter pub get` |
| `check` | Run analyze + test together and summarize pass/fail |

## Behavior

1. Map arguments to the matching task above (case-insensitive).
2. Execute the corresponding shell command using the Bash tool.
3. Parse the output:
   - For `analyze`: list each warning/error with file, line, and message.
   - For `test`: show passed/failed counts and any failing test names with stack traces.
   - For `l10n`: confirm the generated files were updated.
   - For all others: show the relevant output lines (skip progress spinners).
4. If the command fails, suggest the most likely fix based on the error message.

## Flutter project rules reminder (apply when generating/editing code)

- Files must stay under 500 lines — split when approaching the limit.
- All user-visible strings must use `AppLocalizations.of(context)!.key` — never hardcode text.
- All colors must come from `AppThemeProvider.of(context)` (an `AppPalette`) — never use `Colors.*` or raw `Color(0x…)`.
- New palette colors go in `lib/core/app_colors.dart` with values for every existing theme.
- Follow feature-first MVVM: Views in `presentation/views/`, ViewModels in `presentation/viewmodels/`, business logic via repositories/usecases.

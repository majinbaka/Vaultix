---
name: workflow
description: 8-Phase Development Workflow — execute the full plan→explore→TDD→implement→verify→document→review→gate cycle for any task.
argument-hint: <task description>
---

# 8-Phase Development Workflow

Execute the 8-phase development workflow for the task described in arguments.

**Invocation:**
```
/workflow <task description>
```

**Examples:**
```
/workflow Add notification settings screen
/workflow Fix vocabulary flashcard not saving progress
```

---

## Phase 1 — Plan

Before touching any code:
1. Restate the task clearly in one sentence.
2. List affected files (use `Glob`/`Grep` to confirm they exist).
3. Assess complexity: how many files, any architectural impact, what could break?
4. Create a `TodoWrite` task list with all steps.
5. Create a plan file at `.github/plans/YYYY-MM-DD_<slug>.md` using this template:
   ```
   # <Task> — Implementation Plan
   - Date, Author, Status: DRAFT
   ## 1. Goal
   ## 2. Approach
   ## 3. Steps (ordered, checkboxes)
   ## 4. Risks & Mitigations
   ## 5. Definition of Done
   ```

**Stop and confirm plan with user before proceeding.**

---

## Phase 2 — Explore

Verify every assumption against the real codebase:
- `Grep` for every model, method, class, constant you intend to use
- Confirm they exist **and** have the expected signature
- Never reference a method or relationship chain you haven't verified
- Update investigation notes at `.github/investigation-notes/YYYY-MM-DD_<slug>.md` with findings

---

## Phase 3 — Write Tests First (TDD)

1. Write failing tests describing expected behavior
2. Run `flutter test path/to/test_file.dart` — tests **must** fail now
3. Use mutation-resistant assertions: check exact values, not just `isNotNull`
4. Assert every side effect: state changes, DB writes, notifications, counters

---

## Phase 4 — Implement Minimum

Write only the code required to make failing tests pass.
- No extras, no "while I'm here" improvements
- Follow MVVM: Views → ViewModels → Repositories → Data Sources
- All strings via `AppLocalizations`, all colors via `AppThemeProvider`

---

## Phase 5 — Verify No Regressions

Run `flutter test` (full suite). Target: zero regressions.
If anything unrelated fails, investigate before moving on.

---

## Phase 6 — Document

Update **in this same session**:
- `DOCUMENTATION.md` if feature/behavior changed
- `CLAUDE.md` if architecture/conventions changed
- `.github/ISSUES.md` for any bugs found or fixed
- Investigation note if a non-obvious decision was made

---

## Phase 7 — Adversarial Self-Review

Review your own changes as an attacker:
| Question | Why |
|---|---|
| What happens if this runs twice concurrently? | Race conditions, double-writes |
| What if input is null/empty/negative/max? | Crashes, silent corruption |
| What assumptions could be wrong? | Hidden coupling |
| Would I be embarrassed if this broke in prod? | Honest gut-check |

Fix every issue. Add to `.github/ISSUES.md`.

---

## Phase 8 — Quality Gate

- Run `flutter analyze` — zero warnings/errors required
- Run `flutter test` — full suite green
- Fix all valid lint findings
- Mark all TodoWrite tasks complete
- Update plan file status to DONE

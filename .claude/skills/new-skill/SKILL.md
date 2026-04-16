---
name: new-skill
description: Scaffold a new Claude Code skill — creates the SKILL.md with proper frontmatter and optional supporting files. Invoke with: /new-skill <skill-name> [description]
argument-hint: <skill-name> [description]
---

# New Skill Creator

Scaffold a complete Claude Code skill from scratch based on the arguments provided.

**Invocation:**
```
/new-skill <skill-name> [one-line description]
```

`$ARGUMENTS` — first token is the skill name (kebab-case), the rest form the description.

---

## What to do

Follow these steps exactly, in order:

### Step 1 — Parse arguments

Extract from `$ARGUMENTS`:
- **skill-name**: first word/token (kebab-case, lowercase, max 64 chars)
- **description**: everything after the skill name, or ask the user if missing

### Step 2 — Interview the user (if needed)

If description is missing or very short, ask:
1. What does this skill do in one sentence?
2. How will it be invoked — by the user (`/skill-name`), automatically by Claude, or both?
3. Does it need arguments? If so, what is the argument format?
4. Should it run inline (in the current context) or in a forked subagent?
5. Does it need supporting files (e.g. reference docs, templates)?

Skip questions that are already clear from `$ARGUMENTS`.

### Step 3 — Choose frontmatter fields

Based on the answers, select appropriate frontmatter:

| Need | Field to add |
|---|---|
| Hide from `/` menu | `user-invocable: false` |
| Prevent auto-trigger | `disable-model-invocation: true` |
| Run in subagent | `context: fork` |
| Limit tools | `allowed-tools: Read Grep ...` |
| Arguments hint | `argument-hint: <format>` |
| Specific model | `model: sonnet` or `model: opus` |
| Effort level | `effort: low / medium / high / max` |

### Step 4 — Design the skill content

Write clear, step-by-step instructions in the SKILL.md body:

- For **task skills**: numbered steps, exact actions, tool calls to make
- For **reference skills**: conventions, patterns, rules Claude should follow
- For **hybrid skills**: reference section + invocation section

Use `$ARGUMENTS`, `$0`, `$1`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_SESSION_ID}` where dynamic values are needed.

Keep SKILL.md under 500 lines. Move bulky reference material to supporting files.

### Step 5 — Create the files

1. Create `.claude/skills/<skill-name>/SKILL.md` with the designed content
2. If supporting files are needed, create them in the same directory and link from SKILL.md
3. Confirm the directory structure to the user

### Step 6 — Show a summary

After creating the files, display:

```
Skill created: /home/.../.claude/skills/<skill-name>/

Files:
  SKILL.md          — main skill file
  [other files]     — supporting files (if any)

Invoke with:
  /<skill-name> [arguments]

Frontmatter used:
  [list key fields chosen]
```

---

## Skill file template

Use this template as the base for every new SKILL.md:

```markdown
---
name: <skill-name>
description: <one-line description of what the skill does and when to use it>
argument-hint: <argument format, e.g. [filename] or [issue-number]>
[other frontmatter fields as needed]
---

# <Skill Title>

<Brief description of purpose and how to invoke>

**Invocation:**
```
/<skill-name> <argument format>
```

`$ARGUMENTS` — description of what arguments contain.

---

## Steps / Instructions

[Step-by-step instructions or reference content]
```

---

## FStudy-specific conventions

When creating skills for this project:
- Skills that generate Dart code must remind Claude to run `flutter analyze` after generation
- Skills touching localization must remind Claude to edit `.arb` files and run `flutter gen-l10n`
- Skills that create new features must follow the 8-phase workflow from CLAUDE.md
- All generated code must follow MVVM architecture, i18n, and theme rules from CLAUDE.md

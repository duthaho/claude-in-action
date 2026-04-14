# Lab 03 — Per-Project vs User Settings

> Section: 03-configuration-and-permissions · Difficulty: intermediate · Est: 30 min

## Goal

You debug a precedence conflict between a user-level `~/.claude/settings.json` and a project-level `.claude/settings.json`. The starter has both files pre-populated, and they disagree about the default model and the default permission mode. Your task is to predict which value wins *for each key*, verify your prediction, then edit the files so the project always wins on model and the user always wins on `env`. By the end you can sketch the precedence table from memory and you know the single question to ask when "Claude is using the wrong settings" — *"which layer set this key?"*.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-settings-tour](../lab-01-settings-tour/), [lab-02-allowlist-denylist](../lab-02-allowlist-denylist/)

## What you'll build

- A corrected `starter/fake-home/.claude/settings.json` (user layer)
- A corrected `starter/.claude/settings.json` (project layer)
- A `starter/analysis.md` where you record, for each of the four keys, which layer should win and why
- After your edits, the merged view looks like: model = project's pin, env = user's value, permissions = project's stricter value, apiKeyHelper = user's helper (not overridden)

## Steps

1. Change into the starter and read both files side by side:
   ```bash
   cd 03-configuration-and-permissions/lab-03-per-project-vs-user/starter
   cat fake-home/.claude/settings.json
   cat .claude/settings.json
   ```
2. Notice the four keys they both set:
   - `model` — user says `"claude-sonnet-4-5"`, project says `"claude-opus-4-6"`.
   - `env` — user says `{"EDITOR": "vim"}`, project says `{}` (empty — the project accidentally wipes the user value).
   - `permissions.defaultMode` — user says `"bypassPermissions"`, project says `"acceptEdits"`.
   - `apiKeyHelper` — user says `"~/.claude/anthropic_key_helper.sh"`, project doesn't mention it.
3. Create `starter/analysis.md` with one section per key. For each, write:
   - Who *should* win based on the stated intent: *"project should win model and permissions (the project pins them on purpose); user should win env and apiKeyHelper (those are personal)."*
   - Who *currently* wins given Claude's precedence rules (later layer wins on merge; nested objects are *shallow-merged*, so `env: {}` in the project actually wipes the user's env map).
4. Edit the files so intent matches reality:
   - **Project `settings.json`**: delete the `"env": {}` line entirely. An absent key lets the user value pass through; an empty object overwrites it.
   - **Project `settings.json`**: keep `model` pinned to `claude-opus-4-6` and `permissions.defaultMode` at `acceptEdits`. These are the keys where the project should dominate.
   - **User `settings.json`**: keep `env.EDITOR` and `apiKeyHelper`. These are personal and should survive.
5. Update `analysis.md` with a "## After fix" section describing the final merged view.
6. Launch Claude Code with `HOME="$PWD/fake-home" claude` from inside `starter/` and ask it to `/settings` (or whatever the current command is to print effective settings). Confirm: model is `claude-opus-4-6`, EDITOR is `vim`, default mode is `acceptEdits`, and apiKeyHelper points to the user path.

## Verify

```bash
bash ../../scripts/verify-lab.sh 03-configuration-and-permissions/lab-03-per-project-vs-user
```

The script checks that:

- Project `settings.json` has no `env` key (or has it as a non-empty object containing entries the project actually needs).
- Project `settings.json` keeps `model` and `permissions.defaultMode` set.
- User `settings.json` still has `env.EDITOR = "vim"` and `apiKeyHelper` set.
- `analysis.md` exists and has "before" and "after" headings.

## Solution

See `solution/` for corrected versions of both files plus a walkthrough of each key. `solution/README.md` has the full precedence table and explains the shallow-merge gotcha that catches almost every new user.

## Going further

- Add a third file at `starter/.claude/settings.local.json` that overrides `model` again. Which wins now? Document it in `analysis.md`.
- Set `env.EDITOR` in the project file to `"code"`. Does the user's `vim` value survive, or get clobbered?
- Grep your real `~/.claude/settings.json`. Any keys there you didn't realize were silently overriding your project settings?

## References

- [Official docs: Settings precedence](https://docs.claude.com/en/docs/claude-code/settings)

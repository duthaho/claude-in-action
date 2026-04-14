# Solution — lab-01-settings-tour

The finished starter has four files:

- `.claude/settings.json` — the committed project settings (model, env, default permissions).
- `.claude/settings.local.json` — a personal override that bypasses permission prompts.
- `.gitignore` — ignores the local override.
- `README.md` — unchanged.

## Why this works

Claude Code merges settings from three locations, in increasing precedence order:

1. `~/.claude/settings.json` — your user settings, applied to every project.
2. `<repo>/.claude/settings.json` — the project's committed settings.
3. `<repo>/.claude/settings.local.json` — your personal overrides for this project. Never committed.

When you launch Claude from inside `starter/`, it reads all three (whichever exist), merges them, and uses the result. For our file, the project `defaultMode` is `acceptEdits`, but the local override raises it to `bypassPermissions`, so the effective value is `bypassPermissions`.

## Why pin a concrete model

Leaving `model` out (or setting it to `"default"`) ties your project to whatever model Claude Code considers "default" that week. A beginner lab where the model changes underneath you makes debugging impossible — when something behaves differently than the instructions suggest, you can't tell whether the lab is wrong or the model is. Pinning `claude-sonnet-4-5` (or any other concrete ID) makes your project reproducible.

In real projects, the tradeoff is different: you usually *do* want the model to track the latest stable release, so you leave `model` unset in the committed file and pin a specific ID only in `settings.local.json` when you need to reproduce a bug.

## Why `.local.json` is the layer that confuses people

The single most common "why is Claude ignoring my settings" bug is: someone edits the committed `settings.json`, relaunches Claude, and sees no change — because they forgot they had a `settings.local.json` overriding the same key. The local file is gitignored, doesn't show up in `git status`, and nobody mentions it again after the day they created it. Then six weeks later its values silently dominate.

The fix is the `.gitignore` entry we added in step 7. Keeping the local file out of the repo is non-negotiable (it usually contains personal tokens or machine-specific paths), but it means you have to remember it exists. When settings behave mysteriously, always check for a `.local.json` file first.

## Key decisions

- **`acceptEdits` for the committed default.** Allowing Claude to edit files without prompting is the right default for a project you trust. Making *every* bash command prompt is too tedious; making *no* bash command prompt is too loose.
- **`bypassPermissions` only in `.local.json`.** If we put this in the committed file, every collaborator on the repo would inherit it. That's a footgun.
- **`LAB_MODE=true` as a string.** Environment variables are always strings; Claude passes them to shell tools as-is. Don't write `"LAB_MODE": true` (boolean) — it isn't valid in an env map.

## If you got stuck

- **"Claude reports LAB_MODE as empty."** You probably wrote `"env": "LAB_MODE=true"` (a string) instead of `"env": {"LAB_MODE": "true"}` (an object).
- **"`/permissions` still shows `acceptEdits`."** You didn't relaunch Claude after creating the local file. Settings are read at startup, not on every message.
- **"My JSON won't parse."** Comments and trailing commas are not valid JSON. Strip both.

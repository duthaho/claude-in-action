# Lab 01 — Settings Tour

> Section: 03-configuration-and-permissions · Difficulty: beginner · Est: 20 min

## Goal

You create your first `.claude/settings.json` for a project. The file sets a specific model, injects an environment variable into Claude's shell tools, and pins a default permission mode. This is the smallest possible real settings file. By the end you know exactly where `settings.json` lives, what the three most useful top-level keys are, and why you should almost never check in `settings.local.json`.

## Prerequisites

- Claude Code installed and logged in

## What you'll build

- A new file `starter/.claude/settings.json` with three top-level keys: `model`, `env`, `permissions`
- `model` pinned to a specific Claude model (not "default")
- `env` injecting `LAB_MODE=true` so any shell tool call sees it
- `permissions` with a conservative default mode

## Steps

1. Change into the lab starter:
   ```bash
   cd 03-configuration-and-permissions/lab-01-settings-tour/starter
   ls -la
   ```
   The `.claude/` directory does not exist yet.
2. Create the directory and file:
   ```bash
   mkdir -p .claude
   ```
3. Author `.claude/settings.json`. It must be valid JSON (no trailing commas, no comments) with exactly these top-level keys:
   - `"model"` — set to `"claude-sonnet-4-5"` (any concrete model ID is fine; the point is that it is not the word "default").
   - `"env"` — an object with `"LAB_MODE": "true"`.
   - `"permissions"` — an object with a `"defaultMode"` field set to `"acceptEdits"` (a conservative default that lets Claude edit files but still confirms bash commands).
4. Launch Claude Code from inside `starter/`. Ask *"print the value of $LAB_MODE and the current model you're running as"*. Claude should report `LAB_MODE=true` and the model ID you pinned.
5. Now create a *second* settings file, `starter/.claude/settings.local.json`, that overrides `permissions.defaultMode` to `"bypassPermissions"`. Notice the file name ends in `.local.json` — this is the personal, uncommitted layer.
6. Relaunch Claude Code and ask for `/permissions`. Confirm the effective mode is `bypassPermissions` (from the local file) even though the committed project file says `acceptEdits`.
7. Open `.gitignore` in the starter and add `.claude/settings.local.json` to it. You never want to commit the local override.

## Verify

```bash
bash ../../scripts/verify-lab.sh 03-configuration-and-permissions/lab-01-settings-tour
```

The script checks that:

- `starter/.claude/settings.json` exists and parses as valid JSON.
- It sets `model` to a non-empty string other than `"default"`.
- It has `env.LAB_MODE = "true"`.
- It has `permissions.defaultMode` set.
- `starter/.claude/settings.local.json` exists and sets `permissions.defaultMode = "bypassPermissions"`.
- `starter/.gitignore` contains the line `.claude/settings.local.json`.

## Solution

See `solution/` for a pair of minimal settings files that pass every check. `solution/README.md` explains why we pin a concrete model rather than relying on the default, and why `settings.local.json` is the layer that actually causes most "why is Claude ignoring my settings" confusion.

## Going further

- Add a `"hooks"` block to the project settings — an empty object is enough to prove it parses. You'll wire real hooks up in section 08.
- Add an `"allowedTools"` array to the project settings and set it to `["Read", "Grep", "Glob"]`. Launch Claude and try to edit a file — it should refuse.
- Read your own real `~/.claude/settings.json` (if it exists). What keys does it set that you forgot you wrote?

## References

- [Official docs: Settings](https://docs.claude.com/en/docs/claude-code/settings)

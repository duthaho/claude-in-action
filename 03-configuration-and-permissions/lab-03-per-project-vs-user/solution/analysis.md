# Precedence analysis

## Before fix — who actually wins each key

Claude Code merges settings in this order (later wins on conflict):

1. User: `~/.claude/settings.json`
2. Project: `<repo>/.claude/settings.json`
3. Local: `<repo>/.claude/settings.local.json` (not present in this lab)

For *top-level scalar keys*, the later layer replaces the earlier. For *nested objects*, the merge is shallow: the later layer's object replaces the earlier layer's object wholesale unless the later layer omits the key entirely.

- `model` — project wins. Effective: `claude-opus-4-6`. ✓ matches intent.
- `env` — project wins, and since the project sets `env: {}` (empty object), the user's `env.EDITOR = "vim"` is clobbered. Effective: empty. ✗ wrong — we wanted `vim` to survive.
- `permissions.defaultMode` — project wins. Effective: `acceptEdits`. ✓ matches intent.
- `apiKeyHelper` — user wins by default because the project file doesn't mention it. Effective: `~/.claude/anthropic_key_helper.sh`. ✓ matches intent.

The one broken key is `env`. The fix is subtle: removing the empty `env` object from the project file entirely, so the merge falls through to the user value.

## After fix — final merged view

- `model`: `claude-opus-4-6` (project)
- `env.EDITOR`: `vim` (user — pass-through)
- `permissions.defaultMode`: `acceptEdits` (project)
- `apiKeyHelper`: `~/.claude/anthropic_key_helper.sh` (user — pass-through)

Everything now matches intent. The project owns the keys that should be consistent across collaborators (model, permission mode), and the user owns the keys that are personal (editor, API key helper).

## The general rule

If you want the user value to survive, **do not set the key in the project file at all**. Setting it to an empty object or empty string in the project file is not "no change" — it is "replace the user value with this empty thing".

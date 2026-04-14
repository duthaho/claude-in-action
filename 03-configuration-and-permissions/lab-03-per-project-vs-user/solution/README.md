# Solution — lab-03-per-project-vs-user

The finished starter has three files:

- `fake-home/.claude/settings.json` — unchanged user file.
- `.claude/settings.json` — project file with the empty `env: {}` removed.
- `analysis.md` — precedence walkthrough for each of the four keys.

## Why this works

Claude Code merges settings top-down: user → project → local. Each layer's values replace the previous layer's values for any key the later layer sets. For most keys this is obvious: the later layer wins. The non-obvious part is the merge granularity — Claude does a **shallow merge**, not a deep merge. If the later layer sets a nested object, the entire object replaces the previous one, even if the previous object had keys the new one lacks.

That is why `env: {}` in the project file breaks things: an empty object is still an object, and it wins the merge. The user's `env.EDITOR = "vim"` vanishes. The fix — deleting the `env` key entirely from the project file — is the only way to say "leave this alone, inherit from the user layer".

## The full precedence table

| Key type | Behavior |
|---|---|
| Top-level scalar (`model`, `apiKeyHelper`) | Later layer's value replaces earlier, if set. If unset in the later layer, earlier value passes through. |
| Top-level object (`env`, `permissions`) | Later layer's object replaces earlier object wholesale, if set. If unset in the later layer, earlier object passes through. |
| Arrays (`permissions.allow`, `permissions.deny`) | Later layer's array replaces earlier array. Not concatenated. |

Two consequences worth memorizing:

1. **Absent beats empty.** Leaving a key out of a layer is not the same as setting it to empty. Absent inherits; empty overrides.
2. **Arrays don't accumulate.** If you set `allow: ["Read"]` in the user layer and `allow: ["Bash"]` in the project layer, the effective value is just `["Bash"]` — not `["Read", "Bash"]`. This bites people who expect deep-merge semantics.

## Why the project file is right to pin `model` and `permissions.defaultMode`

A project file is committed to the repo. Everyone who clones it gets the same values. That's exactly what you want for things that affect reproducibility: which model the code was developed against, which permission posture the repo expects. If each collaborator ran with a different model or permission mode, debugging "works on my machine" becomes a nightmare.

Conversely, `env.EDITOR` and `apiKeyHelper` are personal — my EDITOR is `vim`, yours is `code`, and neither of us wants the other's preference. These belong in the user layer, and the project file should never set them.

## Why the user layer is right to use `bypassPermissions`

It's a user-layer value, so it only affects the user's own sessions on their own machine. A team never sees it. A solo developer who knows what they're doing can trade off the confirmation prompts for faster iteration. If the same value were in the project file, every collaborator would inherit it, which is bad — trust posture is not transferable.

## If you got stuck

- **"I deleted `env` and it still shows empty."** Did you actually save the file? Did you relaunch Claude? Settings are read at startup.
- **"I set `env: null` instead of removing it."** `null` is valid JSON but it replaces the user value with null, not with the user's actual env. Delete the key entirely.
- **"The project `model` got overridden by the user value."** You probably didn't set the project `model` at all — the user layer was the only one setting it. Put the pin back in the project file.
- **"`/settings` output differs from what I expect."** Check for a `.claude/settings.local.json` you forgot about (see lab 01 — this is the #1 source of surprises).

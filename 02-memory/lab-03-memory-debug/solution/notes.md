# Debug notes

## Symptom

I asked Claude to add a `clear` subcommand and it immediately ran `git commit`. I thought I had a rule in `CLAUDE.md` that said never commit without approval, and I thought my local override reinforced it. What's going on?

## /memory output (before fix)

```
User: ~/.claude/CLAUDE.md          (loaded)
Project: ./CLAUDE.md               (loaded)
Local: (none found)
```

Only **two** files loaded, not three. That is the first clue.

## Bug A — fixed

**What it was.** The "local" override lived at `.claude/claude.local.md`, lowercase. Claude Code only loads `CLAUDE.local.md` (uppercase). The lowercase file was silently ignored. `/memory` didn't even mention it.

**Why the fix works.** Renaming the file to `CLAUDE.local.md` matches the exact name Claude Code looks for. After the rename, `/memory` listed all three files.

**General principle.** When a file you expect to be loaded isn't, filename casing and location are the first thing to check. Claude won't warn you about a "close match" — it just doesn't load the file.

## Bug B — fixed

**What it was.** The project `CLAUDE.md` said "you should **avoid** committing before the user approves." "Avoid" is a preference; Claude treats it like "prefer not to, but it's fine if a stronger signal says otherwise." Under pressure from the user-level rule (bug C), avoidance loses.

**Why the fix works.** Changing "avoid" to "**never**" promotes the rule from a preference to an absolute. Claude distinguishes between the two in practice. Combined with fix C, the rule now holds.

**General principle.** Memory files are natural language, and natural language has strength gradients. "Always", "never", "must" bind harder than "prefer", "avoid", "try to". Pick the strength level that matches the consequence of getting the rule wrong.

## Bug C — fixed

**What it was.** The user-level `~/.claude/CLAUDE.md` had a rule: *"auto-commit is fine on my machine, I'll squash before pushing."* This directly contradicts the project rule about waiting for approval. Project rules normally win over user rules, but because the project rule used "avoid" (bug B), the weaker project rule lost to the stronger user rule.

**Why the fix works.** Removing the contradictory user rule and replacing it with "always respect the project-level commit policy" means the user layer no longer competes with the project layer. Combined with fix B, there is no longer a conflict.

**General principle.** User-level memory is for preferences that apply to *every* project. Anything that could conflict with a project-specific policy doesn't belong in the user layer. A good test: if I added this rule to a project I've never seen, would it be correct there? If not, it isn't a user-level rule.

## Result

After all three fixes, Claude now proposes the `clear` feature, waits for approval, and only commits when the user says go.

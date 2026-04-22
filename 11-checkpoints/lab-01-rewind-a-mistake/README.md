# Lab 01 — Rewind a Mistake

> Section: 11-checkpoints · Difficulty: beginner · Est: 20 min

## Goal

You intentionally ask Claude Code to make a change to `src/calculator.py` that is *wrong* (adds a `divide` method that silently returns 0 on divide-by-zero instead of raising). You observe the file change, then use `/rewind` to return the session to the state *before* that change. Both the conversation turn **and** the file content get rolled back — and you confirm that by checking the file and the session history. By the end you understand which kinds of change a checkpoint captures, which it does not, and when to reach for `Esc Esc` vs `/rewind`.

## Prerequisites

- Claude Code installed and logged in (recent enough version to support `/rewind` — checkpoints shipped in v1.3)
- Tools: a Python runtime (only needed to run the starter's `calculator.py` — the lab itself does not require running it)

## What you'll build

- A `TRANSCRIPT.md` in the lab root with four short sections (filled in by you during the lab):
  1. The file state before you asked Claude to add `divide`.
  2. The file state after Claude added the (wrong) `divide`.
  3. The file state after you ran `/rewind`.
  4. One paragraph comparing 1 and 3 — they must match exactly.

## Steps

1. Change into the starter:
   ```bash
   cd 11-checkpoints/lab-01-rewind-a-mistake/starter
   cat src/calculator.py
   ```
   The starter has a `Calculator` class with `add` and `subtract`. Copy the full file content into the *"before"* section of `TRANSCRIPT.md` that you'll create in the lab root (one level up). This is your ground truth.
2. Launch Claude Code from `starter/`:
   ```bash
   claude
   ```
3. Make the mistake on purpose. Ask Claude:
   > *"Add a `divide(a, b)` method to src/calculator.py. If b is zero, return 0 instead of raising — we want the calculator to be forgiving."*
   
   Claude will edit the file and add a `divide` method that silently returns 0 on divide-by-zero. This is a bug in disguise — silent failure is strictly worse than a noisy exception — but *we asked for it*. That's the point.
4. Confirm the edit landed. In a separate terminal (or with `!cat src/calculator.py` in the same Claude session):
   ```bash
   cat src/calculator.py
   ```
   Copy the full file content into the *"after (broken)"* section of your `TRANSCRIPT.md`.
5. Rewind. Inside the same Claude Code session, run:
   ```
   /rewind
   ```
   Pick the checkpoint from **just before your "add divide" message** — the menu will show your recent turns. Select that one.
6. Confirm the rewind both removed the turn and reverted the file:
   ```bash
   cat src/calculator.py
   ```
   The `divide` method should be gone. Copy the file content into the *"after rewind"* section of your `TRANSCRIPT.md`.
7. Add a one-paragraph comparison at the bottom of `TRANSCRIPT.md`: confirm the "before" and "after rewind" sections are byte-identical.

## Verify

```bash
bash ../../scripts/verify-lab.sh 11-checkpoints/lab-01-rewind-a-mistake
```

The script checks that:

- `starter/src/calculator.py` exists and is unchanged (you didn't accidentally commit the broken state).
- `TRANSCRIPT.md` exists in the lab root and contains all four section headers (`## Before`, `## After (broken)`, `## After rewind`, `## Comparison`).
- `TRANSCRIPT.md` mentions `/rewind` (the command you ran) and `divide` (the method the mistake added).

Like other conversation-artifact labs, the verify is Tier-2: it confirms you completed the exercise, not that `/rewind` itself worked — that check is yours to make by inspecting the file after step 5.

## Solution

See `solution/TRANSCRIPT.md` for an example of what your transcript should look like. `solution/README.md` explains what a checkpoint actually captures (file writes in the working tree + the conversation trace), what it does not capture (changes you made outside Claude's tool use, git operations, MCP server state, external side effects), and when `Esc Esc` is the right tool instead of `/rewind`.

## Going further

- Instead of `/rewind`, try `Esc Esc` after step 3. What's the difference? When is the quick-undo preferable?
- Ask Claude to make two more wrong edits in a row (e.g. also remove `subtract`). Use `/rewind` to return to the very first checkpoint. Confirm that *all* intermediate edits were undone, not just the most recent.
- Inspect `.claude/` after a session — is there a checkpoints directory you can list? Where does Claude Code store the snapshot data?

## References

- [Official docs: Checkpoints](https://docs.claude.com/en/docs/claude-code/checkpoints) — what a checkpoint captures, when it's created, and the `/rewind` / `/checkpoints` commands

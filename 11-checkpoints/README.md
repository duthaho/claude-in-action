# Section 11 — Checkpoints

> Status: **v1.3 — built**

A **checkpoint** is a snapshot of your Claude Code session — both the conversation *and* any files Claude edited during it. You can rewind to a checkpoint (undoing both kinds of changes) and you can branch off one to explore two different implementations from the same starting point.

Key commands:

- `Esc Esc` — rewind to the previous turn (quick undo)
- `/rewind` — pick a checkpoint from a list and return to it
- `/checkpoints` — list the checkpoints in the current session

## Learning objectives

After this section you can:

- Rewind a session cleanly when Claude makes a change you don't want.
- Branch off a single checkpoint to try two implementations and decide which to keep.
- Reason about what a checkpoint does and doesn't capture.

## Labs

- [lab-01-rewind-a-mistake](lab-01-rewind-a-mistake/) — beginner, ~20 min — intentionally break code with Claude, rewind, confirm the break is gone.
- [lab-02-branching-explorations](lab-02-branching-explorations/) — intermediate, ~30 min — from one checkpoint, implement two sort strategies, pick the better one.

## References

- [Official docs: Checkpoints](https://docs.claude.com/en/docs/claude-code/checkpoints)

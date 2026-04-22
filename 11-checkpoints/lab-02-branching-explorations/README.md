# Lab 02 — Branching Explorations

> Section: 11-checkpoints · Difficulty: intermediate · Est: 30 min

## Goal

You use the checkpoint as a **fork point**: from one starting session state, you try two different implementations, keep both for comparison, then decide which to adopt. The starter has `src/sorter.py` with a placeholder `sort_events(events)` function and a vague requirement. You ask Claude to implement it one way (Branch A: in-place sort by timestamp), rewind to the checkpoint, ask Claude to implement it a *different* way (Branch B: pure function returning a new list, also falling back to `id` when timestamps tie), compare the two, and record your decision. By the end you've used `/rewind` not to undo a mistake but to **explore** — and you've produced a comparison document rather than just code.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-rewind-a-mistake](../lab-01-rewind-a-mistake/) — you know how `/rewind` works
- Tools: Python 3.9+ (to sanity-run the starter test)

## What you'll build

- `starter/src/sorter.py` — unchanged (this is the fork point; verify.sh confirms you didn't corrupt it by forgetting to rewind)
- `BRANCHES.md` in the lab root with three sections:
  - **Branch A** — code block + one-paragraph description of the approach and its trade-offs
  - **Branch B** — code block + one-paragraph description
  - **Decision** — one paragraph explaining which branch you picked and why (correctness? clarity? fit with other code?)

## Steps

1. Change into the starter:
   ```bash
   cd 11-checkpoints/lab-02-branching-explorations/starter
   cat src/sorter.py
   cat tests/test_sorter.py
   ```
   `sort_events` is a stub (`raise NotImplementedError`). The test in `tests/test_sorter.py` has two cases — one where timestamps are unique, one where two events share a timestamp.
2. Launch Claude Code from `starter/`. Before your first code message, make sure a checkpoint naturally lands on your prompt-only turn (this is the state you'll `/rewind` to). The easiest way: just open the session — the initial user message you will send kicks off the first checkpoint.
3. **Branch A.** Ask Claude:
   > *"Implement `sort_events` by sorting the list in place by each event's `timestamp` field. Keep it simple — no extra keys."*
   
   Claude edits `sorter.py`. Run the test:
   ```bash
   python -m pytest tests/test_sorter.py -v
   ```
   Note which cases pass and which fail. Copy the final `sorter.py` into the *"Branch A"* section of `BRANCHES.md`, and write one paragraph on the trade-offs (in-place mutates caller's list; ties in timestamps are order-preserving because Python's sort is stable — *but* only by coincidence of arrival order, which may surprise callers).
4. **Rewind to the fork point.** Inside the same Claude Code session:
   ```
   /rewind
   ```
   Pick the checkpoint from **just before the "Implement sort_events" message** — the one where `sorter.py` still has the `NotImplementedError` stub. Confirm:
   ```bash
   cat src/sorter.py
   ```
   The stub must be back.
5. **Branch B.** Ask Claude:
   > *"Implement `sort_events` as a pure function: return a new sorted list without mutating the input. Sort by `timestamp` ascending, and break ties with `id` ascending so the result is deterministic."*
   
   Claude edits `sorter.py` again — but because you rewound, this is a fresh implementation from the same starting point, not a change layered on top of Branch A. Run the test:
   ```bash
   python -m pytest tests/test_sorter.py -v
   ```
   Copy the final `sorter.py` into the *"Branch B"* section of `BRANCHES.md`, and write one paragraph on the trade-offs (pure, deterministic, but allocates a new list — and tie-breaking by id is a contract the caller now depends on).
6. **Decide.** Write a *"Decision"* paragraph at the bottom of `BRANCHES.md`: which branch do you adopt, and why? Mention at least one case where the *other* branch would be the better pick.

## Verify

```bash
bash ../../scripts/verify-lab.sh 11-checkpoints/lab-02-branching-explorations
```

The script checks that:

- `starter/src/sorter.py` still contains the `NotImplementedError` stub (you rewound after Branch B before saving, or you never modified the starter copy).
- `starter/tests/test_sorter.py` still exists and is non-empty.
- `BRANCHES.md` in the lab root contains `## Branch A`, `## Branch B`, and `## Decision` headers.
- `BRANCHES.md` contains two separate Python code blocks (one per branch) — checked by counting ```` ```python ```` fences.

## Solution

See `solution/BRANCHES.md` for an example of what a finished comparison looks like (with both implementations filled in). `solution/README.md` explains when branching is worth the ceremony (the two approaches have meaningfully different trade-offs) vs when it isn't (one branch is obviously worse — just use `Esc Esc`).

## Going further

- Extend to a third branch: ask Claude to implement `sort_events` using `functools.cmp_to_key` with a custom comparator. Is it better, worse, or roughly equivalent? What does it teach you about when `key=` and when `cmp=` are the right hammer?
- Try branching across *non-adjacent* checkpoints. Does `/rewind` let you jump past more than one turn?
- In a real review, would you check the two branches into two git branches and open two PRs? Or keep them as a single `BRANCHES.md`? What's the pedagogical vs engineering answer?

## References

- [Official docs: Checkpoints](https://docs.claude.com/en/docs/claude-code/checkpoints) — especially the "branching" discussion

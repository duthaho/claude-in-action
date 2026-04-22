# TRANSCRIPT — Thinking-budget comparison

Fill this file with real output from your own two sessions. The template below is what the final document should look like.

## Default run

Prompt (default thinking):

> Run `python -m unittest tests.test_intervals` — the `test_contained` case fails. Fix the bug in `src/intervals.py`. Don't rewrite the function, just fix the broken line.

**What Claude did.** Ran the tests, saw `test_contained` fail with `AssertionError: [(1, 5)] != [(1, 10)]`. Paste the key bit of Claude's reasoning here — two or three sentences is enough. Most default-thinking runs hop to the fix quickly: change `end` to `max(last_end, end)`. Did it try a print-statement detour first? Did it correctly identify *why* the bug happens, or just patch the symptom?

**Diff Claude produced.** Paste the one-line change.

**Verdict.** Did the tests pass after? How many tool calls did it take?

## Think-hard run

Rewind to before the previous prompt (`/rewind` to a checkpoint before the fix, or start a fresh session).

Prompt (extended thinking):

> Think hard about this. Run `python -m unittest tests.test_intervals`. The `test_contained` case fails. Before changing anything, explain the invariant the merge loop is supposed to maintain. Then describe the specific input shape that breaks it. Then, and only then, fix the bug.

**What Claude did.** With extended thinking, Claude typically states the invariant first — "after processing each interval, `result[-1]` spans every start/end point we've seen that's ≤ its current end". Then names the failure mode: "when an incoming interval is fully contained, `end < last_end`, and we're overwriting `last_end` with the smaller value." Paste what Claude actually said.

**Diff Claude produced.** Probably identical to the default run — it's the same one-line fix. Confirm.

**Tool calls / time.** Extended thinking costs more tokens but shouldn't significantly change the tool-call count.

## Verdict

Three or four sentences in your own words:

- Did default thinking get to the correct fix?
- Did extended thinking get there *faster* or *slower*? (Often slower — it spends tokens reasoning before acting.)
- What did extended thinking give you that default thinking didn't? (Usually: a clean explanation of *why*, not just *what*.)
- For this class of bug (a one-line fix with a failing unit test), was extended thinking worth the extra tokens?

The pedagogical point is that extended thinking is *not* universally better. It excels at bugs where reasoning matters more than iteration — this one is arguably on the boundary. Your verdict is the whole point of the lab.

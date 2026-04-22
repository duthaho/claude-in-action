# Lab 03 — Thinking Budget: Default vs Extended

> Section: 12-advanced-features · Difficulty: intermediate · Est: 35 min

## Goal

You run Claude twice on the same subtle bug — once with default thinking, once with extended thinking — and write up how the two runs differ. The starter ships a buggy `merge_intervals` function and a failing test case (`test_contained`). In one session you just ask Claude to fix it. In a second session you prefix the prompt with "think hard" and ask Claude to explain the invariant before fixing. `TRANSCRIPT.md` captures both runs side by side; the verifier checks the final code passes and the transcript has the required headers. The exercise is calibrational: you come out of it knowing *when* thinking is worth the tokens, not just that it exists.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-03-safety-hook](../../08-hooks/lab-03-safety-hook/) or any prior debugging-shaped lab (optional)
- Tools: `python` ≥ 3.9 on `PATH`

## What you'll build

- A fixed `starter/src/intervals.py` — the one-line change that makes `python -m unittest` pass.
- `TRANSCRIPT.md` in the lab root with three `##`-level headings: `## Default run`, `## Think-hard run`, `## Verdict`.

## Steps

1. Change into the starter and confirm the tests fail:
   ```bash
   cd 12-advanced-features/lab-03-thinking-budget/starter
   python -m unittest tests.test_intervals
   ```
   You should see `test_contained` (and possibly `test_contained_with_tail`) fail. The other cases pass.
2. **Run 1 — default thinking.** Launch Claude Code from `starter/` and paste:
   > Run `python -m unittest tests.test_intervals` — the `test_contained` case fails. Fix the bug in `src/intervals.py`. Don't rewrite the function, just fix the broken line.

   Let Claude work. Record the prompt, Claude's reply (or the key reasoning), the diff Claude produced, and whether the tests pass after, under `## Default run` in `TRANSCRIPT.md`.
3. **Rewind.** Restore `src/intervals.py` to its broken state (either `git checkout -- src/intervals.py` if you've committed, or `/rewind` to before Claude's fix, or manually revert `max(last_end, end)` back to `end`). The second run must start from the same state.
4. **Run 2 — extended thinking.** Still in Claude Code, paste:
   > Think hard about this. Run `python -m unittest tests.test_intervals`. The `test_contained` case fails. Before changing anything, explain the invariant the merge loop is supposed to maintain. Then describe the specific input shape that breaks it. Then, and only then, fix the bug.

   Record the prompt, the invariant Claude stated, the failure mode it named, the diff, and test result under `## Think-hard run`.
5. Write the `## Verdict` section: three or four sentences in your own words. Did both runs find the same fix? Was extended thinking *faster*, *slower*, or *similar*? What did extended thinking give you that default thinking didn't? Was it worth the extra tokens for this specific bug?
6. Leave `src/intervals.py` in its fixed state — the verifier runs the test suite.

## Verify

```bash
bash ../../scripts/verify-lab.sh 12-advanced-features/lab-03-thinking-budget
```

The script runs `python -m unittest` against `starter/tests/test_intervals.py` and checks that `TRANSCRIPT.md` has all three required headers plus a reference to both thinking modes. The tests passing proves your fix is correct; the transcript proves you actually ran the comparison.

## Solution

See `solution/src/intervals.py` for the one-line fix and `solution/TRANSCRIPT.md` for a template comparison. `solution/README.md` explains what the bug actually is (the loop invariant), why this specific bug was chosen for the comparison, and where extended thinking genuinely moves the needle vs where default mode is fine.

## Going further

- Escalate the prompt from `think hard` to `ultrathink` and see if the reasoning quality improves *or* just gets more verbose. Token cost grows faster than accuracy on easy bugs.
- Apply the same two-run comparison to a bug you actually encountered at work. Does the verdict match this lab's?
- Hand the same prompt to a smaller model (`claude-haiku-4-5` via `--model`). Does extended thinking rescue the smaller model, or is the ceiling a function of parameters, not budget?

## References

- [Official docs: Extended thinking](https://docs.claude.com/en/docs/build-with-claude/extended-thinking) — the "think hard" rungs
- [Official docs: Claude Code overview](https://docs.claude.com/en/docs/claude-code/overview) — how thinking blocks appear in Claude Code

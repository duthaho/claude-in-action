# Solution — lab-03-thinking-budget

> Try the steps in the lab's `README.md` first — peek here after.

## The bug

`src/intervals.py` has one broken line:

```python
result[-1] = (last_start, end)
```

should be:

```python
result[-1] = (last_start, max(last_end, end))
```

The invariant the loop is meant to maintain is: after processing any interval, `result[-1]` spans every endpoint we've seen that's `≤` its current end. If an incoming interval is fully contained (`end < last_end`), overwriting `last_end` with the smaller value violates the invariant. Sorted input usually *starts* with the smallest `start`, but it doesn't start with the largest `end` — that's what `test_contained` exposes.

## Why this bug was chosen

Three properties make it useful for the thinking-budget comparison:

1. **One-line fix.** The solution is identical in both thinking modes — "hard" doesn't change the final diff.
2. **Non-obvious by inspection.** Most readers scan the loop and think "looks right" because the happy-path case (overlapping from the left) works. The failure mode requires you to imagine a specific input shape.
3. **Testable.** The test suite includes `test_contained` with minimal setup, so the failing-test signal is clear in both runs.

Bugs that *would* strongly favour extended thinking: concurrency bugs where reasoning about interleavings dominates; algorithmic bugs where the fix requires a different approach, not a different line. Bugs that wouldn't: typos, obvious off-by-ones, missing null checks. This lab sits closer to the "doesn't much matter" end on purpose — it makes the comparison honest.

## How to read the comparison

If you ran both modes and got the same fix in similar time, that's a correct observation, not a failure of the exercise. The takeaway isn't "always use extended thinking" — it's "extended thinking changes *reasoning quality*, not always *outcome*, so spend tokens on it when reasoning is the bottleneck." The typical pattern:

- Default thinking: 70% of the tokens, 95% of the correct fixes on easy-to-medium bugs.
- Extended thinking: 3-10× the tokens, 99% correct fixes plus a clean explanation of *why*.

You use extended thinking when the *why* is load-bearing: writing a bug-fix PR description, producing an ADR, debugging a concurrency issue, designing an API. You skip it when the *why* is obvious and the *what* is the whole point.

## What the lab doesn't cover

- **Budget tuning.** The `think`/`think hard`/`think harder`/`ultrathink` rungs escalate reasoning tokens. Most problems need `think`, not `ultrathink` — token cost grows faster than accuracy.
- **Thinking visibility.** Extended thinking blocks are separate from the regular response; tooling that streams output needs to render them distinctly or hide them. That's an SDK-level concern, out of scope here.
- **When thinking makes Claude worse.** Overthinking simple problems sometimes produces elaborate but wrong answers. The default mode's bias toward action is a feature on easy bugs.

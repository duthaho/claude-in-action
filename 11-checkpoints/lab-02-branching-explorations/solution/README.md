# Solution — lab-02-branching-explorations

> Try the steps in the lab's `README.md` first — peek here after.

## What branching buys you

Branch A and Branch B are both legitimate implementations. Without checkpoints, you'd either:

1. Pick one and commit to it (you might not learn what the alternative would have looked like).
2. Ask Claude "give me two variants" in a single turn (you get two blobs, but they share context — Branch B inherits the framing Claude used in Branch A, and the comparison is polluted).
3. Keep a copy of `sorter.py` before each change and manually swap (bookkeeping friction, easy to mess up).

Checkpoint branching gives you something different: **two independent completions from the same session state**. Claude doesn't "remember" Branch A when producing Branch B — the rewind truly removes it from the conversation trace. That makes the branches comparable in the way a parallel A/B test is comparable: same input, different attempts.

## When branching is worth the ceremony

- The two approaches have **genuinely different trade-offs** (pure vs in-place, recursive vs iterative, feature-flag vs hard-cutover) and you want to see both.
- You're writing a technical decision record and need the alternative considered.
- You're pair-programming with Claude on a design-sensitive function.

## When it's not

- You already know Branch A is wrong — just `Esc Esc` and re-phrase.
- The two approaches would differ in a line or two. Ask for both in one turn; the pollution is minor when the diff is small.
- Stakes are low — a one-paragraph docstring doesn't deserve a fork.

## Why the test pins tie-breaking

`test_tied_timestamps_broken_by_id` is there on purpose: it means the *minimal* Branch A answer fails a case, and the *careful* Branch B answer passes. Without that test, both branches would look equivalent, and the comparison would reduce to stylistic preference — which doesn't exercise the pedagogy.

## Note on the code in `solution/src/sorter.py`

The file in this directory is *still the stub*. The solution's payload is `BRANCHES.md` (the comparison document), not a chosen implementation. Writing the chosen branch back into `sorter.py` is left to the learner as the obvious follow-up after they make the decision.

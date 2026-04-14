# Solution — lab-03-skill-evaluation

The finished state has five eval cases in `evals.json` (four normal + one expected-failure), plus a notes file explaining what each case tests.

## Why this works

Evals are how you turn "a skill that seems to work" into "a skill whose behavior is pinned down". Each eval case is a promise: *for this input, the skill must return this output*. When the suite runs green, you know the current behavior matches your expectations. When a case fails, either the skill drifted or your expectation was wrong — and either way you noticed, which is the point.

The harness in this lab is deliberately offline: it implements `slugify` in Python rather than calling Claude. Running real evals against a model is slow, expensive, and flaky for a beginner lab. For a real project you can run both levels — offline evals on every commit, model-backed evals once a week.

## Why you should always have at least one expected-failure

Pure-green suites look reassuring but hide something important: they don't track the things you know are broken. If you notice a bug and think "I should fix that later", writing an expected-failure eval for it is the lightest possible way to remember. The bug goes into the test suite, marked so it doesn't break CI, and the day the bug gets fixed the suite will start complaining that the case is no longer failing — which is your cue to promote it.

A skill with no expected-failures is usually a skill whose author hasn't looked closely at the edge cases, not a skill without edges.

## Why we wrote expected values from the rules, not from the implementation

Step 5 of the lab was specific: fix broken expected values by *reading the skill's rules*, not by running the function and copying its output. This matters because the implementation is allowed to be wrong; the rules are the spec. If you write tests against the implementation, you're measuring consistency, not correctness. The first time the implementation drifts from the spec, your tests will happily pass on the wrong answer.

General principle: tests assert what the code *should* do, not what it currently does.

## How to evolve an eval suite

- **Add a case when you find a bug.** The case documents the bug before you fix it, so nobody has to re-discover it later.
- **Add a case when you add a rule.** New rules deserve at least one case that fails if the rule is deleted.
- **Graduate expected-failures.** When a formerly-failing case starts passing, move it out of the expected-failure slot.
- **Retire cases only when the rule they test goes away.** Shrinking a suite to "speed up CI" is a false economy.

## If you got stuck

- **"The runner said 4/5 passed but I have 5 cases."** Your fifth case probably isn't marked `expected_failure: true`. Without the marker, a failing case counts as a failure, not a pass.
- **"My expected-failure case actually passes."** That's fine for this lab — the notes file shows you how to think about it. Rotate a new broken case through the slot later when you find one.
- **"The JSON won't parse."** Trailing commas, smart quotes, or unescaped backslashes. JSON is strict.

# Lab 03 — Skill Evaluation

> Section: 04-skills · Difficulty: intermediate · Est: 35 min

## Goal

You write evals for a skill. Evals are small test cases that exercise a skill with representative inputs and assert properties of the output — the same discipline you apply to code. Treating skills as testable artifacts is what separates "it worked when I tried it" from "it keeps working after I change it". The starter ships with a pre-written `slug-generator` skill and a broken `evals.json` file; your job is to fix the evals, add one more case, then run them with a tiny Python harness that's included. By the end you have a workflow you can apply to any of your own skills.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-first-skill](../lab-01-first-skill/), [lab-02-skill-with-resources](../lab-02-skill-with-resources/)

## What you'll build

- A corrected `starter/.claude/skills/slug-generator/evals.json` with at least four eval cases
- At least one eval that *fails intentionally* — proving the harness actually detects regressions
- A `starter/evals-notes.md` documenting what each case is testing and why

## Steps

1. Change into the starter:
   ```bash
   cd 04-skills/lab-03-skill-evaluation/starter
   ls .claude/skills/slug-generator
   cat evals_runner.py
   ```
   You'll see the skill, an `evals.json` file, and a small Python script `evals_runner.py` that reads the JSON, "runs" each case (by calling a simple offline function that mimics the skill's behavior), and reports pass/fail.
2. Read the skill at `.claude/skills/slug-generator/SKILL.md`. It takes a string and produces a URL-friendly slug: lowercase, spaces to `-`, strip punctuation, collapse consecutive dashes, no leading or trailing dashes, max 60 chars.
3. Read `evals.json`. It has three existing cases. Two are broken — the expected values don't match the skill's stated rules.
4. Run the evals:
   ```bash
   python evals_runner.py
   ```
   You'll see pass/fail output with the broken cases failing.
5. Fix the broken expected values so they match the skill's behavior. Do **not** fix them by running the function and copying its output — read the skill's rules and write the correct expectation.
6. Add a fourth case that tests something none of the existing cases cover. Good candidates: a string with emoji, a string of only punctuation, a string longer than 60 chars. Document your choice in `evals-notes.md`.
7. Add a fifth case that you *expect to fail* — something where the skill's behavior is wrong or unspecified. Mark it with `"expected_failure": true` in the JSON. The runner treats `expected_failure` cases as passing when they fail the assertion (the assertion failing *is* the test passing).
8. Run the evals again. You should see 4 passes + 1 expected-fail pass = 5/5.
9. Write `evals-notes.md` with a short entry per case: what it tests, why it matters, and (for the expected-failure) what the skill would need to change to make it pass "for real".

## Verify

```bash
bash ../../scripts/verify-lab.sh 04-skills/lab-03-skill-evaluation
```

The script checks that:

- `evals.json` is valid JSON with at least four normal cases and one with `expected_failure: true`.
- `python evals_runner.py` exits 0 (all cases pass under the runner's rules, including expected-fail cases).
- `evals-notes.md` exists and has a section per case.

## Solution

See `solution/` for one acceptable set of eval cases plus the notes. `solution/README.md` explains the "expected failure" pattern, why you should always have at least one, and how to evolve an eval suite over time as the skill changes.

## Going further

- Add a case that the skill currently fails on because of an underspecified rule. Then update the skill body to cover the case. Does the old expected-failure case still fail?
- Split the suite into `evals.json` and `evals-edge.json` — common cases and edge cases. Should they run on every change or only pre-release?
- Measure something other than exact-match: assert that the slug is a substring of the input, or that it contains no consecutive dashes. Write the assertion as a Python expression in the JSON.

## References

- [Official docs: Skills](https://docs.claude.com/en/docs/claude-code/skills)

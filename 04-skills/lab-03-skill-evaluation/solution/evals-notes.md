# Eval notes

## basic — `"Hello, World!"` → `"hello-world"`

The obvious case. Exercises rules 1 (lowercase), 2 (space→dash), 3 (strip punctuation), 5 (strip trailing dash). If this case fails, the skill is broken in a completely routine way — the regression would show up on the first real use. Keep it as the first case so failures are easy to read.

## collapses-spaces — `"  multiple   spaces  "` → `"multiple-spaces"`

Specifically exercises rule 2 (any run of whitespace becomes one dash) and rule 5 (no leading or trailing dashes). A naive implementation that only replaces single spaces would produce `"multiple---spaces"` — exactly the kind of bug this case catches. The starter's original expected value was `"multiple spaces"` (a literal space), which was wrong.

## pure-punctuation — `"!!!"` → `"untitled"`

Exercises rule 7 — the fallback when every character is stripped and the result is empty. The starter's original expected value was `""` (empty string), which was wrong by rule 7. This is a great rule to forget and a great case to catch its omission.

## long-truncated — a 90-character title → 60-character slug

Exercises rule 6 (truncation and the conditional trailing-dash strip). The truncation happens *after* the other rules, not before — if you truncated the raw input first, you might cut across a word in a way that produces extra dashes later. Rule 6 only strips a trailing dash if the truncation itself landed on one; it does not back up to a word boundary. For this input the 60-char cut lands mid-word on `-c`, so the expected value ends with `-c` and is exactly 60 characters long. A case like this catches every wrong variant: 60-char-stripped-anyway, word-boundary-aware, or "just truncate the raw string".

## unicode-transliteration-expected-failure — `"naïve implementation"` → would like `"naive-implementation"` (marked expected_failure)

This case **currently fails** and that's on purpose. The skill's rule 3 strips every non-ASCII character, including accented letters. Running through the rules:

1. lowercase → `"naïve implementation"`
2. whitespace → `-` → `"naïve-implementation"`
3. strip non-ASCII → `"nave-implementation"` (the `ï` is gone)
4. collapse dashes → `"nave-implementation"`
5. strip ends → `"nave-implementation"`

The skill produces `"nave-implementation"`. What you'd *want* in a mature slug generator is `"naive-implementation"` — transliterated from `ï` to `i`. Rule 3 as written can't do that because it only knows "strip anything non-ASCII". Fixing this case would require adding a transliteration step before rule 3, e.g. `unicodedata.normalize("NFKD", s).encode("ascii", "ignore")`.

This is a real, interesting shortcoming, and a great candidate for the expected-failure slot. When (if) the skill's rules are tightened to include transliteration, this case will start passing — and the harness will tell you that the expected-failure marker should be removed. That's the graduation signal.

## Why the expected-failure pattern matters

Regressions are the main reason evals exist. When a skill changes — a rule is tightened, a new edge case is handled — the ordinary cases should still pass. But the interesting cases are the ones that currently fail and should eventually stop failing. Marking them as `expected_failure` gives you a list of "known issues" the test suite tracks without breaking CI. When one of them starts passing, the harness tells you — and that's your cue to graduate it to a real case.

A skill with zero expected failures isn't necessarily good; it may just have a blind spot about its own rough edges.

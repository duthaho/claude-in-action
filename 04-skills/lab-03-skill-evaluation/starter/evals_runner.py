#!/usr/bin/env python3
"""Tiny offline eval harness for the slug-generator skill.

We deliberately do not call Claude here — the harness implements the skill's
rules in plain Python so every lab can run evals without a network or API key.
If the implementation drifts from the skill's stated rules, that's a bug in
the implementation, not the skill. This is the same dynamic you'd hit in real
evals: you have to trust *something* as the source of truth for expected
behavior, and in a learning repo the skill's natural-language rules are it.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

EVALS = Path(__file__).parent / ".claude" / "skills" / "slug-generator" / "evals.json"


def slugify(s: str) -> str:
    s = s.lower()
    s = re.sub(r"\s+", "-", s)
    s = re.sub(r"[^a-z0-9-]", "", s)
    s = re.sub(r"-+", "-", s)
    s = s.strip("-")
    if len(s) > 60:
        s = s[:60].rstrip("-")
    if not s:
        return "untitled"
    return s


def main() -> int:
    data = json.loads(EVALS.read_text(encoding="utf-8"))
    cases = data["cases"]

    passed = 0
    failed = 0
    print(f"Running {len(cases)} eval cases...\n")

    for case in cases:
        name = case["name"]
        inp = case["input"]
        exp = case["expected"]
        expected_failure = case.get("expected_failure", False)
        got = slugify(inp)

        match = got == exp
        if expected_failure:
            if match:
                print(f"  FAIL [unexpected pass]: {name}")
                print(f"    input:    {inp!r}")
                print(f"    expected failure, but got expected value {got!r}")
                failed += 1
            else:
                print(f"  ok [expected failure]: {name} (got {got!r}, expected {exp!r})")
                passed += 1
        else:
            if match:
                print(f"  ok: {name}")
                passed += 1
            else:
                print(f"  FAIL: {name}")
                print(f"    input:    {inp!r}")
                print(f"    expected: {exp!r}")
                print(f"    got:      {got!r}")
                failed += 1

    print(f"\n{passed} passed, {failed} failed")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())

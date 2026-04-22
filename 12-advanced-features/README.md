# Section 12 — Advanced Features

> Status: **v2.0 — built**

A catch-all for features that don't need their own top-level section but deserve hands-on practice. Each lab targets one feature and one decision: when to reach for it, when not to.

## Learning objectives

After this section you can:

- Launch a long-running shell command as a Claude background task and poll its output, without blocking the conversation.
- Drop a screenshot into Claude Code and get back working HTML that reproduces it — and know which parts of the fidelity you control.
- Compare default thinking vs extended thinking ("think hard") on the same bug, and make an informed call about when extended thinking earns the extra tokens.

## Labs

- [lab-01-background-tasks](lab-01-background-tasks/) — beginner, ~20 min — launch `slow-build.sh` in the background, poll it, finish it.
- [lab-02-image-inputs](lab-02-image-inputs/) — intermediate, ~30 min — reproduce a product-card mockup as HTML from a screenshot.
- [lab-03-thinking-budget](lab-03-thinking-budget/) — intermediate, ~35 min — fix a subtle `merge_intervals` bug with default thinking, then with `think hard`, and compare.

## References

- [Official docs: Claude Code overview](https://docs.claude.com/en/docs/claude-code/overview)
- [Official docs: Extended thinking](https://docs.claude.com/en/docs/build-with-claude/extended-thinking)
- [Official docs: Vision](https://docs.claude.com/en/docs/build-with-claude/vision)

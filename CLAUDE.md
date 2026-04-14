# Project Memory — claude-in-action

This is a hands-on learning repo. Every section is a collection of labs where beginners *build* something with Claude Code instead of just reading about it.

## Lab conventions

Every lab directory follows this exact shape:

```
NN-<section>/lab-NN-<slug>/
  README.md        # Goal / Prerequisites / What you'll build / Steps / Verify / Solution / Going further / References
  starter/         # files the learner modifies
  solution/        # finished state — visible sibling dir
  verify.sh        # runs diff or concrete checks against starter/
  .lab-meta.yml    # title, est_minutes, difficulty, tags, section
```

Do not invent alternative layouts. If you need a new convention, propose it in `CONTRIBUTING.md` first.

## Writing rules

- **Voice**: second person, present tense, active. "You create a command" — not "a command is created" or "we will create".
- **Beginner-friendly**: assume the reader installed Claude Code yesterday. Link to the official Claude Code docs for background, don't re-explain concepts already in the docs.
- **Every lab starts with a one-paragraph Goal**. No throat-clearing, no "in this lab we will".
- **Time estimate**: every lab has `est_minutes` in `.lab-meta.yml`. Target 15–45 minutes.
- **Scale**: labs are small on purpose. If a lab needs more than 10 steps, split it.

## Don't spoil solutions

`solution/` is a visible sibling to `starter/` — beginners will look at it. That is fine.

- Lab README `## Solution` section says **"try the steps first, peek after"**.
- `solution/README.md` inside each solution explains *why* the finished files look the way they do. That is the pedagogical payload, not the files themselves.
- Never stash solutions in hidden dirs, encrypted files, or separate git branches. All three break the beginner experience.

## Starter files

- If three or more labs need the same toy project, promote it to `sandbox/` (currently: `sandbox/todo-cli/`).
- `scripts/new-lab.sh` is responsible for copying a sandbox project into a new lab's `starter/` — never reference the canonical sandbox from a lab's instructions.
- Labs with unusual needs (MCP databases, mockup images, PR diffs) ship bespoke `starter/` files directly.

## Verification

- Prefer offline Tier-1 verification: `verify.sh` runs `diff -r solution/ starter/` or a concrete `grep`/`test` command, no Claude call.
- If a lab's artifact is a conversation transcript or screenshot, use Tier-2: a manual checklist in the `## Verify` section of the README.
- Tier-3 headless `claude -p` smoke runs in CI are deferred past v1 — do not add them yet.

## References

Every lab's `## References` section links to the relevant page in the official Claude Code docs (`https://docs.claude.com/en/docs/claude-code/...`). Point to specific pages, not just the root. Do not link to external repos or tutorials — the official docs are the only durable reference.

## What not to do

- Do not add features, sections, or labs not listed in the plan at `C:\Users\Admin\.claude\plans\cryptic-gathering-planet.md` without updating the plan first.
- Do not translate the repo in v1. English only until labs stabilize.
- Do not run `claude -p` from verify scripts — verification must work offline.
- Do not add references to external repos; link to the official Claude Code docs instead.

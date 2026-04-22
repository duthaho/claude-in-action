# Lab 01 — CLI Flags Tour

> Section: 13-cli · Difficulty: beginner · Est: 25 min

## Goal

You fill in a driver script that exercises the five CLI flags you'll reach for most in headless use: `-p`, `--output-format`, `--append-system-prompt`, `--allowedTools`, `--max-turns`. The starter ships a `drive.sh` with five numbered `TODO` blocks — one per flag — and short comments explaining what each should do. You don't have to actually *run* the script (Claude calls cost money), but the verifier reads the finished script and confirms each flag appears in its expected shape. The pedagogy: you come away knowing which five flags matter, not which fifty exist.

## Prerequisites

- Claude Code installed and logged in (optional if you don't intend to actually run `drive.sh`)
- Completed: any prior lab that got you comfortable with Claude Code
- Tools: bash

## What you'll build

- `starter/drive.sh` with all five TODOs filled in — each flag used at least once in its standard form.

## Steps

1. Read `starter/drive.sh` top to bottom. Each of the five `task_*` functions has a one-line comment describing what it should do and a `TODO N` marking where you write the actual `claude` invocation.
2. Fill in **TODO 1** — print mode. Call `claude` with `-p` (or `--print`) and a simple prompt like `"Reply with exactly: OK"`.
3. Fill in **TODO 2** — JSON output. Same prompt as TODO 1, add `--output-format json`. The effect: instead of plain text, you get an envelope you can pipe to `jq`.
4. Fill in **TODO 3** — system-prompt appending. Use `--append-system-prompt "Always answer in rhyming couplets. No exceptions."` and send a tiny prompt like `"Explain recursion in two lines."`. The flag stacks on top of the default system prompt, doesn't replace it.
5. Fill in **TODO 4** — tool restriction. Use `--allowedTools "Read,Glob,Grep"` on a prompt like `"List the Python files in this directory."` This is the primary safety knob for CI integrations: the agent can inspect but can't mutate.
6. Fill in **TODO 5** — turn cap. Use `--max-turns 2` on any prompt. Two turns means "one tool call then an answer" — enough for simple lookups, not enough for runaway loops.
7. (Optional) If you have `claude` installed and want to see the flags in action, run individual tasks: `bash drive.sh task_one_print`.

## Verify

```bash
bash ../../scripts/verify-lab.sh 13-cli/lab-01-cli-flags-tour
```

The script greps your `drive.sh` for each required flag. It doesn't execute `claude` — the lab is deliberately offline-verifiable so cost-sensitive learners can still pass.

## Solution

See `solution/drive.sh` for one complete version. `solution/README.md` explains *why* these five flags earn their keep, and lists which additional flags to reach for only once the main five stop covering your case.

## Going further

- Pipe each task's output through `jq` (for JSON) or through a small post-processor. Build a small script that extracts just the `result` field from JSON and counts tokens used.
- Add a sixth task using `--model claude-haiku-4-5-20251001`. Compare the reply to the default model on the same prompt.
- Read `claude --help` end to end. Pick one more flag that sounds useful, write it up in a comment on the bottom of `drive.sh`, and explain when you'd use it.

## References

- [Official docs: CLI reference](https://docs.claude.com/en/docs/claude-code/cli-reference) — every flag and its shape
- [Official docs: Headless mode](https://docs.claude.com/en/docs/claude-code/headless) — `-p`, stdin, output formats
- [Official docs: Settings](https://docs.claude.com/en/docs/claude-code/settings) — some of these flags have settings.json equivalents

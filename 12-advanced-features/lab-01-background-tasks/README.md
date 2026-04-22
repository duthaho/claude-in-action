# Lab 01 — Background Tasks & Polling

> Section: 12-advanced-features · Difficulty: beginner · Est: 20 min

## Goal

You launch a long-running shell command as a background task inside Claude Code, keep talking to Claude while it runs, poll it mid-flight, then wait for it to finish. The artifact is a `TRANSCRIPT.md` that captures the four touch-points — launch, interleaved work, poll, final — so the exercise is reviewable. Background mode is a small API surface (`run_in_background: true`, `BashOutput`, `KillShell`) but the workflow change is substantial: you stop blocking the session on every slow command.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-pre-commit-hook](../../08-hooks/lab-01-pre-commit-hook/) (optional — familiar with Claude's Bash tool)
- Tools: bash

## What you'll build

- `TRANSCRIPT.md` in the lab root with five `##`-level headings: `## Launch`, `## Interleaved work`, `## Poll`, `## Final`, `## What I learned`.
- The starter ships `slow-build.sh` (an ~18-second simulated build). You don't edit it — you run it through Claude and record what happens.

## Steps

1. Change into the starter and verify the build script works:
   ```bash
   cd 12-advanced-features/lab-01-background-tasks/starter
   bash slow-build.sh
   ```
   It prints four phase lines over ~18 seconds and ends with `BUILD SUCCESS`. This is the workload you'll run through Claude.
2. In a fresh Claude Code session (launched from this starter directory), ask Claude:
   > Run `bash slow-build.sh` in the background. Tell me the shell id.

   Claude should invoke Bash with `run_in_background: true` and reply with the shell id (e.g. `bash_1`). Record the prompt and Claude's answer under `## Launch` in `TRANSCRIPT.md`.
3. Immediately — don't wait for the build — ask Claude:
   > While that runs, count the number of `.sh` files under this directory and summarise what each one does.

   Claude should do this work *without* waiting for the build. If it blocks on the build instead, the background launch didn't take. Record the answer under `## Interleaved work`.
4. Ask Claude to peek at the running build:
   > Check the background build's output so far without waiting for it to finish.

   Claude should invoke `BashOutput` on the shell id and return partial output (only the first one or two phases will have printed). Record under `## Poll`.
5. Ask Claude to finish the build and report:
   > Wait for the build to finish and tell me if it succeeded.

   Claude polls until the shell state becomes `completed` and reports `BUILD SUCCESS`. Record the final output under `## Final`.
6. Add a `## What I learned` section (2–3 sentences in your own words) — when background mode is worth it, when it isn't.

## Verify

```bash
bash ../../scripts/verify-lab.sh 12-advanced-features/lab-01-background-tasks
```

The script checks that `slow-build.sh` still exists, is executable in the `starter/`, and that `TRANSCRIPT.md` sits in the lab root with all five required headings and references both `slow-build.sh` and `BashOutput` (proof you actually exercised the background-poll flow).

## Solution

See `solution/`. `solution/TRANSCRIPT.md` shows the template you can compare against after your own run, and `solution/README.md` explains when the polling round-trips earn their keep and when you should just run commands synchronously.

## Going further

- Launch two background builds at once (copy `slow-build.sh` to `slow-migrate.sh`, change the text). Ask Claude to poll both and report when the slower one finishes.
- Intentionally start a build and then ask Claude to kill it before it finishes. Observe what `KillShell` does to the shell state.
- Replace `slow-build.sh` with a real `pytest` run in a small sandbox project, or a `docker build`. The pedagogy is the same; the workload is real.

## References

- [Official docs: Bash tool reference](https://docs.claude.com/en/docs/claude-code/slash-commands) — `run_in_background`, `BashOutput`, `KillShell` in Claude Code's tool catalog
- [Official docs: Claude Code overview](https://docs.claude.com/en/docs/claude-code/overview) — the tool-use loop underpinning background mode

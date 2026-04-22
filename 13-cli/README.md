# Section 13 — CLI

> Status: **v2.0 — built**

Claude Code outside the TUI: `claude -p` as a Unix filter, in shell pipelines, in CI. The surface is small — five flags carry most of the weight — but the workflow changes are substantial: no more human-in-the-loop, every invocation is scripted, every cost is budgeted.

## Learning objectives

After this section you can:

- Drive `claude` entirely from CLI flags: print mode, output formats, system-prompt appending, tool restriction, turn caps.
- Build a bash pipeline that sends structured input to Claude, gets structured output back, and post-processes it.
- Wire Claude into a GitHub Actions workflow that reviews every pull request — with read-only tools and a turn cap as the safety rails.

## Labs

- [lab-01-cli-flags-tour](lab-01-cli-flags-tour/) — beginner, ~25 min — fill in a driver script that exercises `-p`, `--output-format`, `--append-system-prompt`, `--allowedTools`, `--max-turns`.
- [lab-02-scripting-with-claude](lab-02-scripting-with-claude/) — intermediate, ~35 min — an access-log → JSON → markdown-report pipeline with a canned-response fallback for offline CI.
- [lab-03-ci-integration](lab-03-ci-integration/) — intermediate, ~40 min — a GitHub Actions workflow that runs Claude on every PR and posts a review comment.

## References

- [Official docs: CLI reference](https://docs.claude.com/en/docs/claude-code/cli-reference)
- [Official docs: Headless mode](https://docs.claude.com/en/docs/claude-code/headless)

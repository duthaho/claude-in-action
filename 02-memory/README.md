# Section 02 — Memory

Memory is how Claude Code remembers things about your project across sessions. Without memory, you re-explain your conventions every time you open Claude. With memory, those conventions live in a file next to your code and show up automatically.

The labs in this section use the shared `sandbox/todo-cli/` project. You will write a `CLAUDE.md` for it, split that file across layers so user-wide rules live separately from project rules, and then debug a session where Claude ignores what you thought was a clear instruction.

## Learning objectives

After finishing these labs, you can:

- Write a project-level `CLAUDE.md` that Claude Code actually consults
- Split memory across user, project, and local layers and reason about precedence
- Use the `/memory` command to find out which layer is winning a conflict
- Diagnose and fix common "Claude is ignoring my rule" bugs
- Decompose a bloated `CLAUDE.md` into topic-scoped files under `.claude/rules/` and choose between that and `@import`

## Labs

| # | Lab | Difficulty | Est. |
|---|---|---|---|
| 01 | [lab-01-project-claude-md](lab-01-project-claude-md/) | beginner | 20 min |
| 02 | [lab-02-imports-and-layers](lab-02-imports-and-layers/) | beginner | 25 min |
| 03 | [lab-03-memory-debug](lab-03-memory-debug/) | intermediate | 30 min |
| 04 | [lab-04-organizing-rules](lab-04-organizing-rules/) | beginner | 25 min |

## References

- [Official docs: Memory](https://docs.claude.com/en/docs/claude-code/memory)

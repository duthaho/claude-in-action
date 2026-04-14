# Section 01 — Slash Commands

Slash commands are the first thing most Claude Code users try to customize, and for good reason: they are the simplest way to turn a natural-language instruction into a reusable action. You tell Claude "whenever I type `/commit`, do these things" — once — and never write that instruction again.

Each lab in this section asks you to author a real command and run it. By the end you can write project-local commands that ship with a repo, user-global commands that follow you between projects, and multi-step commands that chain multiple actions into one.

## Learning objectives

After finishing these labs, you can:

- Create a project-scoped slash command in `.claude/commands/`
- Write a command that reads its arguments and passes them to a concrete action
- Author a multi-step command that runs a sequence of tools in order
- Decide when a slash command is the right tool versus a skill or a subagent

## Labs

| # | Lab | Difficulty | Est. |
|---|---|---|---|
| 01 | [lab-01-hello-command](lab-01-hello-command/) | beginner | 15 min |
| 02 | [lab-02-commit-command](lab-02-commit-command/) | beginner | 25 min |
| 03 | [lab-03-multi-step-refactor](lab-03-multi-step-refactor/) | intermediate | 35 min |

## References

- [Official docs: Slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands)

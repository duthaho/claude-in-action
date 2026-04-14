# Section 05 — Subagents

> Status: **coming in v1.2**

Subagents are specialized Claude instances dispatched from your main session to handle a focused task without polluting the main context. Planned labs:

- `lab-01-code-reviewer-subagent` — define a reviewer subagent in `.claude/agents/` and dispatch it on a PR-shaped diff.
- `lab-02-researcher-subagent` — build a read-only researcher with tool restrictions.
- `lab-03-subagent-handoff` — main agent dispatches to the reviewer, consumes the report, decides what to do.

## References

- [Official docs: Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)

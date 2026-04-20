# Section 05 — Subagents

A **subagent** is a specialised Claude instance the main conversation dispatches to handle a focused side-task — code review, research, patching — in its own context window with its own tool set. The main conversation gets back a summary. The subagent's searches, file reads, and drafts never flood your main context.

Subagents live as Markdown files with YAML frontmatter at `.claude/agents/*.md` (project scope) or `~/.claude/agents/` (user scope). The frontmatter declares the subagent's `name`, `description`, tool allowlist, and optional `model`. Claude uses the `description` to decide *when* to dispatch.

The labs in this section walk you through authoring a reviewer subagent, a read-only researcher with tight tool restrictions, and a two-agent pipeline that composes a reviewer with a patch-writer. By the end you can design a subagent that's narrow enough to compose and restrictive enough to trust.

## Learning objectives

After finishing these labs, you can:

- Author a project-scoped subagent with correct frontmatter and a description that matches the right prompts
- Restrict a subagent's capabilities with `tools:` allowlists and `disallowedTools:` denylists, and explain why each layer matters
- Orchestrate multiple subagents from the main conversation in a sequential pipeline
- Decide when a pipeline of subagents is the right shape and when to graduate to an agent team

## Labs

| # | Lab | Difficulty | Est. |
|---|---|---|---|
| 01 | [lab-01-code-reviewer-subagent](lab-01-code-reviewer-subagent/) | beginner | 25 min |
| 02 | [lab-02-researcher-subagent](lab-02-researcher-subagent/) | beginner | 30 min |
| 03 | [lab-03-subagent-handoff](lab-03-subagent-handoff/) | intermediate | 40 min |

## References

- [Official docs: Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)

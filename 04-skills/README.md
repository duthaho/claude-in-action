# Section 04 — Skills

A **skill** is an auto-loadable bundle that teaches Claude how to do one specific thing: write a changelog, review a PR, generate an ADR, scaffold a component. Skills live in `.claude/skills/` (or in your user dir), carry their own instructions and optional resources, and get discovered by Claude at session start. When the situation matches the skill's description, Claude reaches for it the way a human reaches for a tool that's already on the bench.

The labs in this section walk you through authoring your first skill, packaging it with bundled resources, and writing evals so you can tell when a change to the skill breaks it. By the end you have a durable artifact you can reuse in every project — and the habit of treating a skill as code worth testing.

## Learning objectives

After finishing these labs, you can:

- Author a skill in `.claude/skills/<name>/SKILL.md` with correct frontmatter
- Bundle resource files into a skill and reference them from the instructions
- Write eval cases that exercise a skill and fail loudly when it drifts

## Labs

| # | Lab | Difficulty | Est. |
|---|---|---|---|
| 01 | [lab-01-first-skill](lab-01-first-skill/) | beginner | 25 min |
| 02 | [lab-02-skill-with-resources](lab-02-skill-with-resources/) | beginner | 30 min |
| 03 | [lab-03-skill-evaluation](lab-03-skill-evaluation/) | intermediate | 35 min |

## References

- [Official docs: Skills](https://docs.claude.com/en/docs/claude-code/skills)

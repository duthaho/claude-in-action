# Section 03 — Configuration & Permissions

Claude Code reads its behavior from `settings.json` files, merges them across three scopes (user, project, local), and consults an allow/deny list before every tool call. Until you understand these two systems, "Claude did something I didn't expect" is a mystery. After you understand them, it's a lookup.

This section walks you through writing your first `settings.json`, locking a repo down with an allowlist so Claude can look but not touch, and debugging a precedence conflict where a user-level setting silently wins over a project-level one.

## Learning objectives

After finishing these labs, you can:

- Author a `.claude/settings.json` that sets the model, environment variables, and a permission mode
- Build a deny list that keeps Claude out of a `secrets/` directory even in agentic mode
- Predict which of user/project/local `settings.json` will win a conflict and verify the prediction
- Use `/permissions` (or the equivalent flag) to see the merged view
- Author a custom output style and decide when a behavior belongs in a style vs. in `CLAUDE.md`

## Labs

| # | Lab | Difficulty | Est. |
|---|---|---|---|
| 01 | [lab-01-settings-tour](lab-01-settings-tour/) | beginner | 20 min |
| 02 | [lab-02-allowlist-denylist](lab-02-allowlist-denylist/) | beginner | 25 min |
| 03 | [lab-03-per-project-vs-user](lab-03-per-project-vs-user/) | intermediate | 30 min |
| 04 | [lab-04-output-styles](lab-04-output-styles/) | beginner | 25 min |

## References

- [Official docs: Settings](https://docs.claude.com/en/docs/claude-code/settings)
- [Official docs: Permissions](https://docs.claude.com/en/docs/claude-code/iam)

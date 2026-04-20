# Solution — lab-01-code-reviewer-subagent

The finished state is `.claude/agents/code-reviewer.md` — one file, ~40 lines including frontmatter. The `src/auth.py` file is intentionally left unchanged; the review report the subagent produces is the artifact, not a patched file.

## Why this works

Claude Code scans `.claude/agents/*.md` at session start and registers every subagent it finds. Registration reads the frontmatter only. When you prompt Claude later, the matcher compares your request against each subagent's *description* and delegates if one matches. The subagent runs in its own context window with its own tool set and returns a summary to the parent conversation.

That architecture is the whole point: the reviewer can `Glob` 50 files, `Read` all of them, and build a mental picture — and none of that noise ever lands in your main conversation. You get back a short report.

## Why tool restrictions are load-bearing here

The `tools: Read, Grep, Glob` line is the most important line in the frontmatter after `description`. A reviewer with `Edit` in its tool list can (and eventually will) "helpfully" apply the fixes it suggests, turning a review into a silent rewrite. Restricting tools means the subagent *physically cannot* do that — the tool isn't in its allowlist, so the call fails before it reaches the filesystem.

This is stronger than telling the model "don't edit files" in the system prompt. Instructions are negotiable. Tool allowlists are not.

## How to write a good description

- **Tell Claude when to delegate, not what the agent is.** "Code reviewer" is a label. "Use when the user asks to review code, audit code quality, or check a file or directory for security issues" is a trigger.
- **Include the phrasings a user would actually say.** People don't say "invoke the reviewer" — they say "review this", "audit this", "find problems". Put those words in the description.
- **End with the output shape.** "Produces a report grouped by severity with file:line references" tells Claude what it's being asked to make. That's visible in the registry and helps disambiguation when multiple subagents could plausibly match.
- **Narrow beats broad.** A description like "code analysis" would match every code question and clog your sessions. "Review for security, correctness, or style" is narrow enough to fire only when someone actually wants a review.

## Why the body is a procedure

The body becomes the subagent's system prompt. Narrative explanations ("In this agent we will explore…") make the model worse at following instructions. The numbered-procedure shape plus a constraints section at the end is close to the minimum viable structure.

The explicit output shape — exact Markdown with placeholders — is what makes reviews composable. If the parent session wants to feed the report into another subagent (see lab 03), it needs the shape to be predictable.

## Key decisions

- **Project scope, not user scope.** For a lab, project scope is right — the agent ships with the repo so everyone on the team gets the same reviewer. For a reviewer you'd use across every personal project, `~/.claude/agents/` would be the right choice.
- **`model: sonnet`.** Reviewers trade off accuracy against latency; Sonnet is well-sized for reading code and finding known-pattern issues. Opus is overkill; Haiku misses things.
- **No `Bash`.** A reviewer that can run tests is tempting, but it's a different job — and it widens the attack surface of the subagent considerably. Keep the reviewer read-only and let a separate agent run the tests.

## What the reviewer should find in `src/auth.py`

There are three seeded issues. A reasonable report surfaces all three:

- **Critical** — `src/auth.py:10` — hard-coded API token in source (`API_TOKEN = "sk-live-..."`). Rotate the token and load from environment or a secret store.
- **Critical** — `src/auth.py:14` — SQL injection via string concatenation in `find_user`. Use a parameterised query: `conn.execute("SELECT id, role FROM users WHERE username = ?", (username,))`.
- **Warning** — `src/auth.py:22` — bare `except:` swallows every error including `KeyboardInterrupt` and masks real failures. Narrow to `except sqlite3.Error:` and let unexpected exceptions propagate.

If the reviewer only finds two of the three, the description is fine but the body's "look for" list may be too shallow. Extend it.

## If you got stuck

- **"Claude didn't dispatch the subagent."** Check `/agents` (or run `claude agents` from a separate terminal) to see the registry. Missing agent → malformed frontmatter. Registered but not selected → the description isn't matching; add more trigger words.
- **"The subagent tried to edit the file."** Your tool list is wrong. `tools: Read, Grep, Glob` as a YAML string — not a list, not with commas missing.
- **"The report has extra commentary."** Your constraints section didn't say "output only the Markdown block" or you didn't pin the shape tightly enough. Add both.

# Solution — lab-04-organizing-rules

The finished starter has six memory-related files:

- `CLAUDE.md` — three lines: project name, one-sentence summary, pointer to rules.
- `.claude/rules/architecture.md` — state location and dispatch shape.
- `.claude/rules/testing.md` — unittest conventions, test requirements.
- `.claude/rules/commits.md` — conventional commits, subject limits, security.
- `.claude/rules/style.md` — Python formatting preferences.
- `todo.py` — unchanged.

## Why this works

Claude Code auto-discovers any markdown file under `.claude/rules/` (relative to the project root) and loads it as part of the model's memory at session start. You do not need to list the files anywhere — drop a new file into the directory, and Claude picks it up on the next session. Delete a file, and the rules in it stop applying. The filename itself becomes part of the organization: `commits.md` is a *location*, and a future contributor scanning the directory knows exactly where the commit rules live without grepping.

## `.claude/rules/` vs `@import` — the tradeoffs

You now know two ways to split a large memory file. They solve the same problem with different philosophies:

| | `@import` (lab 02) | `.claude/rules/` (this lab) |
|---|---|---|
| **Discovery** | Explicit. You list every imported file in `CLAUDE.md`. | Automatic. Claude scans the directory. |
| **Ordering** | You control the order by the order of imports. | Alphabetical by filename (effectively). |
| **Scope** | Can import from anywhere in the repo — `@import docs/memory/api-style.md` works. | Limited to `.claude/rules/`. |
| **Overlap** | Files can be reused across projects if paths align. | Each project has its own rules directory. |
| **Reviewability** | The `@import` lines in `CLAUDE.md` form a table of contents. | You have to `ls .claude/rules/` to see what exists. |
| **New-file cost** | Add an `@import` line, then write the file. | Write the file. |

### When to reach for `@import`

- When the imported file lives outside `.claude/rules/` (e.g., `docs/adr/2026-04-retrieval.md` that you want to surface into memory without copying).
- When you want a visible table of contents inside `CLAUDE.md`.
- When order matters — later imports override earlier ones.

### When to reach for `.claude/rules/`

- When you have several topic-scoped rule sets that don't need special ordering.
- When you want the cost of adding a new rule to be "write a file". `@import` requires two edits, not one.
- When the directory structure *is* the documentation — a teammate browsing `.claude/rules/` learns the shape of your conventions just from the filenames.

### In practice

Most real projects use both. `.claude/rules/` handles the topic-scoped rules that evolve over time (architecture, testing, style). `@import` handles pointers to canonical documents that already exist elsewhere in the repo (an ADR, an API style guide, a security policy that legal wants single-sourced). The two mechanisms compose — you can `@import docs/security-policy.md` from inside `.claude/rules/security.md`, and the transitive import resolves.

## The "one topic per filename" discipline

The real win from `.claude/rules/` is the filename. A file named `commits.md` is a promise that everything inside is about commits. If you dump unrelated rules into it ("also, we use 2-space indentation"), the filename lies, and the directory stops being self-documenting.

When you're tempted to put a rule in the "wrong" file because the right file doesn't exist yet — create the file. Rules files are free. A directory with eight focused files beats four bloated ones.

## Key decisions

- **No `#` heading at the top of each rules file.** The filename already says what the topic is; a heading would be redundant and add visual noise. Rules files are content, not documents.
- **`CLAUDE.md` keeps the pointer sentence.** Technically Claude would load `.claude/rules/*` even without the pointer. We keep the sentence because a human cloning the repo needs to know where the rules live — `CLAUDE.md` is still the first thing a new contributor reads.
- **Four topics, not eight.** Splitting further would be fine but we stopped at architecture/testing/commits/style because those are the meaningful axes for this tiny project. Don't split just to split.

## If you got stuck

- **"`/memory` only shows `CLAUDE.md`."** Either the rules directory has a typo (`.claude/rules` vs `.claude/Rules`), or the rules files lack a `.md` extension, or they're nested in a subdirectory Claude doesn't scan.
- **"Claude is following contradictory rules from `CLAUDE.md` and `.claude/rules/`."** You moved the content but didn't delete it from `CLAUDE.md`. Check for duplication.
- **"The rules files are huge."** You probably inherited a too-broad topic. Split further — create `testing-unit.md` and `testing-integration.md` if one file hits 30+ lines.

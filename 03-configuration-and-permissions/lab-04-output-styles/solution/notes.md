# Style vs. rule — classification exercise

For each of the three rules below, decide whether it belongs in an **output style**, in **`CLAUDE.md`** (a project rule), or in neither (in which case say where it should go instead). Write a short paragraph under each question explaining your reasoning.

## Q1: "Never commit secrets, API keys, or `.env` files."

**Belongs in `CLAUDE.md`, not in an output style.** This is a project-specific behavior rule about *what* Claude should do, not *how* it should talk. Output styles shape tone, format, and verbosity; they do not carry project-specific content rules. If you moved this rule into a style, it would apply to every project using that style, which is wrong — some projects *do* commit an `.env.example` and a demo `todos.json` intentionally. Rules about content belong where the content is: in project memory.

## Q2: "When writing code, lead with the code block; keep prose to one sentence."

**Belongs in an output style.** This is a pure shape rule — it doesn't touch the content of what Claude produces, only the formatting and order. Crucially, it is also *personal and reusable*: a senior developer wants this shape in every project they touch. Putting it in `CLAUDE.md` means copying it to every new repo and it being wrong for the teammate who does want explanations. Putting it in a user-scope output style means it follows the developer across projects without polluting any one project's rules.

## Q3: "All URL paths in the `api/` subdirectory must end with a trailing slash."

**Belongs in neither.** This is a *scoped content rule* — it only applies to files under `api/`, and it's a coding convention, not a behavior tweak. Putting it in a project `CLAUDE.md` works, but it's a lot of noise for a rule that only applies to a small subtree. The right home is a `.claude/rules/api-style.md` file (see lab 02-04) — a topic-scoped rules file that Claude auto-loads when the session touches files in `api/`. Output styles can't do scoping at all; they apply globally to every response.

## The general heuristic

| The rule is about... | It belongs in |
|---|---|
| How Claude talks (format, length, tone, code-first vs prose-first) | Output style |
| What Claude should or shouldn't do in this specific project | `CLAUDE.md` or `.claude/rules/` |
| A narrow scope (one subdirectory, one filetype) | Topic-scoped rules file |
| A reusable action (write commits this way, run tests that way) | Skill or slash command |

Output styles are about *voice and format*. When the rule is really about *behavior and content*, you are looking at a memory rule, not a style.

# Lab 04 — Output Styles

> Section: 03-configuration-and-permissions · Difficulty: beginner · Est: 25 min

## Goal

You author a custom **output style** — a markdown file that reshapes how Claude responds in every session that uses it. The built-in styles (Default, Explanatory, Learning) cover common cases, but when you want something specific (terse senior-dev mode, exhaustive teaching mode, code-review persona), you write your own. By the end you know where custom styles live, how they get wired via `settings.json`, and the single question that decides "style vs. `CLAUDE.md` rule" when you're not sure which to reach for.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-settings-tour](../lab-01-settings-tour/)

## What you'll build

- A custom output style at `starter/.claude/output-styles/terse.md` — a markdown file with YAML frontmatter (`name`, `description`) and a body that instructs Claude to respond minimally: code blocks, no prose, no preamble, no trailing summaries.
- A `starter/.claude/settings.json` that references the custom style via the `outputStyle` setting.
- A short `starter/notes.md` answering one question: *"which of these belongs in the output style, and which belongs in `CLAUDE.md`?"* — with three example rules to classify.

## Steps

1. Change into the starter and look around:
   ```bash
   cd 03-configuration-and-permissions/lab-04-output-styles/starter
   ls -la
   ```
   There's a `CLAUDE.md` with some existing project rules and `notes.md` with three classification questions. No `.claude/` directory yet.
2. Create the output styles directory and your style file:
   ```bash
   mkdir -p .claude/output-styles
   ```
3. Author `.claude/output-styles/terse.md`. It needs:
   - YAML frontmatter with `name: terse` and a `description` that explains *when* to use this style (for senior developers who don't want hand-holding).
   - A body that modifies the system prompt. Claude loads the body as additional system-prompt instructions. Tell Claude explicitly:
     - No preamble or "Sure, I'll help with that".
     - Lead with code, not prose.
     - One-sentence explanations, max. No trailing summaries.
     - Ask for clarification only when a decision changes what gets written.
4. Wire the style via `.claude/settings.json`. Create the file with:
   ```json
   {
     "outputStyle": "terse"
   }
   ```
   The value `"terse"` must match the `name` field in the frontmatter of your style file — that's how Claude finds it.
5. Launch Claude Code from inside `starter/`. Run `/output-style` to confirm `terse` is listed and active. Ask Claude *"how do I iterate over a dict in Python?"*. Expect a code block and maybe one sentence — nothing else.
6. Open `notes.md` and answer the three classification questions by writing a short paragraph under each. The point of step 6 is not the specific answers; it's to force you to think about the dividing line between "style" and "rule".

## Verify

```bash
bash ../../scripts/verify-lab.sh 03-configuration-and-permissions/lab-04-output-styles
```

The script checks that:

- `starter/.claude/output-styles/terse.md` exists.
- The style file starts with `---` (frontmatter) and has `name: terse` and a non-empty `description` field.
- The body references response shape (keywords like "code", "preamble", "prose", "sentence" — at least one).
- `starter/.claude/settings.json` is valid JSON and sets `outputStyle` to `"terse"`.
- `starter/notes.md` has been updated: each of the three `## Q` questions has at least one paragraph of answer below it.

## Solution

See `solution/` for one acceptable terse style and a worked answer to the classification questions. `solution/README.md` explains the "style vs. rule" heuristic and when a behavior belongs in neither — it belongs in a slash command or a skill.

## Going further

- Author a second style `teaching.md` that does the opposite — asks questions, explains each code edit, narrates reasoning. Switch between the two mid-session with `/output-style teaching`. Does the session feel different enough to justify two styles?
- Move the style to `~/.claude/output-styles/terse.md` (user scope) and use it across multiple projects. What does that tell you about where a style should live — project or user?
- Try setting `outputStyle` to one of the built-in styles (`"Explanatory"`, `"Learning"`) instead of your custom one. How does it compare to your terse style?

## References

- [Official docs: Output Styles](https://docs.claude.com/en/docs/claude-code/output-styles)
- [Official docs: Settings](https://docs.claude.com/en/docs/claude-code/settings)

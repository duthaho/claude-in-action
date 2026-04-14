# Solution — lab-04-output-styles

The finished starter has three new files:

- `.claude/output-styles/terse.md` — the custom style, ~25 lines including frontmatter.
- `.claude/settings.json` — one line wiring `outputStyle` to `"terse"`.
- `notes.md` — answers to the three classification questions plus a general heuristic table.

## Why this works

An output style is a markdown file whose body gets injected into Claude's system prompt at session start. The frontmatter gives the style a `name` (used to select it) and a `description` (shown in `/output-style` and picked up by any tooling that lists available styles). The body is free-form markdown that becomes part of the model's context for every response in that session — it's not a one-off instruction, it's a persistent overlay.

Once `.claude/settings.json` says `"outputStyle": "terse"`, every session booted from this project starts in terse mode. There is no runtime step, no explicit tool call, no per-message instruction. Drop the style file, wire the setting, relaunch.

## The "style vs. rule" heuristic

The single question that decides where a behavior lives is: **does this change how Claude talks, or what Claude does?**

- **How Claude talks** → output style. "Lead with code." "No preamble." "One sentence max." "Ask before showing two approaches." These are formatting and tone; they are portable across projects; they affect every interaction uniformly.
- **What Claude does** → project memory (`CLAUDE.md` or `.claude/rules/`). "Never add dependencies." "Tests use `unittest`, not `pytest`." "Timestamps are ISO-8601 UTC with `Z` suffix." These are behavioral rules; they are specific to this project; they affect the *content* of Claude's output, not its shape.

If a rule fits both categories — "always write code comments in TypeDoc style" is about both format and what — it usually belongs in project memory, because project memory is the higher-fidelity mechanism. Styles are a blunt instrument; memory is a precise one.

## Why terse is user-scope in real projects

The `terse.md` file in this lab lives at `.claude/output-styles/` (project scope) so the starter is self-contained. In real use, you'd put it at `~/.claude/output-styles/terse.md` (user scope) — your preference for terseness follows you between projects. A project-scope style would force every collaborator on the repo to read in terse mode even if they prefer explanatory, which is a bad default.

**General rule**: styles are personal. They usually belong in user scope. Project scope is for the unusual case where the project *itself* has an identity that should override user preferences — a teaching repo, a demo, a support chatbot persona.

## Key decisions

- **Used `name: terse` (lowercase, unquoted).** YAML is forgiving but case-sensitive for matching. The `outputStyle` value in `settings.json` must match exactly.
- **Description tells Claude *when* to use the style, not what it is.** Same lesson as skill descriptions (lab 04-01): the important line is the one that helps the model decide, not the one that labels the file.
- **Numbered rules in the body, not prose.** Claude follows checklists better than it follows narrative. "No preamble. Lead with code. One sentence max." beats "Try to be terse and code-focused without being too brief."
- **`outputStyle` only in `settings.json`, not `settings.local.json`.** For a lab where the style *is* the artifact, committing it is the point. In real use, a personal style preference is often better in `settings.local.json` so it doesn't affect collaborators.

## If you got stuck

- **"Claude is still responding in Default style."** Check three things: the style file's frontmatter `name` exactly matches the `outputStyle` value in settings; the style file is under `.claude/output-styles/` (plural, hyphen); you relaunched Claude after creating the files (settings are read at startup).
- **"The style is active but Claude is still adding preambles."** Your style body is probably too gentle. Natural-language instructions need negative rules stated as negatives: "Do not start with 'Sure'" beats "Try to skip acknowledgments".
- **"I can't tell if it's working."** Ask a direct question in a session with the style on, then the same question in a session with the style off (delete the `outputStyle` line temporarily). If the two responses are indistinguishable, the style body is too weak.

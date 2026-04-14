# Solution — lab-02-skill-with-resources

The finished skill has four files:

- `.claude/skills/adr-writer/SKILL.md` — the skill (~40 lines with frontmatter).
- `.claude/skills/adr-writer/resources/template-short.md` — the short ADR shape.
- `.claude/skills/adr-writer/resources/template-long.md` — the long ADR shape.
- `docs/adr/0001-use-python.md` — unchanged, used to test the numbering logic.

## Why this works

Claude Code loads a skill by reading its `SKILL.md` and, when needed, following relative paths inside the skill directory to resource files. When the body says "read `resources/template-long.md`", Claude treats that path as relative to the skill's own directory, so it finds the template without the user having to spell out the full path. Resource files are ordinary files — there is no special format, no required directory name, just "things the skill body can point to".

## Why templates as files, not inline

Three reasons to separate templates from the skill body:

1. **Readability.** A skill body reads better as a list of steps ("pick a template, fill it in, write it out") than as a wall of text that interleaves instructions with an 80-line template block.
2. **Maintainability.** When you want to change the ADR shape — add a `Security implications` section, say — you edit one file, not a rendered string inside a Markdown code block. Less chance of mis-escaping something.
3. **Reuse.** The template files can be consumed by something other than the skill — a slash command, a `Plan` step, or even a human copying the file directly. Inline content is trapped inside the skill.

The rule of thumb: if the content has a *shape* (headings, required fields, a schema), put it in a resource file. If the content is a single string, inline it. "Write the output like this: `ok: {count}`" is inline-worthy; "Fill in this ADR structure" is not.

## Why two templates, not one with conditional sections

One template with "optional" sections means the skill body has to describe which sections to include in which cases, and the template has to use markup that Claude might accidentally emit literally. Two templates means the choice is made at step 2 and the rest of the body doesn't need to think about it again. Two separate files are simpler than one file with branches.

## Why the numbering uses `highest + 1`, not "next free"

Real ADR repos treat numbers as identifiers — `ADR-0004` is a name, not a slot. If you deleted `0004` and then wrote a new decision into slot `0004`, anyone who referenced the old one in a commit message or a Slack thread would now be pointing at the wrong decision. `highest + 1` is monotonic and safe even when gaps appear (usually because an ADR was superseded and the old one stayed in place).

## Key decisions

- **`resources/` as the subdirectory name.** Not required, but conventional. Other common names are `templates/`, `prompts/`, `examples/`. Pick one and stick with it across your skills.
- **Status date in parentheses, not in frontmatter.** The templates put the date in the Status line because a human reading the rendered ADR wants to see "Accepted (2026-03-01)" without opening a hidden block.
- **The short template has only three sections.** Anything more elaborate and you should have picked long. Keeping it minimal makes the tradeoff obvious.

## If you got stuck

- **"Claude couldn't find the template file."** The skill body needs to reference the file by relative path (`resources/template-short.md`), not an absolute path. Absolute paths depend on where the learner cloned the repo.
- **"Claude wrote the ADR into the wrong directory."** The body didn't say `docs/adr/`. Skills operate in the current working directory; if you want a specific output path, state it.
- **"The numbering started at 0001 even though 0001 existed."** The body's numbering step only triggered when it was explicit about "find the highest existing". If you said "pick the next number", Claude might have interpreted it as "start fresh". Be specific.

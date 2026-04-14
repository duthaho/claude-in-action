# Solution — lab-01-first-skill

The finished state is `starter/.claude/skills/changelog-writer/SKILL.md` — one file, ~30 lines including frontmatter.

## Why this works

Claude Code scans `.claude/skills/*/SKILL.md` at session start and builds a registry of available skills. For each skill, it reads the YAML frontmatter but does **not** immediately load the body. When you prompt Claude later, it looks at the *descriptions* in the registry, decides which (if any) match your request, and only then pulls in the matching skill's body.

This two-stage discovery has an important consequence: **the description is the most load-bearing line in the skill**. A vague description means your skill gets ignored when you need it or loaded when you don't. A tight description means Claude reaches for the skill in exactly the right situations.

## How to write a good description

- **Tell Claude when to use it, not what it is.** "Writes changelogs" is a label. "Use when the user asks for a changelog, release notes, or a summary of what changed since a tag" is a trigger.
- **Include the words a user would actually say.** If someone might ask "what changed recently", put "what changed" in the description. Keywords matter because the skill matcher is doing a semantic search over descriptions.
- **Narrow beats broad.** "Documentation skill" is too broad — Claude will load it for every docs question. "Changelog and release-note generator" is narrow enough to fire only when relevant.
- **End with the output shape.** "Produces a Keep-a-Changelog block" tells Claude what it's being asked to make, which shows up in the registry and helps disambiguation.

## Why the body is structured as a procedure

A skill body is an instruction, not a tutorial. The model reads it as a checklist: run this, parse that, emit the following. Narrative explanations ("In this skill we will explore…") make the model worse at following the skill, not better. The numbered-step shape we used here is close to the minimum viable structure.

## Why we don't use a shell script for this

You could write changelog generation as a shell script (or a Python script). In a real project you probably should — scripts are deterministic and fast, skills are negotiable and model-dependent. The reason this lab uses a skill is that the *shape* of the output is natural-language-adjacent: grouping commits by conventional-commit type, writing prose for ambiguous commits, picking sensible section headings. Skills are the right tool when the task has a rigid skeleton and a soft middle.

## Key decisions

- **Project scope, not user scope.** For a lab, project scope is right — the skill ships with the repo. For real use, you'd probably put it in `~/.claude/skills/` so it follows you across projects.
- **Omit empty categories.** Keep a Changelog doesn't require every section to exist. Emitting `### Added` with nothing under it is noise.
- **`--no-merges` on the `git log` call.** Merge commits pollute changelog output. If your team rebases, this flag is a no-op. If your team merges, it keeps the noise out.

## If you got stuck

- **"Claude didn't load my skill."** Check `/skills` (or the equivalent) to see what's registered. If your skill is missing entirely, the frontmatter is probably malformed — missing `---` delimiters, a tab in the YAML, or a smart quote. If your skill is registered but not selected, the description isn't matching — add more keywords.
- **"Claude loaded the skill but ignored the instructions."** Your body is probably too narrative. Rewrite as a numbered procedure.
- **"The output has extra explanation around the changelog block."** Your constraints section didn't say "output only the Markdown block". Add that sentence.

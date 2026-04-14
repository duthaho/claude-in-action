# Contributing to claude-in-action

Thanks for wanting to add or improve a lab. This repo has strong conventions so every lab feels the same to a learner. Please read this document before opening a PR.

## Ground rules

1. **One lab = one focused skill**. If a lab needs more than ~10 steps or teaches more than one idea, split it into two.
2. **Every lab ships `starter/`, `solution/`, `verify.sh`, `README.md`, and `.lab-meta.yml`.** No exceptions.
3. **English only for v1.** Translations come later.
4. **No `claude -p` calls in `verify.sh`.** Verification must work offline and without a network dependency.
5. **Link to the official Claude Code docs in `## References`.** Do not cross-link to external repos or tutorials — the official docs are the only durable reference.

## Adding a new lab

Use the scaffolding script:

```bash
bash scripts/new-lab.sh <section-dir> <lab-slug>
# example:
bash scripts/new-lab.sh 01-slash-commands lab-04-docs-command
```

This copies `templates/lab/` into the target location. Then:

1. Edit `README.md` — fill in every heading from the template.
2. Add your starting files to `starter/`.
3. Add the finished files to `solution/`. Include `solution/README.md` explaining *why* the finished state looks the way it does.
4. Write `verify.sh`. Prefer `diff -r solution/ starter/` for file-based labs; use concrete `grep`/`test` commands when you need to check a specific property.
5. Update `.lab-meta.yml` — `title`, `est_minutes`, `difficulty` (`beginner` or `intermediate`), `tags`, `section`.
6. Regenerate the index: `bash scripts/list-labs.sh`. Commit the updated `INDEX.md`.

## Sandbox vs bespoke starters

- **Shared sandbox project**: `sandbox/todo-cli/` — a small Python CLI reused by several labs. Use this when your lab works on "a typical small project". `new-lab.sh` can copy it into the lab's `starter/`.
- **Bespoke starter**: write your own files directly in `starter/` when the lab needs something unusual (a database, a screenshot, a PR-shaped diff).
- **Promotion rule**: if three or more labs need the same toy project, promote it to `sandbox/`.

## Lab README checklist

Before opening a PR, your lab's `README.md` must have all of these headings in order:

- `# Lab NN — <Title>`
- `> Section: <slug> · Difficulty: ... · Est: N min`
- `## Goal`
- `## Prerequisites`
- `## What you'll build`
- `## Steps`
- `## Verify`
- `## Solution`
- `## Going further`
- `## References`

See `templates/lab/README.md` for the canonical skeleton.

## Style

Full writing rules are in `STYLE-GUIDE.md`. Highlights:

- Second person, present tense, active voice.
- No "in this lab we will". Start the Goal with the concrete thing the learner produces.
- No more than ~10 numbered steps.
- Link to specific pages in the official Claude Code docs, not just the docs root.

## Review checklist (for reviewers)

- [ ] Directory shape matches the convention exactly.
- [ ] `README.md` headings match the template in order.
- [ ] `verify.sh` exits 0 on the committed `solution/` copied into `starter/`.
- [ ] `verify.sh` exits non-zero on the committed unmodified `starter/`.
- [ ] `.lab-meta.yml` is valid YAML with all required fields.
- [ ] `INDEX.md` regenerated and committed.
- [ ] No `claude -p` calls in verify.
- [ ] No spoilers in the `## Steps` section.

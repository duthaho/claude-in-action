---
name: changelog-writer
description: Use when the user asks for a changelog, release notes, or a summary of what changed since a tag (keywords: changelog, release notes, what changed, Keep a Changelog). Produces a Markdown block formatted like Keep a Changelog, grouped by conventional-commit type.
---

# Changelog Writer

Produce a Keep-a-Changelog-formatted entry for commits since the most recent git tag.

## Procedure

1. Run `git describe --tags --abbrev=0` to find the most recent tag. If there is no tag, stop and tell the user the repo has no release history yet.
2. Run `git log <tag>..HEAD --oneline --no-merges` to get the commits since the tag.
3. For each commit, parse the conventional-commit type from the start of the subject (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `build`, `ci`, `perf`, `style`). Anything else becomes `chore`.
4. Map types to Keep a Changelog categories:
   - `feat` → **Added**
   - `fix` → **Fixed**
   - `refactor`, `perf` → **Changed**
   - `docs`, `chore`, `test`, `build`, `ci`, `style` → **Chores** (a category Keep a Changelog doesn't define but is common in real projects)
5. Emit a Markdown block in exactly this shape:

   ```markdown
   ## [Unreleased]

   ### Added
   - <subject> (`<short-hash>`)

   ### Changed
   - ...

   ### Fixed
   - ...

   ### Chores
   - ...
   ```

6. Omit empty categories. Sort commits within each category alphabetically by subject.

## Constraints

- Output only the Markdown block. No preamble, no explanation after.
- Short hashes are the first 7 characters of the commit SHA.
- Do not invent categories. If every commit is a `chore`, the block has only a `### Chores` section.

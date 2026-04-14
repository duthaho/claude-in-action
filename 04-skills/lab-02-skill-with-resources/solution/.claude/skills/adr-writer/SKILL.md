---
name: adr-writer
description: Use when the user asks to write, create, or draft an ADR, architecture decision record, or decision record. Picks between a short or long template based on the size of the decision, assigns the next ADR number, and writes the result to docs/adr/NNNN-<slug>.md.
---

# ADR Writer

Produce a new Architecture Decision Record from the user's request.

## Procedure

1. Parse the user's request to extract:
   - A short title for the decision (5–8 words).
   - The size: **short** for a one-line decision with no meaningful tradeoffs (style, formatting, naming conventions); **long** for anything that has context, alternatives, or downstream consequences. If the request describes why the decision matters or what was considered, pick long. When in doubt, ask the user.
2. Read the chosen template:
   - Short: `resources/template-short.md`
   - Long: `resources/template-long.md`
3. Scan `docs/adr/` for existing ADRs. Find the highest `NNNN` prefix and pick `NNNN + 1`, zero-padded to four digits. If `docs/adr/` is empty or missing, start at `0001`.
4. Generate a kebab-case slug from the title (lowercase, spaces to `-`, strip punctuation).
5. Fill in the template:
   - **Short**: title, status (`Proposed` dated today), decision paragraph.
   - **Long**: title, status, context, decision, consequences, alternatives considered, references. Never leave a heading empty — if the user's request didn't supply enough to fill a section, make your best inference and mark it italic (`*inferred: ...*`) so a reviewer can spot it.
6. Write the result to `docs/adr/NNNN-<slug>.md`.
7. Print one line to the user: `wrote: docs/adr/NNNN-<slug>.md (template: short|long)`.

## Constraints

- Do not modify existing ADRs.
- Do not invent section headings. Use exactly what the template provides.
- If the numbering scan finds a gap (e.g. `0001` and `0003` but no `0002`), still pick `highest + 1`. Do not fill gaps — they may be intentional supersessions.

# Report template

Every researcher emits its answer in exactly this shape. The lead stitches three of these together into the final report, preserving order by question number.

## Per-answer shape

```markdown
### Q: <the question, verbatim>

<one short paragraph, grounded in the corpus>

**Citations**
- `sources/<file>.md:LINE` — <the phrase or heading the claim comes from>
- `sources/<file>.md:LINE` — ...
```

## Synthesised report shape (the lead produces this)

```markdown
# paypal-lite research report

## Q1 — <question summary>
<Q1 answer block>

## Q2 — <question summary>
<Q2 answer block>

## Q3 — <question summary>
<Q3 answer block>

## Cross-findings
<Optional: notes that cut across more than one answer. Only include if genuinely relevant.>
```

## Why the template is pinned this hard

Synthesis is only mechanical when inputs are uniform. If researcher 1 writes three paragraphs with inline citations, researcher 2 writes bullet points, and researcher 3 writes a table, the lead has to reformat everything — at which point the parallelism bought you nothing. A pinned template makes synthesis a copy-and-paste job.

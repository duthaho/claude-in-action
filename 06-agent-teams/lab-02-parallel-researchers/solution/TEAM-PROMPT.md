# Team prompt

Paste the block below into Claude Code (from inside this directory) to start the team.

---

```text
Create an agent team to answer the three questions in QUESTIONS.md in parallel.

Spawn three teammates, all using the researcher agent type defined in .claude/agents/researcher.md. Assign each teammate exactly one question:

- researcher-1 → Q1 (refund SLA)
- researcher-2 → Q2 (webhook signatures)
- researcher-3 → Q3 (idempotency key reuse)

Each teammate:
- reads only from sources/
- produces output in the shape defined in REPORT-TEMPLATE.md
- cites path:line for every substantive claim

When all three have produced their answer blocks, synthesise them into a single report using the "Synthesised report shape" from REPORT-TEMPLATE.md. Do not paraphrase individual answers — copy them verbatim into the synthesis. Add a "Cross-findings" section at the end only if there is genuinely a theme connecting two or more answers.

When the synthesis is done, clean up the team.
```

---

## While the team runs

- Use Shift+Down to cycle through the three researchers.
- If a researcher starts wandering into another researcher's question, interrupt (Escape) and remind it to stay on its assigned question.
- If a question turns out to have no answer in the corpus, the researcher should say so explicitly — do not let it fabricate.

# Team prompt

Paste the block below into Claude Code (from inside this directory) to start the team.

---

```text
Create an agent team to implement SPEC.md in this directory. Spawn three teammates:

- Name: planner — use the planner agent type. Read SPEC.md and publish a task list of 5–8 items to the shared task list. Require plan approval before any task is marked actionable.
- Name: builder — use the builder agent type. Claim tasks one at a time from the list, implement each minimally, mark complete. Do not run tests.
- Name: tester — use the tester agent type. After builder marks a task complete, run `python -m unittest discover -s tests -v` and report pass/fail back to builder.

Coordination rules:
- Only approve planner's plan if every task names concrete file:line changes.
- If tester reports a failure, builder fixes it before claiming the next task.
- Clean up the team when every task is complete and tests pass.
```

---

## While the team runs

- Use Shift+Down to cycle through teammates and type to message them directly.
- Press Ctrl+T to toggle the task list view.
- If the lead starts doing work itself, tell it: "wait for your teammates to complete their tasks before proceeding".
- When every task is complete, tell the lead: "clean up the team".

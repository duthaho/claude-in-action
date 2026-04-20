# starter

You wire a `PreToolUse` hook that denies any `Edit` or `Write` whose `file_path` lands under `prod/`. The hook lives at `.claude/hooks/block-prod-writes.sh`; `test_block_prod_writes.sh` next to it is an offline test fixture you can run with `bash` — no Claude Code required.

See the top-level lab README for the step-by-step.

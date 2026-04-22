---
description: Draft a standup update from yesterday's git commits.
---

Summarise the current user's git activity for a standup note.

## Procedure

1. Run `git log --author="$(git config user.email)" --since="1 day ago" --oneline --no-merges`.
2. If there are no commits, reply `No commits in the last 24 hours.` and stop.
3. Otherwise emit three sections in this order, each one a single bullet:
   - **Yesterday**: one-sentence summary of the commits, grouped by theme if there are more than three.
   - **Today**: best guess at what is still in flight, based on the commit subjects.
   - **Blockers**: `none known` unless a commit message mentions "wip", "blocked", or "stuck".

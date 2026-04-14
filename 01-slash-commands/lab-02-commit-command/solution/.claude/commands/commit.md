---
description: Write a conventional commit message from the staged diff and commit after confirmation
---

You are commiting staged changes in the current git repo. Do this in order:

1. Run `git diff --cached` and read the staged changes.
2. Infer the most appropriate conventional-commit type (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `build`, `ci`, `perf`, `style`). Pick an optional scope from the top-level directory or module that most lines touch.
3. Compose a commit message with:
   - A subject line under 72 characters, imperative mood, no trailing period.
   - Optionally a body with a short bullet list of the concrete changes.
4. Show the proposed message to the user and ask them to approve, edit, or cancel. **Do not run `git commit` before the user approves.**
5. On approval, run `git commit -m <subject>` (using a heredoc if the body is non-empty).
6. Print the new commit's short hash and subject.

If the staged diff is empty, stop and tell the user there is nothing to commit.

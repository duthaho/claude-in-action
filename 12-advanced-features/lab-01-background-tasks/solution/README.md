# Solution — lab-01-background-tasks

> Try the steps in the lab's `README.md` first — peek here after.

## What background mode actually is

When Claude invokes the Bash tool with `run_in_background: true`, the child process is started detached and a shell id is returned immediately. The conversation continues — you can ask more questions, Claude can invoke more tools, none of it blocks on the background job. Two later tools read the state:

- **BashOutput** takes the shell id and returns whatever's accumulated on stdout/stderr since the last read, plus the shell's current state (`running` or `completed`). This is a *polling* interface, not a streaming one — each call is a snapshot.
- **KillShell** terminates the process.

That's the whole primitive. Everything else is UX layered on top.

## When it's worth the ceremony

Three situations earn the extra round-trip:

1. **Long, checkable commands.** A test suite, a build, a data import. You don't want to wait for it synchronously; you want to know it's running and poll when you're curious.
2. **Parallel shell work.** Start two imports at once, poll both, move on when both are done. Sequential shell calls can't do this.
3. **Runaway-command insurance.** If the command might hang, running it in the foreground means your only escape is Esc, which kills the whole tool call. Background mode + `KillShell` is more surgical.

## When it isn't

- **Short commands** (<3 s). The polling overhead dominates the actual work.
- **Commands whose output you need right now** to decide what to do next. If the very next tool call depends on what this command prints, background mode just forces Claude to poll in a loop — slower than running it synchronously.
- **Commands with side effects you want to confirm.** `rm -rf` should never be launched and forgotten. The whole point of waiting is you see what it reports.

## What the lab doesn't show

- Multiple concurrent background shells. You can launch N at once; BashOutput takes one shell id each, so polling them is a loop. Useful when you're running two databases and a web server side-by-side.
- Stdin. Background shells don't have an interactive stdin — if the process prompts, it'll hang forever. Always use non-interactive flags (`--yes`, `DEBIAN_FRONTEND=noninteractive`, etc.) on background commands.
- Output truncation. BashOutput returns everything accumulated since the last read, but Claude Code itself may truncate very long tail output. For huge logs, tee to a file and read the file directly.

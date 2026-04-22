# TRANSCRIPT — Background task walkthrough

This is the template your own `TRANSCRIPT.md` should follow. Fill in real output from your session, not this example text.

## ## Launch

Prompt to Claude:

> Run `bash slow-build.sh` in the background. Tell me the shell id.

Claude should invoke the Bash tool with `run_in_background: true` on `bash slow-build.sh`. Its reply includes a shell id like `bash_1` and confirms the task is running.

## ## Interleaved work

While the build runs, prompt to Claude:

> While that runs, count the number of `.sh` files under this directory and summarise what each one does.

Claude uses Glob + Read to inspect the starter, producing a summary without waiting on the build. This is the whole point: the background task doesn't block the conversation.

## ## Poll

Prompt to Claude:

> Check the background build's output so far without waiting for it to finish.

Claude uses BashOutput on the shell id. Mid-run you see something like:

```
Phase 1/4: compile
Phase 2/4: link
```

…with the shell still in the `running` state.

## ## Final

Prompt to Claude:

> Wait for the build to finish and tell me if it succeeded.

Claude polls BashOutput until it sees `BUILD SUCCESS` and the shell state becomes `completed`. Final output:

```
Phase 1/4: compile
Phase 2/4: link
Phase 3/4: test
Phase 4/4: package
BUILD SUCCESS: artifacts/app-2026-04-22T14:03:12Z.tar.gz
```

## ## What I learned

Two or three sentences in your own words. Suggested angles:

- Why is this different from running the build and waiting? (Answer: you keep the session responsive; you can pivot while waiting; you can kill a runaway.)
- When is `run_in_background: true` the wrong choice? (Answer: short commands — the overhead of polling outweighs the wait.)
- What would have happened without background mode when you asked the "count .sh files" question? (Answer: Claude would have blocked until the build finished, or you'd have had to cancel with Esc.)

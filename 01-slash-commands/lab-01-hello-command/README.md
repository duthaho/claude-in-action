# Lab 01 — Hello Command

> Section: 01-slash-commands · Difficulty: beginner · Est: 15 min

## Goal

You create a project-scoped slash command called `/hello` that greets you with the current repository's name. This is the smallest possible real slash command: one file, one instruction, one observable output. By the end you will know exactly where project commands live, what their frontmatter looks like, and how Claude turns the file into a callable action.

## Prerequisites

- Claude Code installed and logged in
- A working shell (bash, zsh, or PowerShell with `bash` available)

## What you'll build

- A new file at `.claude/commands/hello.md` inside `starter/`
- The file contains a short instruction that, when invoked, asks Claude to greet the user with the repo's name
- After invocation, `starter/.claude/commands/hello.md` exists and matches `solution/.claude/commands/hello.md`

## Steps

1. Change into the lab's starter directory:
   ```bash
   cd 01-slash-commands/lab-01-hello-command/starter
   ```
2. Notice the directory has a `README.md` and nothing else. There is no `.claude/` folder yet — you are going to create one.
3. Create the directory that holds project commands:
   ```bash
   mkdir -p .claude/commands
   ```
4. Create the file `.claude/commands/hello.md`. Give it a short YAML frontmatter block with a `description` field, then a one-line instruction that tells Claude to greet the user with the current repo's name. (Look at the template in `../../templates/lab/README.md` *only if you get stuck on the shape* — the file you need to write is about six lines long.)
5. Launch Claude Code from inside `starter/` and type `/hello`. Claude should respond with a greeting that contains the string `lab-01-hello-command` (the name of the current repo directory).
6. Exit Claude.

## Verify

Run the automated check from the lab directory:

```bash
bash ../../scripts/verify-lab.sh 01-slash-commands/lab-01-hello-command
```

It passes when `starter/.claude/commands/hello.md` exists and contains a `description:` frontmatter line plus a greeting instruction that mentions the repo name.

## Solution

See `solution/` for the finished command file. Try the steps first — the point of this lab is to find out what you don't know about where project commands live, not to copy a file.

## Going further

- Add an `argument-hint` field to the frontmatter and change the command to greet a named person: `/hello Alice`.
- Create a second command `.claude/commands/bye.md` and invoke it from the same session. What changed in how Claude announces available commands?
- Move the file to `~/.claude/commands/hello.md` and observe that the command is now available in every repo on your machine, not just this one.

## References

- [Official docs: Slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands)

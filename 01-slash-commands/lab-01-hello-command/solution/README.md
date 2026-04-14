# Solution — lab-01-hello-command

The finished state is a single file: `.claude/commands/hello.md`. It is about six lines long.

## Why this works

Claude Code discovers project-local slash commands by scanning the `.claude/commands/` directory of the current working repo at startup. Each `.md` file in that directory becomes a command — the filename (minus `.md`) is the command name, the YAML frontmatter provides metadata, and the body of the file is the instruction Claude follows when you invoke the command.

The body of `hello.md` asks Claude to greet the user with the current repo's name. Claude resolves "current repo" by looking at its working directory when the session started — that is why the greeting contains `lab-01-hello-command`, the name of the starter folder.

## Key decisions

- **We used `description:` in the frontmatter.** This is optional, but it's what Claude displays when you run `/help` or start typing `/hel`. Without it, the command shows up anonymously in the list.
- **We did not add `argument-hint:`.** The command takes no arguments. Adding an empty hint would clutter the help output.
- **The file is short on purpose.** A slash command's body is a natural-language instruction, not a script. More than a few sentences usually means the logic belongs in a skill, not a command.

## If you got stuck

- **"My command didn't show up in the list."** Did you launch Claude from inside `starter/`? Project commands are discovered relative to the working directory.
- **"Claude greeted me but didn't use the repo name."** Your instruction didn't tell Claude to read the working directory name. Say so explicitly in the body.
- **"I wrote `hello.sh` instead of `hello.md`."** Project commands are Markdown files, not shell scripts. Shell scripts go in hooks (section 08).

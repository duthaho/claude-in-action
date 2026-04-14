# Solution — lab-01-project-claude-md

The finished starter has two files: the unchanged `todo.py` and `README.md`, plus a new `CLAUDE.md` at the root. The `CLAUDE.md` below is one acceptable version — your wording can differ as long as it hits the three categories (summary, architecture, rules).

## Why this works

Claude Code loads `CLAUDE.md` from the repo root automatically at the start of every session that begins inside that repo. Everything in the file becomes part of Claude's system context — it doesn't need to be told "read CLAUDE.md", it already has. That makes `CLAUDE.md` the highest-leverage file you can write for a project: one paragraph of well-placed guidance changes every future interaction.

## The three categories and why each matters

- **Project summary.** Claude can read `README.md` too, but a one-paragraph project summary in `CLAUDE.md` is aimed at Claude specifically. It tells Claude *what you want it to remember*, which is usually different from what a human reader needs.
- **Architecture.** "Where does state live" is the single most useful sentence you can write. If Claude has to guess, it guesses wrong half the time — it invents a database, creates a new config file, or assumes a framework you don't use. Tell it the answer.
- **Rules.** These are negative constraints: *don't do this thing even if it seems helpful*. The three in this lab are real: Claude will add `click` if you don't tell it not to, will reformat functions it didn't need to touch, and will propose adding timestamps/priorities if it sees a todo data model.

## Key decisions

- **Short.** A good `CLAUDE.md` is 200–500 words. Longer files dilute the attention the model pays to each rule.
- **Written for the model, not for humans.** "Never add dependencies" is fine. "Per RFC-2119 we do not add dependencies" is a human document pretending to be useful.
- **Testing section even though there are no tests.** The point of the testing section here is to tell Claude what to do *when asked to add a feature* — propose a test, don't silently skip it.

## If you got stuck

- **"Claude still added argparse."** Your rules section probably said "avoid" instead of "never". "Never" works better; "avoid" is interpreted as a preference.
- **"My file is 2000 words long."** Cut it in half. Then cut it in half again. Anything that applies to every Python project probably belongs in user-level memory (lab 02).
- **"I wrote it in `docs/claude.md` instead of `CLAUDE.md`."** Only `CLAUDE.md` at the repo root is auto-loaded. Other locations require imports (lab 02).

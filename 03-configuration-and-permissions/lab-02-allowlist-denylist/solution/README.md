# Solution — lab-02-allowlist-denylist

The finished starter has one new file: `.claude/settings.json`. Its `permissions` object contains both an `allow` list (read-only tools) and a `deny` list (patterns that block `secrets/`).

## Why this works

Claude Code evaluates every tool call against the merged `permissions` object before letting the call proceed. The rule it uses is simple:

1. If any entry in `deny` matches the call, **reject** — even if something in `allow` also matches.
2. If any entry in `allow` matches the call, **accept** silently.
3. If neither matches, fall back to the current `defaultMode` (ask, accept-edits, bypass).

So `Read(./src/hello.py)` gets evaluated against the deny list (no match), then the allow list (`Read` matches), and is accepted. `Read(./secrets/api_key.txt)` gets evaluated against the deny list (`Read(./secrets/**)` matches) and is rejected before the allow list is even checked. `Write(./notes.txt)` gets evaluated against the deny list (no match), then the allow list (no match — `Write` is not allowed), and falls through to `defaultMode`, which asks for confirmation.

## Why deny beats allow

The order in the rule above — deny first — is the only sane default. If `allow` could override `deny`, then adding a general allowlist (`Read`) would silently unlock the thing you explicitly forbade (`Read(./secrets/**)`). You would have to write every allow rule as "not the denied paths", which is unreadable and error-prone. Deny-first means you can keep your allow list broad ("any read") and your deny list narrow ("these exact paths") without worrying about them colliding.

General principle: the sensitive thing always wins. Deny is sensitive.

## Why the allow list is exactly four tools

- `Read`, `Grep`, `Glob`, `LS` are the purely read-only tools. A session with only these four can explore the repo in depth but cannot change anything.
- `Write`, `Edit`, `NotebookEdit` are the file-modifying tools. Excluded.
- `Bash` is power. One `rm -rf` and you're having a bad day. Excluded.
- `Task`, `WebFetch`, `WebSearch` are net-adjacent tools. Excluded for a locked-down read-only session.

A real deployment might allow `Bash(git status:*)` and `Bash(git diff:*)` — very narrow bash rules — if the contractor needs to read git state. Anything broader than that is a foothold.

## Why `./secrets/**` and not `secrets/**`

Both work, but `./` makes the scope explicit: "relative to the project root, not some arbitrary `secrets/` elsewhere in the filesystem". Path patterns without a leading `./` can be ambiguous depending on the working directory. Be explicit.

## How to test rules without booting Claude

The trick the lab's `verify.sh` uses: parse `settings.json` as JSON and assert the shape. That's also how you should write a CI check for a real project. You don't need to actually run Claude to prove your settings file has the rules you intended — you just need to load the JSON and check.

## If you got stuck

- **"Claude still read the secret."** Either your `deny` pattern doesn't match the path you tested (check the path separator and leading `./`), or you put the rule in `settings.local.json` but launched Claude from a different working directory.
- **"Claude refused to read hello.py too."** You probably left `Read` off the allow list, or you wrote `"allow": "Read"` (string) instead of `"allow": ["Read"]` (array).
- **"Claude ran `ls` anyway."** `ls` runs through `Bash`, which isn't on the allow list. Did you maybe set `defaultMode` to `bypassPermissions`? Drop it back to `acceptEdits`.

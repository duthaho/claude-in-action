# INSTALL-LOG — lab-01-install-a-plugin

This is the *shape* of the log you create in your own lab root. Your exact output may vary (timestamps, session identifiers, phrasing).

## Added the marketplace

Command:

```
/plugin marketplace add ./marketplace
```

Claude Code read `./marketplace/.claude-plugin/marketplace.json` and registered it under the name `lab-marketplace` (taken from the manifest's `name` field). No errors.

## Installed the plugin

Command:

```
/plugin install greeter@lab-marketplace
```

Claude Code copied `./marketplace/plugins/greeter/` into its plugins directory under `~/.claude/` and wired the `/greet` command into the current session. No errors.

## Ran the command

Command:

```
/greet
```

Reply:

```
Hello from the greeter plugin!
```

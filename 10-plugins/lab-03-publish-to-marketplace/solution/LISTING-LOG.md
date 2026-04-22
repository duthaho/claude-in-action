# LISTING-LOG — lab-03-publish-to-marketplace

This is the *shape* of the log you create in your lab root. Your exact output may vary in phrasing.

## Registered the marketplace

Command:

```
/plugin marketplace add ./marketplace
```

Claude Code read `./marketplace/.claude-plugin/marketplace.json` and registered the marketplace as `claude-in-action-lab-market` (the `name` field in the manifest). No errors.

## Listed available plugins

Command:

```
/plugin
```

Relevant slice of output:

```
claude-in-action-lab-market
  quote-of-the-day    Motivational /quote command and a wordcount skill.
  daily-standup       Drafts a standup note from yesterday's git commits.
```

Both plugins appear under the marketplace. Each line shows `plugin-name  description`, matching what we put in `marketplace.json`.

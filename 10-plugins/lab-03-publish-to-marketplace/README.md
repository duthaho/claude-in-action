# Lab 03 — Publish to a Marketplace

> Section: 10-plugins · Difficulty: intermediate · Est: 30 min

## Goal

You take a fully-authored plugin (shipped in the starter — it is the solution from lab-02 plus a second plugin) and publish it by writing the `marketplace.json` that lists it. The marketplace hosts **two** plugins: `quote-of-the-day` and `daily-standup`. You populate `marketplace/.claude-plugin/marketplace.json` with both entries, then register the marketplace locally and confirm `/plugin` shows both listed. By the end you understand the `plugins[]` array shape, the `source` field's relative-path semantics, and the difference between a plugin's `plugin.json` (identity) and a marketplace's `marketplace.json` (directory listing).

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-02-author-a-plugin](../lab-02-author-a-plugin/) — you know how `plugin.json` works
- Tools: `python --version` ≥ 3.9 (only used by `verify.sh`)

## What you'll build

- `starter/marketplace/.claude-plugin/marketplace.json` — currently empty scaffold, you fill it in
- `LISTING-LOG.md` in the lab root — the Tier-2 evidence that `/plugin` actually shows both plugins after you register the marketplace

## Steps

1. Change into the starter:
   ```bash
   cd 10-plugins/lab-03-publish-to-marketplace/starter
   tree marketplace -L 3
   ```
   (If you don't have `tree`, use `find marketplace -maxdepth 3`.) You should see:
   ```
   marketplace/
     .claude-plugin/
       marketplace.json    # empty scaffold — you fill this
     plugins/
       quote-of-the-day/
         .claude-plugin/plugin.json
         commands/quote.md
         skills/wordcount/SKILL.md
         quotes.txt
       daily-standup/
         .claude-plugin/plugin.json
         commands/standup.md
   ```
2. Inspect each plugin's `plugin.json` so you know what `name` to list:
   ```bash
   python -c "import json; print(json.load(open('marketplace/plugins/quote-of-the-day/.claude-plugin/plugin.json'))['name'])"
   python -c "import json; print(json.load(open('marketplace/plugins/daily-standup/.claude-plugin/plugin.json'))['name'])"
   ```
3. Fill in `marketplace/.claude-plugin/marketplace.json`. The required fields are:
   - `name` — `"claude-in-action-lab-market"` (or any slug-style string; verify.sh accepts non-empty)
   - `owner.name` — a non-empty string
   - `plugins` — an array. Each entry has:
     - `name` — must match the plugin's own `plugin.json` name
     - `source` — relative path from the marketplace root to the plugin directory (so `"./plugins/quote-of-the-day"`, not `"plugins/quote-of-the-day"` — the leading `./` is conventional and unambiguous)
     - `description` — one sentence (surfaced by `/plugin` listing)
4. Validate the JSON locally:
   ```bash
   python -c "import json; json.load(open('marketplace/.claude-plugin/marketplace.json'))"
   ```
   Silent means valid.
5. Register the marketplace in Claude Code:
   ```
   /plugin marketplace add ./marketplace
   ```
   Then list what's available:
   ```
   /plugin
   ```
   You should see both `quote-of-the-day` and `daily-standup` under your marketplace.
6. Create `LISTING-LOG.md` in the lab root containing:
   - The command you ran (`/plugin marketplace add ./marketplace`).
   - The relevant slice of `/plugin` output showing both plugins listed (copy-paste or paraphrase — what matters is that both plugin names appear).

## Verify

```bash
bash ../../scripts/verify-lab.sh 10-plugins/lab-03-publish-to-marketplace
```

The script checks that:

- `starter/marketplace/.claude-plugin/marketplace.json` is valid JSON, has a non-empty `name`, and has `owner.name` set.
- The `plugins[]` array lists **both** `quote-of-the-day` and `daily-standup`, each with a `source` that (a) starts with `./` and (b) resolves to an existing directory containing a valid `.claude-plugin/plugin.json` with a matching `name`.
- `LISTING-LOG.md` exists and mentions both plugin names.

## Solution

See `solution/`. `solution/README.md` covers: why `source` is relative (so the marketplace works when cloned/forked to any path), the difference between the marketplace's `name` and the plugin's `name`, and how you would swap `"source": "./plugins/..."` for a git URL to ship a real public marketplace.

## Going further

- Add a `version` field at the marketplace level (not just per-plugin). What does it buy you vs per-plugin versioning?
- Ship a third plugin whose `source` points to a *sibling* directory, not inside `plugins/` (e.g. `"../shared/foo"`). Does `/plugin marketplace add` still accept it?
- Write a `verify-marketplace.sh` that walks every entry in `plugins[]`, resolves the `source` path, and confirms each one has a valid `plugin.json`. Pin this into CI for a real marketplace repo.

## References

- [Official docs: Plugin marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces) — the `marketplace.json` reference
- [Official docs: Plugins](https://docs.claude.com/en/docs/claude-code/plugins) — for contrast, the `plugin.json` reference

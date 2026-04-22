# Solution — lab-03-publish-to-marketplace

> Try the steps in the lab's `README.md` first — peek here after.

## Two manifests, two purposes

This is the subtle point of the lab:

- `plugin.json` is **identity** — the plugin declaring itself. It travels with the plugin and never changes when the plugin is redistributed.
- `marketplace.json` is **a directory listing** — which plugins live at which relative paths inside *this* marketplace. It is specific to one marketplace; the same plugin can appear in many marketplaces, each with its own `marketplace.json` entry.

The `name` field appears in both, and must agree. The marketplace's `plugins[].name` is *how users install the plugin* (`/plugin install <that-name>@<marketplace>`); the plugin's own `plugin.json` `name` is *what the plugin calls itself*. If they disagree, `/plugin install` looks up the right folder, finds a name mismatch, and refuses — save yourself the debugging by making them identical.

## Why `source` is relative

Using a relative path (`./plugins/quote-of-the-day`) means the marketplace works wherever it's cloned, forked, or moved — a user can `git clone` the repo to any local directory and `/plugin marketplace add ./path-to-clone` just works. An absolute path would break as soon as the marketplace leaves the author's machine.

The leading `./` is conventional but not strictly required. Writing it explicitly disambiguates: a reader knows instantly the path is relative and rooted at the marketplace directory, not at their shell's current working directory.

## Swapping local paths for git URLs

The same `marketplace.json` shape works for a public marketplace — change each plugin's `source` from `"./plugins/quote-of-the-day"` to a git-URL-based source (e.g. `{"type": "git", "url": "..."}`) and users get the plugin fetched from there instead of from a local directory. The rest of the shape is identical. That is why `marketplace.json` exists as an indirection layer: it lets a single manifest describe either a local working copy or a distributed registry without changing shape.

## What happens on `/plugin marketplace add`

Claude Code:

1. Resolves the given path or URL.
2. Reads `<that-path>/.claude-plugin/marketplace.json`.
3. Validates that it has `name`, `owner`, and a `plugins[]` array.
4. Stores a reference to the marketplace under the name in the manifest — not under the path you gave. That is why `@marketplace-name` in `/plugin install` disambiguates, not `@marketplace-path`.

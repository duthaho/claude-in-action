# Solution — lab-03-ci-integration

> Try the steps in the lab's `README.md` first — peek here after.

## Why this workflow is shaped the way it is

Three choices are worth pausing over:

### 1. Read-only tools

`--allowedTools "Read,Glob,Grep"` is the single most important line in the file. In CI, an LLM with write access to a clean runner is low-blast-radius (the runner is ephemeral) but an LLM with write access to a *PR branch* can push code you didn't author. Read-only means the worst case is a bad comment. Worst cases of a bad comment are embarrassing; worst cases of an unauthorised push are a security incident.

### 2. Diff as input, not the whole repo

`claude -p "..." < pr.diff` sends only the changes. You *could* check out the whole repo and let Claude Glob/Grep through it, which produces richer reviews — but at much higher token cost, and with a risk that Claude fixates on unrelated code. A diff-scoped review is a forcing function for the agent to stay on topic. If Claude needs surrounding context, it can still Read specific files.

### 3. `--max-turns 4`

Four turns is generous for a review: enough to skim the diff, pull one or two relevant files with Read, and answer. Unbounded turn counts on autoreview are how you discover that Claude has spent twelve turns reading the test harness when you wanted it to comment on the one-line API change. The cap is a safety rail, not a performance optimisation.

## What this workflow doesn't do (yet)

- **Incremental diffs.** Every push re-reviews the full PR diff from the base. On a PR with many commits and long rebase history, that's wasteful. A smarter workflow diffs against the previous review's SHA and only reviews the new commits.
- **Cost limits.** Nothing caps how much this workflow can spend on a very large diff. In production, you'd add a diff-size guard: if `wc -c < pr.diff` exceeds some threshold, either skip or chunk the review.
- **Inline comments.** `createComment` on the issue (which is the PR) posts a summary comment. Real review tooling posts line-anchored comments via `createReviewComment`, which requires parsing Claude's output into file/line references. That's a whole lab on its own.
- **Gating the merge.** This workflow reviews but doesn't block. If you want Claude's severity bullets to mark the PR as failing, add a final step that `exit 1`s when Claude emits something tagged "blocker". Do this carefully: LLM severity tags are inconsistent and will produce flaky gates.

## The secret management side

`ANTHROPIC_API_KEY` must be added to the repo's **Actions secrets** (`Settings → Secrets and variables → Actions`). Alternatives worth knowing:

- **Environment-scoped secrets.** If you have `staging` and `production` environments configured on the repo, you can key-per-environment. Useful when different teams share one repo.
- **OIDC + short-lived credentials.** For very security-sensitive orgs, avoid long-lived keys entirely: the runner exchanges an OIDC token for an API credential per run. More setup; much lower leak risk.

For most repos, a plain Actions secret is fine. Just don't paste the key into code, and don't let it log.

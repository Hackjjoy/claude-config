---
name: morning-briefing
description: Generate a sectioned morning briefing for Daniel's projects by scanning GitHub remote activity (via `gh`, no pull), Notion (Stratosphere only), plus last-touched files in the 2nd-brain vault, then writing a daily note to `wiki/daily/YYYY-MM-DD-<project>.md`. Supports `stellar`, `stratosphere`, or `all`. Triggers on "morning briefing", "모닝 브리핑", "오늘 뭐 해야해", "/morning-briefing", or any "what should I do today" question framed in a project context.
---

# Morning Briefing

Reads remote state across GitHub (and Notion for Stratosphere) and the user's vault, synthesizes a "what to do today" briefing, and writes it as a daily note in the Obsidian vault. **No `git pull`.** All GitHub data goes through `gh` against the remote.

## Vault root

```
$HOME/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain
```

**Always use `$HOME/...` inside double-quoted shell arguments.** `"~/..."` does NOT expand on the Google Drive mount and will create a literal `~` directory.

## Scope

| Project      | GitHub org            | Notion teamspaces                           |
| ------------ | --------------------- | ------------------------------------------- |
| Stellar      | `stellarlabsai`       | — (not scanned)                             |
| Stratosphere | `stratosphere-games`  | `Stratosphere Games`, `Engineering`         |

If the user names anything outside this table, refuse and stop. Do not fabricate data.

## Inputs

- **Project**: `stellar`, `stratosphere`, or `all`. Anything else → refuse. **Default depends on host** (see below).
- **Today**: local date as `YYYY-MM-DD`.
- **Since**: yesterday 00:00 local. (Future iterations may pick the last briefing's date; v2 is fixed at yesterday.)

### Host-based default

The two projects live behind two different GitHub accounts (Stellar = personal MacBook account, Stratosphere = Mac mini work account `DanielChoiS`). Picking the wrong default produces "Invalid search query" / empty repo list errors. So:

```bash
HOST=$(scutil --get LocalHostName 2>/dev/null || hostname)
case "$HOST" in
  Daniels-Mac-mini*|Macmini*) DEFAULT_PROJECT=stratosphere ;;
  *MacBook*|*macbook*)        DEFAULT_PROJECT=stellar ;;
  *)                          DEFAULT_PROJECT=stellar ;;   # fallback
esac
```

Use `DEFAULT_PROJECT` only when the user did not specify one. If the user explicitly says `stellar` / `stratosphere` / `all`, honor that — but warn before running if the host doesn't have a token for that org (e.g. running `stellar` on Mac mini will fail at `gh repo list`).

Compute these once per run:

```bash
TODAY=$(date +%Y-%m-%d)
SINCE_DATE=$(date -v-1d +%Y-%m-%d)            # macOS BSD date
SINCE_ISO="${SINCE_DATE}T00:00:00Z"           # for gh api ?since=
SINCE_LOCAL_FIND="${SINCE_DATE} 00:00:00"     # for find -newermt
VAULT="$HOME/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain"
DAILY_DIR="$VAULT/wiki/daily"
```

## Per-project config

Pick the config(s) based on the input. For `all`, run the full pipeline once per project, producing one file per project.

### Stellar

```
PROJECT=stellar
ORG=stellarlabsai
OUT="$DAILY_DIR/${TODAY}-stellar.md"
NOTION_TEAMSPACE_IDS=()        # none
```

### Stratosphere

```
PROJECT=stratosphere
ORG=stratosphere-games
OUT="$DAILY_DIR/${TODAY}-stratosphere.md"
NOTION_TEAMSPACE_IDS=(
  "14c25585-93e7-8122-88fe-004212d50174"   # Stratosphere Games
  "2a925585-93e7-8169-91d7-004279be5dd9"   # Engineering
)
```

## Preflight

Run these checks before any data gathering. If any fails, surface the failure and stop — do not write a partial briefing.

```bash
gh auth status                       # must be logged in with read:org + repo
gh api user --jq '.login'            # capture for later filters; expected: DanielChoiS
test -d "$VAULT" || echo "VAULT MISSING"
mkdir -p "$DAILY_DIR"
```

If any `$OUT` already exists, ask the user before overwriting.

For Stratosphere/all, also confirm the Notion MCP is connected — the `mcp__notion__notion-search` tool must be available. If it is not, surface the failure and skip the Notion section (don't fail the whole run).

## Step 1 — Auto-discover repos

Per project:

```bash
gh repo list "$ORG" --limit 200 --no-archived \
  --json name,defaultBranchRef,updatedAt,isFork \
  > "/tmp/${PROJECT}-repos.json"
```

Drop forks. Treat the remainder as the universe of that project's repos. For the "Moved while I was away" section, narrow further to repos with `updatedAt >= SINCE_ISO` to avoid wasted calls.

## Step 2 — Gather GitHub data

These calls are independent — run them in parallel where the runtime allows. Keep `--json` field lists minimal. **All search calls are scoped to the project's org via `--owner=$ORG`** so a single run only surfaces the current project's items.

### 2a. Awaiting my review

```bash
gh search prs --review-requested=@me --state=open --owner="$ORG" --limit 50 \
  --json url,title,repository,author,createdAt,updatedAt
```

### 2b. Notifications since yesterday

```bash
gh api "/notifications?all=false&since=${SINCE_ISO}" \
  --jq '.[] | {reason, repo: .repository.full_name, title: .subject.title, type: .subject.type, api_url: .subject.url, updated: .updated_at}'
```

Notifications are not org-filterable at the API level, so fetch once per run and bucket client-side: keep entries where `repo` starts with `${ORG}/`. If running for `all`, you can fetch this once and split between the two output files.

`subject.url` is an API URL. Convert to a web URL when rendering: replace `https://api.github.com/repos/` with `https://github.com/` and rewrite `/pulls/` → `/pull/` for PR subjects.

### 2c. My open PRs

```bash
gh search prs --author=@me --state=open --owner="$ORG" --limit 50 \
  --json url,title,repository,createdAt,updatedAt
```

For each PR with `updatedAt >= SINCE_ISO`, fetch lightweight status:

```bash
gh pr view <url> --json state,reviewDecision,statusCheckRollup,comments,reviews,updatedAt
```

Skip `gh pr view` for stale PRs to keep the run fast.

### 2d. Issues I'm assigned (open, recently updated)

```bash
gh search issues --assignee=@me --state=open --owner="$ORG" --updated=">=${SINCE_DATE}" --limit 50 \
  --json url,title,repository,updatedAt
```

### 2e. Issues mentioning me (open, recently updated)

```bash
gh search issues --mentions=@me --state=open --owner="$ORG" --updated=">=${SINCE_DATE}" --limit 50 \
  --json url,title,repository,updatedAt,author
```

Deduplicate against 2d on URL.

### 2f. Commits on default branches since yesterday

Loop over the recently-updated subset of discovered repos:

```bash
jq -r --arg since "$SINCE_ISO" \
  '.[] | select(.isFork==false) | select(.updatedAt >= $since) | "\(.name)\t\(.defaultBranchRef.name)"' \
  "/tmp/${PROJECT}-repos.json" |
while IFS=$'\t' read -r repo branch; do
  [ -z "$branch" ] && continue
  gh api "repos/${ORG}/${repo}/commits?sha=${branch}&since=${SINCE_ISO}&per_page=50" \
    --jq '.[] | {repo: "'"$repo"'", sha: .sha[0:7], msg: (.commit.message | split("\n")[0]), author: (.author.login // .commit.author.name), date: .commit.author.date, url: .html_url}'
done
```

If a repo returns 0 commits, omit it from the section. Note: default branch names vary per repo (e.g. `ageofsteel` uses `dev`, others use `main`) — always read `defaultBranchRef.name` from the JSON, never hardcode.

## Step 3 — Notion activity (Stratosphere only)

Skip this step entirely for Stellar.

For each teamspace ID in `NOTION_TEAMSPACE_IDS`, call `mcp__notion__notion-search`:

```
query: "recent activity updates"
query_type: "internal"
teamspace_id: <id>
page_size: 20
max_highlight_length: 120
filters: {}
```

The search response includes a human-readable `timestamp` field per result (e.g. `"Past day (2026-05-04)"`, `"5 days ago (2026-04-29)"`, `"Today"`). Parse the absolute date in parentheses; if no parentheses (e.g. bare `"Today"`), treat as today.

**Filter rule**: keep results where the parsed date `>= SINCE_DATE`. Drop everything older.

**Source filter**: by default, keep all source types the search returns (Notion pages, Slack messages, Microsoft Teams, Outlook, Github connector results). Slack/Outlook/Teams items are noisy — surface them only if they look directly addressed to the user (e.g. `Daniel` in highlight, an `@me` mention, or `subject` referencing a PR/issue). When in doubt, prefer Notion-native pages.

Render each surviving result as a bullet with title, URL, and relative date. Group by teamspace name.

If a teamspace returns 0 surviving results, omit that subsection entirely (per the empty-section rule).

If `mcp__notion__notion-search` is unavailable or errors, record the failure under `## Gaps` and continue with GitHub-only output.

## Step 4 — Last-touched vault files

Vault scan is shared across projects (the vault is one tree). Run once per overall briefing run, not once per project, but include the rendered list in each project's file.

```bash
find "$VAULT" \
  -type f -name "*.md" \
  -newermt "$SINCE_LOCAL_FIND" \
  -not -path "*/.obsidian/*" \
  -not -path "*/wiki/daily/*" \
  -not -path "*/Clippings/*" \
  -not -path "*/temp/*" \
  -print
```

Render each as a vault-relative path (strip `$VAULT/`).

## Step 5 — Synthesize and write

Use the **Write** tool (not a heredoc) to put the rendered markdown at `$OUT`. Heredocs trip on backticks and the vault's spaces.

For `project=all`, write two files (`${TODAY}-stellar.md` and `${TODAY}-stratosphere.md`) — do not merge.

### Template

```markdown
# {{TODAY}} Morning Briefing — {{PROJECT_TITLE}}

_Since {{SINCE_DATE}}. Scanned {{N_REPOS}} repos under `{{ORG}}`{{NOTION_SUFFIX}}._

## Top 3 for today
1. ...
2. ...
3. ...

## What to do today
- [ ] 
- [ ] 
- [ ] 

## Awaiting me
- [#123 PR title](url) — `repo`, opened by @author, Nh ago

## My open PRs
- [#119 PR title](url) — `repo` • CI: failed • review: changes_requested • last activity Nh ago

## Moved while I was away
- **repo-name** — Nc commits
  - `abc1234` first line of commit msg (@author)

## Issues I'm in
- [#42 title](url) — `repo`, assigned, updated Nh ago

## Notion activity — {{TEAMSPACE_NAME}}
- [Page title](url) — Nd ago

## Yesterday's loose ends
- `wiki/some-note.md` — touched Nh ago
```

`{{PROJECT_TITLE}}` is `Stellar` or `Stratosphere`. `{{NOTION_SUFFIX}}` is empty for Stellar, ` plus 2 Notion teamspaces` for Stratosphere. The `## Notion activity` section appears once per teamspace and only for Stratosphere.

### Rules

- **Skip empty sections entirely** — do not write "no items" / "nothing here". A briefing with fewer sections is fine. **Exception**: `## What to do today` is *always* rendered with three empty checkboxes — it's a placeholder for the user to fill in, not data the skill provides.
- **One line per bullet.** Truncate long titles to ~80 chars.
- **Relative times** ("3h ago", "2d ago") not absolute timestamps. Compute against now.
- **Top 3** is synthesized from the rest using these priors:
  1. PRs awaiting *my* review (I block someone) — usually #1.
  2. CI-red on my own open PRs (fix before standup).
  3. @-mention notifications (a question waiting on me).
  4. Stale PRs of mine (no movement >5 days) — list but rarely top-3.
  5. Notion items with @-mentions of me (Stratosphere only).
  Adjust if a section clearly outweighs the priors (e.g. a P0 incident issue).
- **Author of issue** in 2e: if `author.login == $me`, drop it (don't show me my own mentions of myself).
- **Gaps section** at the bottom — only include if a `gh` or Notion call rate-limited or otherwise failed mid-run. Format:
  ```markdown
  ## Gaps
  - Skipped: 2c (rate-limited at 14:32). Re-run after 15:00.
  ```

## Step 6 — Report back

After writing the file(s), print to the terminal:

1. The output path(s) (clickable in most terminals).
2. The "Top 3 for today" block from each file, inline.

That's it — keep terminal output to those two things so the user can scan it without opening the vault.

## Failure modes

| Failure                                  | Action                                                                                    |
| ---------------------------------------- | ----------------------------------------------------------------------------------------- |
| `gh auth status` not logged in           | Tell user to run `gh auth login`. Stop.                                                   |
| `gh repo list` returns empty             | Token likely lost `read:org`. Surface and stop — do not write an empty briefing.          |
| Vault path not present (Drive offline)   | Tell user, stop.                                                                          |
| Single `gh` call rate-limits             | Finish other sections; record under `## Gaps` at the bottom of the briefing.              |
| `mcp__notion__notion-search` unavailable | Skip Notion step, record under `## Gaps`, continue with GitHub-only briefing.             |
| User asks for a project not in the table | Refuse, no fabrication.                                                                   |

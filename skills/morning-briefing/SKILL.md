---
name: morning-briefing
description: Generate a sectioned morning briefing for Daniel's Stellar project by scanning GitHub remote activity (via `gh`, no pull) plus last-touched files in the 2nd-brain vault, then writing a daily note to `wiki/daily/YYYY-MM-DD-<project>.md`. v1 covers Stellar only; Stratosphere is out of scope. Triggers on "morning briefing", "모닝 브리핑", "오늘 뭐 해야해", "/morning-briefing", or any "what should I do today" question framed in a Stellar / project context.
---

# Morning Briefing

Reads remote state across GitHub and the user's vault, synthesizes a "what to do today" briefing, and writes it as a daily note in the Obsidian vault. **No `git pull`.** All GitHub data goes through `gh` against the remote.

## Vault root

```
$HOME/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain
```

**Always use `$HOME/...` inside double-quoted shell arguments.** `"~/..."` does NOT expand on the Google Drive mount and will create a literal `~` directory.

## Scope

| Project      | Status                                          |
| ------------ | ----------------------------------------------- |
| Stellar      | Supported. GitHub org `stellarlabsai`.          |
| Stratosphere | Out of scope (lives on a Mac mini). If asked, say so and stop. Do not fabricate data. |

## Inputs

- **Project**: default `stellar`. If user says anything else, refuse.
- **Today**: local date as `YYYY-MM-DD`.
- **Since**: yesterday 00:00 local. (Future iterations may pick the last briefing's date; v1 is fixed at yesterday.)

Compute both representations:

```bash
TODAY=$(date +%Y-%m-%d)
SINCE_DATE=$(date -v-1d +%Y-%m-%d)            # macOS BSD date
SINCE_ISO="${SINCE_DATE}T00:00:00Z"           # for gh api ?since=
SINCE_LOCAL_FIND="${SINCE_DATE} 00:00:00"     # for find -newermt
VAULT="$HOME/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain"
DAILY_DIR="$VAULT/wiki/daily"
OUT="$DAILY_DIR/${TODAY}-stellar.md"
```

## Preflight

Run these checks before any data gathering. If any fails, surface the failure and stop — do not write a partial briefing.

```bash
gh auth status                       # must be logged in with read:org + repo
gh api user --jq '.login'            # capture for later filters
test -d "$VAULT" || echo "VAULT MISSING"
mkdir -p "$DAILY_DIR"
```

If `$OUT` already exists, ask the user before overwriting.

## Step 1 — Auto-discover Stellar repos

```bash
gh repo list stellarlabsai --limit 200 --no-archived \
  --json name,defaultBranchRef,updatedAt,isFork \
  > /tmp/stellar-repos.json
```

Drop forks. Treat the remainder as the universe of Stellar repos. For the "Moved while I was away" section, narrow further to repos with `updatedAt >= SINCE_ISO` to avoid wasted calls.

## Step 2 — Gather GitHub data

These calls are independent — run them in parallel where the runtime allows. Keep `--json` field lists minimal.

### 2a. Awaiting my review

```bash
gh search prs --review-requested=@me --state=open --limit 50 \
  --json url,title,repository,author,createdAt,updatedAt
```

### 2b. Notifications since yesterday

```bash
gh api "/notifications?all=false&since=${SINCE_ISO}" \
  --jq '.[] | {reason, repo: .repository.full_name, title: .subject.title, type: .subject.type, api_url: .subject.url, updated: .updated_at}'
```

`subject.url` is an API URL. Convert to a web URL when rendering: replace `https://api.github.com/repos/` with `https://github.com/` and rewrite `/pulls/` → `/pull/` for PR subjects.

### 2c. My open PRs

```bash
gh search prs --author=@me --state=open --limit 50 \
  --json url,title,repository,createdAt,updatedAt
```

For each PR with `updatedAt >= SINCE_ISO`, fetch lightweight status:

```bash
gh pr view <url> --json state,reviewDecision,statusCheckRollup,comments,reviews,updatedAt
```

Skip `gh pr view` for stale PRs to keep the run fast.

### 2d. Issues I'm assigned (open, recently updated)

```bash
gh search issues --assignee=@me --state=open --updated=">=${SINCE_DATE}" --limit 50 \
  --json url,title,repository,updatedAt
```

### 2e. Issues mentioning me (open, recently updated)

```bash
gh search issues --mentions=@me --state=open --updated=">=${SINCE_DATE}" --limit 50 \
  --json url,title,repository,updatedAt,author
```

Deduplicate against 2d on URL.

### 2f. Commits on default branches since yesterday

Loop over the recently-updated subset of discovered repos:

```bash
jq -r --arg since "$SINCE_ISO" \
  '.[] | select(.isFork==false) | select(.updatedAt >= $since) | "\(.name)\t\(.defaultBranchRef.name)"' \
  /tmp/stellar-repos.json |
while IFS=$'\t' read -r repo branch; do
  [ -z "$branch" ] && continue
  gh api "repos/stellarlabsai/${repo}/commits?sha=${branch}&since=${SINCE_ISO}&per_page=50" \
    --jq '.[] | {repo: "'"$repo"'", sha: .sha[0:7], msg: (.commit.message | split("\n")[0]), author: (.author.login // .commit.author.name), date: .commit.author.date, url: .html_url}'
done
```

If a repo returns 0 commits, omit it from the section.

## Step 3 — Last-touched vault files

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

## Step 4 — Synthesize and write

Use the **Write** tool (not a heredoc) to put the rendered markdown at `$OUT`. Heredocs trip on backticks and the vault's spaces.

### Template

```markdown
# {{TODAY}} Morning Briefing — Stellar

_Since {{SINCE_DATE}}. Scanned {{N_REPOS}} repos under `stellarlabsai`._

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

## Yesterday's loose ends
- `wiki/some-note.md` — touched Nh ago
```

### Rules

- **Skip empty sections entirely** — do not write "no items" / "nothing here". A briefing with fewer sections is fine. **Exception**: `## What to do today` is *always* rendered with three empty checkboxes — it's a placeholder for the user to fill in, not data the skill provides.
- **One line per bullet.** Truncate long titles to ~80 chars.
- **Relative times** ("3h ago", "2d ago") not absolute timestamps. Compute against now.
- **Top 3** is synthesized from the rest using these priors:
  1. PRs awaiting *my* review (I block someone) — usually #1.
  2. CI-red on my own open PRs (fix before standup).
  3. @-mention notifications (a question waiting on me).
  4. Stale PRs of mine (no movement >5 days) — list but rarely top-3.
  Adjust if a section clearly outweighs the priors (e.g. a P0 incident issue).
- **Author of issue** in 2e: if `author.login == $me`, drop it (don't show me my own mentions of myself).
- **Gaps section** at the bottom — only include if a `gh` call rate-limited or otherwise failed mid-run. Format:
  ```markdown
  ## Gaps
  - Skipped: 2c (rate-limited at 14:32). Re-run after 15:00.
  ```

## Step 5 — Report back

After writing the file, print to the terminal:

1. The output path (clickable in most terminals).
2. The "Top 3 for today" block, inline.

That's it — keep terminal output to those two things so the user can scan it without opening the vault.

## Failure modes

| Failure                                  | Action                                                                          |
| ---------------------------------------- | ------------------------------------------------------------------------------- |
| `gh auth status` not logged in           | Tell user to run `gh auth login`. Stop.                                         |
| `gh repo list` returns empty             | Token likely lost `read:org`. Surface and stop — do not write an empty briefing.|
| Vault path not present (Drive offline)   | Tell user, stop.                                                                |
| Single `gh` call rate-limits             | Finish other sections; record under `## Gaps` at the bottom of the briefing.    |
| User asks for Stratosphere               | Refuse for v1, no fabrication.                                                  |

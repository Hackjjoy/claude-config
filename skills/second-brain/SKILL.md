---
name: second-brain
description: Interact with the user's Obsidian/Google Drive second brain vault from any project. Two modes — (1) upload — add markdown source material to `raw/` so the vault's own ingest flow can turn it into wiki pages; (2) query — answer a question by reading `wiki/index.md` and the relevant wiki pages. Triggers on "second brain", "세컨드 브레인", "raw에 추가", "wiki에서 찾아봐", "브레인에 물어봐", "upload to second brain", "ask my wiki", or any question that clearly wants the user's accumulated knowledge rather than a fresh answer.
---

# Second Brain

Reads and writes against the user's Obsidian vault. The vault root:

```
$HOME/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain
```

**Always use `$HOME/...` inside double-quoted shell arguments.** `"~/..."` does NOT expand — it would create a literal `~` directory on the Google Drive mount.

Vault layout:

| Folder | Contents | This skill's access |
|---|---|---|
| `raw/` | Immutable markdown source material, flat | **Write new files only.** Never modify or delete existing. |
| `Clippings/` | Web-clipper output, flat, read-only per vault rules | Never write. |
| `wiki/` | Claude-authored knowledge pages, flat, kebab-case | **Read only.** Wiki authoring happens inside the vault project, not here. |
| `wiki/index.md` | Master catalog — entry point for any query | Read only. |
| `wiki/log.md` | Append-only history | Do not touch. |

## Pick the mode

| Signal | Mode |
|---|---|
| User pasted text, handed over a `.md` path, said "raw에 추가" / "upload to second brain" / "이거 저장해줘" | **upload** |
| Question phrased as "what do I know about X", "브레인에서 찾아봐", "check my wiki", or anything that wants their accumulated knowledge | **query** |
| Ambiguous | Ask. |

---

## Mode 1: Upload (source → `raw/`)

Scope: place one new file under `raw/`. Ingestion (raw/ → wiki/) is a separate operation triggered inside the vault project — this skill does not run it.

### Step 1. Determine source
- **Inline**: user pasted or dictated content → compose, then write.
- **Path**: user gave a `.md` path → `cp` into `raw/`.

If they only described a topic, ask — do not fabricate material for the vault.

### Step 2. Filename
- `.md` extension required.
- Preserve the human title. Spaces, original casing, and Korean are all fine in `raw/` (see existing files like `Claude Opus 4.7.md`, `Stratosphere Games -- Desync 원인과 해법.md`). Do **not** force kebab-case — that's a `wiki/` convention.
- If no title given, derive from the first `#` heading or ask.
- Check collision with `ls` before writing. If the filename exists, stop and ask: overwrite, rename, or cancel. `raw/` is immutable — default to not overwriting.

### Step 3. Write or copy
**Inline** — use the Write tool with the absolute path:
```
$HOME/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain/raw/<name>.md
```
Ensure the file opens with a `# Title` heading if the content lacks one.

**Path** — `cp` via Bash, using `$HOME`:
```bash
cp "<source-path>" "$HOME/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain/raw/<name>.md"
```
Default is copy, not move. Only move if the user explicitly asked.

### Step 4. Verify and report
- `ls -la` on the new file.
- Report final filename, size, and remind that ingest still has to run inside the vault project (`/ingest` in the Daniel 2nd Brain workspace) — this skill does not trigger it.

### Upload guardrails
- Never write to `Clippings/` or `wiki/` via this skill.
- Never delete or rename existing `raw/` files.
- Non-markdown input (PDF, HTML, image): ask whether to convert first or drop in as-is. Vault ingest is written for markdown.
- URLs: ask — WebFetch-based extract, user-written summary, or a stub pointing at the URL? Don't silently fetch and dump raw HTML.

---

## Mode 2: Query (ask the wiki)

Scope: answer a question using only what's in `wiki/`. Read-only — wiki authoring belongs to the vault project, not here.

### Step 1. Read the index
Always start by reading `wiki/index.md`:
```
$HOME/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain/wiki/index.md
```
It's the master catalog; it tells you which pages exist and how they're categorized. Skipping it leads to missed pages.

### Step 2. Select pages
Pick the 1–5 most relevant `wiki/*.md` pages from the index. If the index is ambiguous, grep:
```bash
grep -l -i "<keyword>" "$HOME/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain/wiki/"*.md
```

### Step 3. Read and synthesize
Read the selected pages, then answer directly:
- Cite pages using `[[page-name]]` (kebab-case, no extension — vault's wiki-link convention).
- Pull out specific facts, numbers, decisions, techniques. Not vague paraphrase — the user wrote these pages and will spot weak summaries immediately.
- If the page's top "Takeaway for my game dev journey" callout is relevant, quote it verbatim.
- Flag contradictions between pages when you find them.

### Step 4. Gaps
If the wiki doesn't cover the question, or coverage is thin, say so plainly. Offer either:
- (a) queue a raw/ upload to close the gap (switches to upload mode), or
- (b) direct the user into the vault project to run `/ingest` or author a new page.

Do **not** write wiki pages from this skill.

### Query guardrails
- Read-only across `wiki/` — never edit `wiki/*.md`, `wiki/index.md`, or `wiki/log.md`.
- Prefer quoting specific lines over paraphrasing.
- Wiki pages are English by default (per vault style guide); `raw/` may be Korean. Match the user's question language for the answer.

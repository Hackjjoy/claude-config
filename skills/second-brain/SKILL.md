---
name: second-brain
description: Interact with the user's Obsidian/Google Drive second brain vault from any project, on macOS or Windows. Three modes — (1) upload — stage markdown source material into `raw/`; (2) ingest — synthesize `raw/` material into `wiki/` pages following the vault's own ingest procedure; (3) query — answer a question by reading `wiki/index.md` and the relevant wiki pages. Triggers on "second brain", "세컨드 브레인", "raw에 추가", "wiki에 추가", "위키로 만들어줘", "ingest this", "wiki에서 찾아봐", "브레인에 물어봐", "upload to second brain", "ask my wiki", or any question that clearly wants the user's accumulated knowledge rather than a fresh answer.
---

# Second Brain

Reads and writes against the user's Obsidian vault from any working directory, on macOS or Windows.

## Resolve the vault path first

The vault lives on a Google Drive mount whose location differs per OS (macOS: `~/Library/CloudStorage/GoogleDrive-…/My Drive/…`; Windows Git Bash: a drive letter like `/g/My Drive/…`). **Never hardcode the path.** Resolve it once at the start of any operation:

```bash
VAULT="$(bash "$HOME/.claude/scripts/second-brain-path.sh")" || {
  echo "Could not locate the second brain vault. If it lives somewhere unusual, set SECOND_BRAIN_VAULT to its path."; exit 1;
}
```

- The detector checks (in order): `$SECOND_BRAIN_VAULT` override → macOS CloudStorage mounts → Windows drive letters → home-folder Drive layouts.
- Use `"$VAULT/..."` (double-quoted — the path contains spaces) in every Bash command.
- The **Write tool needs a literal absolute path**, not a shell variable. Run the detector first, read its output, then paste that resolved path into the Write tool (e.g. on this Windows host it resolves to `/g/My Drive/Vaults/Daniel 2nd Brain/...`).
- Never write `"~/..."` — the tilde does not expand inside double quotes and would create a literal `~` directory on the Drive mount.

Vault layout:

| Folder | Contents | This skill's access |
|---|---|---|
| `raw/` | Immutable markdown source material, flat | **Write new files only.** Never modify or delete existing. |
| `Clippings/` | Web-clipper output, flat, read-only per vault rules | Never write. |
| `wiki/` | Claude-authored knowledge pages, flat, kebab-case | Read for **query**; write only during **ingest**, following the vault's own procedure. |
| `wiki/index.md` | Master catalog — entry point for any query | Read; updated by ingest. |
| `wiki/log.md` | Append-only history | Appended by ingest only. |

## Pick the mode

| Signal | Mode |
|---|---|
| User pasted text, handed over a `.md` path, said "raw에 추가" / "이거 저장해둬" / "upload to second brain" — wants it **staged**, not yet turned into a wiki page | **upload** |
| User said "wiki에 추가" / "위키로 만들어줘" / "ingest this" / "/ingest" / "이 자료 정리해서 위키에 넣어줘" — wants source material **synthesized into wiki pages** | **ingest** |
| Question phrased as "what do I know about X", "브레인에서 찾아봐", "check my wiki", or anything that wants their accumulated knowledge | **query** |
| Ambiguous between upload and ingest | Ask: just stage it in `raw/`, or also synthesize it into the wiki now? |

---

## Mode 1: Upload (source → `raw/`)

Scope: place one new file under `raw/`. This stages material only — it does **not** create wiki pages. Use **ingest** mode for that.

### Step 1. Determine source
- **Inline**: user pasted or dictated content → compose, then write.
- **Path**: user gave a `.md` path → `cp` into `raw/`.

If they only described a topic, ask — do not fabricate material for the vault.

### Step 2. Filename
- `.md` extension required.
- Preserve the human title. Spaces, original casing, and Korean are all fine in `raw/` (see existing files like `Claude Opus 4.7.md`, `Stratosphere Games -- Desync 원인과 해법.md`). Do **not** force kebab-case — that's a `wiki/` convention.
- If no title given, derive from the first `#` heading or ask.
- Check collision with `ls "$VAULT/raw/"` before writing. If the filename exists, stop and ask: overwrite, rename, or cancel. `raw/` is immutable — default to not overwriting.

### Step 3. Write or copy
**Inline** — use the Write tool with the resolved absolute path:
```
<resolved VAULT>/raw/<name>.md
```
Ensure the file opens with a `# Title` heading if the content lacks one.

**Path** — `cp` via Bash, using `$VAULT`:
```bash
cp "<source-path>" "$VAULT/raw/<name>.md"
```
Default is copy, not move. Only move if the user explicitly asked.

### Step 4. Verify and report
- `ls -la "$VAULT/raw/<name>.md"`.
- Report final filename and size, and ask whether to **ingest** it into the wiki now (offer to switch to ingest mode) or leave it staged.

### Upload guardrails
- Never write to `Clippings/` via this skill.
- Never delete or rename existing `raw/` files.
- Non-markdown input (PDF, HTML, image): ask whether to convert first or drop in as-is. Vault ingest is written for markdown.
- URLs: ask — WebFetch-based extract, user-written summary, or a stub pointing at the URL? Don't silently fetch and dump raw HTML.

---

## Mode 2: Ingest (raw → `wiki/`)

Scope: synthesize source material into wiki pages and update the catalog. This writes to `wiki/`. The authoritative procedure lives **inside the vault**, not here — this skill makes that procedure runnable from any working directory.

### Step 1. Resolve the vault (see top) and load the canonical procedure
Read these two files and follow them exactly — they define every rule (page format, mandatory callout, project scoping into Stratosphere / Stellar / General, index and log updates):
```
<resolved VAULT>/CLAUDE.md
<resolved VAULT>/.claude/skills/ingest/SKILL.md
```
Do not reimplement or summarize the procedure from memory — read the current files each run, since the vault owns the definition and it may have changed.

### Step 2. Orient
Read `"$VAULT/wiki/index.md"` to see existing categories and pages before creating or updating anything.

### Step 3. Identify source
- A named file in `raw/` or `Clippings/` → read it fully.
- Pasted content → treat that as the source (offer to also stage it via upload mode).
- "ingest the new stuff" → `ls "$VAULT/raw/"` and `ls "$VAULT/Clippings/"`, then ask which file(s).

### Step 4. Synthesize and write
Follow the vault procedure: classify project scope, write/update `wiki/*.md` pages (kebab-case, mandatory callout, wiki-links), update `wiki/index.md`, append to `wiki/log.md`. Use the resolved absolute path in the Write tool.

### Step 5. Report
List the pages created/updated as `[[wiki-links]]`, the detected project bucket(s), and any classification you were unsure about so the user can correct it in one line.

### Ingest guardrails
- Never modify or delete files in `raw/` or `Clippings/` — they are immutable source.
- `wiki/index.md` and `wiki/log.md` are touched only as the vault procedure prescribes (index entries, append-only log).
- If `$VAULT/CLAUDE.md` or the vault ingest skill is missing, stop and report — do not improvise wiki structure.

---

## Mode 3: Query (ask the wiki)

Scope: answer a question using only what's in `wiki/`. Read-only.

### Step 1. Read the index
Resolve the vault, then always start by reading:
```
<resolved VAULT>/wiki/index.md
```
It's the master catalog; it tells you which pages exist and how they're categorized. Skipping it leads to missed pages.

### Step 2. Select pages
Pick the 1–5 most relevant `wiki/*.md` pages from the index. If the index is ambiguous, grep:
```bash
grep -l -i "<keyword>" "$VAULT/wiki/"*.md
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
- (b) ingest existing source material now (switches to ingest mode).

### Query guardrails
- Read-only across `wiki/` — never edit `wiki/*.md`, `wiki/index.md`, or `wiki/log.md` in this mode.
- Prefer quoting specific lines over paraphrasing.
- Wiki pages are English by default (per vault style guide); `raw/` may be Korean. Match the user's question language for the answer.

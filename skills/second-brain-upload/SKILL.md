---
name: second-brain-upload
description: Upload markdown files into the user's Obsidian/Google Drive second brain `raw/` folder so the vault's ingest flow can turn them into wiki pages. Use when the user says things like "raw에 추가", "세컨드 브레인에 업로드", "second brain에 올려줘", "upload to raw", "ingest에 넣어줘", or hands over a markdown file/URL/inline note meant for the vault. Supports two modes: (1) inline content the user writes or dictates, (2) an existing local markdown file to copy in.
---

# Second Brain Upload

Adds a markdown file to the user's second brain `raw/` folder. Ingestion into the wiki is a separate operation that happens inside the vault project itself — this skill only stages the source material.

## Target location

Absolute path (always quote it — the path contains spaces and special chars):

```
/Users/hackjoy/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain/raw
```

The `raw/` folder is **flat** (no subdirectories) and **immutable** once populated. Never modify or overwrite an existing file under it without explicit user confirmation.

## Workflow

### Step 1. Determine the source

Ask or infer which mode applies:

| Mode | Signal | Action |
|------|--------|--------|
| Inline | User pasted text, dictated notes, or asked you to draft content | Compose final markdown, then write it |
| Path  | User gave an absolute/relative path to a `.md` file | Read to confirm it is markdown, then copy |

If the user only described a topic without providing content or a path, ask which mode they want before proceeding — do not fabricate source material for the vault.

### Step 2. Decide the filename

- Use `.md` extension.
- Preserve the human-readable title the user provides (raw/ filenames are allowed to keep spaces, casing, and Korean — see existing files like `Claude Opus 4.7.md`). Do **not** force kebab-case here; kebab-case is a wiki/ convention, not a raw/ convention.
- If the user did not give a title, derive one from the first `#` heading or a short summary, and confirm with the user before writing.
- Check for a collision with `ls` before writing. If the target filename already exists in `raw/`, stop and ask the user: overwrite, pick a new name, or cancel.

### Step 3. Write or copy

**Inline mode:** use the Write tool with the full target path. Ensure the file opens with a top-level `# Title` heading if the content lacks one.

**Path mode:** use `cp` via Bash. Quote the destination path. Example:

```bash
cp "<source-path>" "/Users/hackjoy/Library/CloudStorage/GoogleDrive-gigamage@gmail.com/My Drive/Vaults/Daniel 2nd Brain/raw/<filename>.md"
```

Do not move the original unless the user explicitly asked — default is copy.

### Step 4. Verify and report

Run one `ls -la` on the target file to confirm the write succeeded, then report to the user:

- Final filename written under `raw/`
- Size (bytes or a short line count)
- Reminder that ingestion itself happens in the vault project (`/ingest` or "add this material" inside the Daniel 2nd Brain workspace) — this skill does not trigger it.

## Guardrails

- Never write to `Clippings/` or `wiki/` through this skill. Those have separate ownership (Clippings is web-clipper output; wiki is Claude-authored inside the vault project).
- Never delete or rename existing files in `raw/`.
- If the user hands over a non-markdown file (PDF, HTML, image), stop and ask: should it be converted to markdown first, or dropped into `raw/` as-is? The vault's ingest rules are written for markdown; other formats may not ingest cleanly.
- URLs: if the user pastes a URL and asks to "save it", ask whether they want a manual summary (they provide the gist), a WebFetch-based extract, or just the URL saved as a stub — don't silently fetch and dump raw HTML.

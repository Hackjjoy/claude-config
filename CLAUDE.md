# Claude Code Rules — Global Configuration

## Response Rules
* Always respond in **American English** (spelling: color, organize, behavior; not colour/organise/behaviour)
* **No flattery** — be direct and objective
* **No lying** — admit uncertainty when unsure
* **Act, don't echo** — start work on the given task immediately. Do not restate or rewrite the user's prompt before proceeding.
* **Batch clarifications** — if clarification is genuinely needed, ask all questions in one turn rather than serially.
* **Default to short and clear** — keep responses selective and unambiguous. Include only what changes the reader's next action, written in complete sentences; no preamble, no recap, no trailing summary. Expand only when the task genuinely warrants more detail (complex reasoning, multi-step plans, or explicit user request). Match length to the work, not to a default verbosity.
* **Minimize abbreviations in written documents** — prefer full names over abbreviations or acronyms. If an abbreviation must be used, spell out the full name at least once on first use, with the abbreviation in parentheses, e.g., "Conversion Rate (CVR)". After that first mention, the short form is fine. Applies to documents, specs, design docs, commit messages, and any prose written for humans; does not apply to widely-known industry terms (API, URL, HTTP, JSON) or code identifiers.

## Workflow Rules

### Plan → Implement → Verify
Whenever a task is non-trivial enough to warrant a plan (Plan Mode, spec-first-workflow, or a multi-step task list), the plan **must** end with a `verify` step. Do not mark the task complete without running it.

The `verify` step **must** be delegated to the `verifier` subagent — never self-verify. The main agent's brief to `verifier` must include:
1. **Goal** — what the user originally asked for (one or two sentences).
2. **Plan** — the steps that were executed.
3. **What changed** — files touched and the diff range (e.g., `git diff main...HEAD` or commit SHAs).
4. **Concerns** — anything the main agent is unsure about (optional but encouraged).

If `verifier` returns FAIL, address the blocking items before reporting the task as done. If it returns PASS with non-blocking notes, surface those to the user in your end-of-turn summary.

Skip the verify step only when: (a) the change is a single trivial edit (typo, comment, one-line config) **and** no plan was made, or (b) the user explicitly says "skip verify". Err toward verifying.

## Environment

* Do not use UTF-8 emoji in terminal output

## Language-Specific Conventions

These apply **only to TypeScript / JavaScript projects**. For other stacks (Python, Go, Rust, etc.), follow the language's idiomatic conventions and defer to the project-level `CLAUDE.md`.

* **Formatting & naming** — defer to the project's `eslint` + `prettier` + `@typescript-eslint` config; don't hand-impose style the tooling already enforces.
* **Interfaces** — PascalCase, no `I` prefix (`UserData`, not `IUserData`).
* **Documentation** — JSDoc on public functions: params, returns, throws.

## Git Conventions

### Commit Format
`type(scope): description`

**Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `security`

**Examples**:
* `feat(api): add user authentication`
* `fix(db): resolve connection timeout`
* `security(api): implement rate limiting`

### PR Guidelines
* Include test results
* Note breaking changes
* Link to related issues
* If AI-generated, note: "AI-assisted, reviewed & adjusted"

## Cloud Infrastructure
Cloud provider differs per project — see project-level `CLAUDE.md`:
* Stellar (`~/Works/Stellar`) — GCP
* Stratosphere — Azure

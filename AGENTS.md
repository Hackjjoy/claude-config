# Codex Rules — Global Configuration

## Response Rules
* Always respond in **American English** (spelling: color, organize, behavior; not colour/organise/behaviour)
* **No flattery** — be direct and objective
* **No lying** — admit uncertainty when unsure
* **Act, don't echo** — start work on the given task immediately. Do not restate or rewrite the user's prompt before proceeding.
* **Batch clarifications** — if clarification is genuinely needed, ask all questions in one turn rather than serially.
* **Calibrate response length to task complexity** — short answer for short questions; expand only when the task warrants it. Match length to the work, not to a default verbosity.
* **Minimize abbreviations in written documents** — prefer full names over abbreviations or acronyms. If an abbreviation must be used, spell out the full name at least once on first use, with the abbreviation in parentheses, e.g., "Conversion Rate (CVR)". After that first mention, the short form is fine. Applies to documents, specs, design docs, commit messages, and any prose written for humans; does not apply to widely-known industry terms (API, URL, HTTP, JSON) or code identifiers.

## Workflow Rules

### Plan → Implement → Verify
Whenever a task is non-trivial enough to warrant a plan (Plan Mode, spec-first-workflow, or a multi-step TodoWrite), the plan **must** end with a `verify` step. Do not mark the task complete without running it.

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

The conventions below apply **only to TypeScript / JavaScript projects**. For other stacks (Python, Go, Rust, etc.), follow that language's idiomatic conventions and defer to the project-level `AGENTS.md`.

### Naming Conventions (TS/JS)
* Variables/functions: camelCase (`userId`, `fetchData`)
* Classes: PascalCase (`UserManager`)
* Interfaces: PascalCase, `I` prefix optional (`UserData` or `IUserData`)
* Type aliases: PascalCase (`UserStatus`, `AuthRole`)
* Constants: UPPER_SNAKE_CASE (`MAX_RETRY_ATTEMPTS`)
* Private: prefix underscore or use `private` keyword (`_state` or `private state`)

### Formatting (TS/JS)
* 2-space indentation
* Semicolons required
* Single quotes for strings
* Use `eslint` + `prettier` + `@typescript-eslint`

### Documentation (TS/JS)
Add JSDoc comments for public functions with params, returns, and throws.

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
Cloud provider differs per project — see project-level `AGENTS.md`:
* Stellar (`~/Works/Stellar`) — GCP
* Stratosphere — Azure

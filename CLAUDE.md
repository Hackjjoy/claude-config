# Claude Code Rules — Global Configuration

## Response Rules
* Always respond in **American English** (spelling: color, organize, behavior; not colour/organise/behaviour)
* **No flattery** — be direct and objective
* **No lying** — admit uncertainty when unsure
* **Act, don't echo** — start work on the given task immediately. Do not restate or rewrite the user's prompt before proceeding.
* **Batch clarifications** — if clarification is genuinely needed, ask all questions in one turn rather than serially.
* **Calibrate response length to task complexity** — short answer for short questions; expand only when the task warrants it. Match length to the work, not to a default verbosity.

## Environment

* Do not use UTF-8 emoji in terminal output

### Naming Conventions
* Variables/functions: camelCase (`userId`, `fetchData`)
* Classes: PascalCase (`UserManager`)
* Interfaces: PascalCase, `I` prefix optional (`UserData` or `IUserData`)
* Type aliases: PascalCase (`UserStatus`, `AuthRole`)
* Constants: UPPER_SNAKE_CASE (`MAX_RETRY_ATTEMPTS`)
* Private: prefix underscore or use `private` keyword (`_state` or `private state`)

### Formatting
* 2-space indentation
* Semicolons required
* Single quotes for strings
* Use `eslint` + `prettier` + `@typescript-eslint`

### Documentation
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
Cloud provider differs per project — see project-level `CLAUDE.md`:
* Stellar (`~/Works/Stellar`) — GCP
* Stratosphere — Azure

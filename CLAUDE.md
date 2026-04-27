# Claude Code Rules — Global Configuration

## Response Rules
* Always respond in **American English** (spelling: color, organize, behavior; not colour/organise/behaviour)
* **No flattery** — be direct and objective
* **No lying** — admit uncertainty when unsure
* **Polish user prompts** — rewrite user's prompt in clear English and display it before proceeding

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

## GCP Infrastructure

* Project: `game-server-427808`
* Cloud Run region: `us-central1`
* Artifact Registry repo: `cloud-run-source-deploy` (us-central1)
* WIF Pool for stellarlabsai repos: `github-actions-pool` (provider: `github-provider`)
* GitHub Actions SA: `github-actions-gcs-uploader@game-server-427808.iam.gserviceaccount.com`
* Cloud Run runtime SA: `83132866129-compute@developer.gserviceaccount.com`
* gcr.io is backed by Artifact Registry — same permissions apply

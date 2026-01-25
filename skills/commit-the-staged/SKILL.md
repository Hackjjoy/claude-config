---
name: commit-the-staged
description: Commits currently staged changes with an automatically generated commit message following project conventions. Triggers on "/commit-the-staged" or when asked to commit staged changes.
---

# Commit the Staged Skill

This skill automates the process of creating a commit for changes already in the staging area.

## Workflow

### Step 1: Verify Staged Changes
Run `git diff --cached --name-only` to check if there are any staged changes.
If there's no output, inform the user that there is nothing to commit.

### Step 2: Analyze Changes
If changes exist, run `git diff --cached` to see exactly what is being committed.

### Step 3: Draft Commit Message
Generate a commit message based on the staged changes following the project's convention:
`type(scope): description`

**Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `security`

- **feat**: New features
- **fix**: Bug fixes
- **refactor**: Code changes that neither fix a bug nor add a feature
- **test**: Adding missing tests or correcting existing tests
- **docs**: Documentation only changes
- **chore**: Changes to the build process or auxiliary tools and libraries
- **security**: Security-related changes

### Step 4: Execute Commit
Run the commit command:
```bash
git commit -m "<generated_message>"
```

### Step 5: Verify and Report
Run `git log -1 --stat` to show the created commit and confirm success to the user.

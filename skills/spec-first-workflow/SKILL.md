---
name: spec-first-workflow
description: Use BEFORE non-trivial feature work (new features, components, refactors spanning 3+ files). Brainstorms requirements, writes a committed spec to docs/specs/YYYY-MM-DD-<topic>.md, then hands off to Plan Mode + TodoWrite. Does NOT create plan files — specs are committed, plans are session-scoped. Trigger on "let's build X", "implement Y", "refactor Z", or when the user describes a feature idea before asking for code.
---

# Spec-First Workflow

A lightweight spec-driven approach for team codebases: commit the "what and why" as a spec, then let Claude Code's Plan Mode and TodoWrite handle execution tracking. No plan files, no artifact drift.

## Philosophy

**Commit specs, not plans.** Specs describe intent and remain useful for months. Plans describe execution sequence and go stale the moment they're merged — they duplicate what the code itself shows. Claude Code's native Plan Mode and TodoWrite already handle per-session execution; duplicating that in files adds maintenance cost without clear payoff for small-to-medium teams.

This skill is deliberately narrower than Superpowers-style workflows. It does one thing: get a good spec committed before code starts.

## When to invoke

Invoke this skill BEFORE starting any of:

- A new feature, component, module, or service
- Non-trivial additions to existing code (anything spanning 3+ files, or introducing new concepts)
- Refactoring that changes behavior, architecture, or public API
- Anything where "write code first and iterate" would be measurably worse than thinking first

Do NOT invoke this skill for:

- Bug fixes with obvious scope (one file, clear root cause)
- Typos, renames, dependency bumps, formatting
- Exploratory debugging — use a debugging approach instead
- Questions where the user just wants to discuss, not build

When in doubt, ask the user: "This feels substantial enough to spec first — want me to run through the spec-first workflow, or is this smaller than it sounds?"

## Workflow

### Step 1 — Brainstorm (Socratic)

Before any writing, explore the request through conversation:

- Batch related clarifying questions; split them only when the answer to Q1 would change Q2. Do not dump a long question list at once, but do not drag a simple feature across many turns either. Questions should be the ones whose answers actually change the design.
- Check existing code context so the spec aligns with current patterns. Read related files.
- Propose 2-3 alternative approaches when the design has real trade-offs. Not every decision has alternatives worth naming — only surface them when they do.
- Assess scope. If the request spans multiple independent subsystems (e.g., "build a platform with auth, billing, and analytics"), flag it immediately and propose decomposition into separate specs before going deeper.

Do NOT skip to writing the spec file to save time. The brainstorm is where the value is.

### Step 2 — Present design for approval

Show the design in digestible sections — not a wall of text. Get explicit user approval on the design before writing the spec file. If the user has concerns, iterate in conversation first.

### Step 3 — Write the spec

Save to: `docs/specs/YYYY-MM-DD-<topic>.md`

- `YYYY-MM-DD` is today's date in ISO format
- `<topic>` is a kebab-case slug describing the feature (e.g., `oauth-refresh-token-rotation`, `add-webhook-retry-queue`)

If `docs/specs/` does not exist in the repo, create it. If the project has a different committed convention (e.g., `specs/`, `rfcs/`, `design-docs/`), follow that instead — check before creating a new directory.

**Collision handling.** If a file already exists at that path (same day, same topic), append `-v2`, `-v3`, etc., or a descriptive disambiguator. Never overwrite.

Use this structure:

```markdown
# <Feature name>

## Context
Why this is needed. What problem it solves. Link to tickets or issues if relevant.
Keep to 3-5 sentences.

## Goals
What success looks like. Bullet points. Specific and verifiable.

## Non-goals
What this explicitly does NOT do. Prevents scope creep and future confusion
when someone reads this six months later.

## Design
How it works. Cover:
- Architecture decisions (what components, how they interact)
- Data shapes / schemas
- API contracts or user-facing interfaces
- User flows or state transitions
Use mermaid diagrams or ASCII sketches where they clarify more than prose.

## Alternatives considered
2-3 approaches that were rejected, and why. This is the audit trail —
future readers need to know what was tried and dismissed, not just what won.

## Implementation notes
The ONLY bridge to execution. Keep to bullet points, not a plan.
Capture things like:
- Ordering constraints ("DB migration must ship before app deploy")
- Known pitfalls ("cached client in services/auth.ts — invalidate on token rotation")
- Dependencies on other work ("blocked on infra ticket X")
- Testing approach at a high level (not test-by-test)

This is NOT a task breakdown. If it's becoming one, stop — that's Plan Mode's job.

## Open questions
Things unresolved at spec-write time. Either track them as TODOs to close
during implementation, or mark as "defer to v2".
```

### Step 4 — Spec self-review

Before asking the user to review, scan the draft for:

- Placeholder text (TODO, FIXME, "decide later") still sitting in the spec
- Contradictions between sections (Goals says X, Design assumes not-X)
- Ambiguous requirements ("make it fast" without numbers; "user-friendly" without criteria)
- Scope that drifted beyond the original request

Fix inline where possible. If an issue cannot be resolved without user input, move it into the **Open questions** section rather than leaving unresolved text in the body. Then present the file path to the user: "Spec written at `docs/specs/<path>`. Please review before I commit."

### Step 5 — Commit the spec

After user approval, commit the spec as its own commit with message `spec: <topic>`. Isolating the spec commit means PR reviewers can discuss the spec separately from implementation commits if they want, and the spec is bisectable.

### Step 6 — Hand off to execution

After the spec is committed:

- **Do NOT create a plan file.** No `docs/plans/`, no `PLAN.md`, no `TASKS.md` in the repo.
- Ask the user to `Shift+Tab` into Plan Mode when they're ready to implement. Claude Code's Plan Mode is a user-controlled UI mode — Claude cannot enter it on the user's behalf; it can only suggest the toggle.
- Use TodoWrite to track tasks during execution. Reference the spec when useful: TodoWrite items can say things like "Implement §Design.AuthFlow step 2 (see spec)".

The spec is the durable artifact. The plan is ephemeral — it lives in the session and dies with it, by design.

## Exceptions

### Multi-session work (scratch plans allowed)

For work that will clearly span multiple sessions (days, not hours), a local scratch plan is acceptable IF:

- It lives at `.claude/plans/<topic>.md`
- `.claude/plans/` is in `.gitignore` (check and add if missing)
- It is treated as disposable — no review, no archiving, deleted when the feature merges

This exists ONLY for session recovery — so the user can come back tomorrow and not lose context. It is not a team artifact. Never commit it. Never propose it unless the user has indicated the work is multi-session; assume work fits in one session by default.

### User explicitly wants a committed plan

If the user overrides and asks for a committed plan file, honor it. But note the trade-off once, so the decision is informed: "Committed plan files tend to go stale after merge — do you want to archive at merge time, or keep them in `docs/plans/` as historical record?" Then proceed as they prefer.

## What this skill does NOT do

- Does not enforce TDD — that's a separate concern
- Does not create git worktrees — the user's git workflow is up to them
- Does not replace Plan Mode — it feeds INTO Plan Mode
- Does not generate code — it stops at "spec committed, ready to implement"

The only output of this skill is a committed spec file at `docs/specs/YYYY-MM-DD-<topic>.md`, followed by a clear handoff signal.

## Reference example

A minimal spec following this skill's structure looks like:

```markdown
# OAuth refresh token rotation

## Context
Current refresh tokens are long-lived and reused. Security review in Q1 flagged
this as replay-risk. Ticket SEC-214.

## Goals
- Rotate refresh token on every use
- Invalidate prior refresh token within 5s of rotation
- Existing access-token flow unchanged (no client churn)

## Non-goals
- Does not touch access-token TTL
- Does not add device-binding (SEC-221, separate spec)

## Design
- `POST /oauth/refresh` issues new refresh + access token
- Old refresh token marked `rotated_at` in `oauth_tokens` table
- Tokens with `rotated_at` older than 5s reject with 401
- Reuse detection: if a `rotated_at` token is presented, revoke entire token family

## Alternatives considered
- Sliding-window rotation (rejected: adds clock-skew fragility)
- Client-side rotation cursor (rejected: trusts the client)

## Implementation notes
- DB migration: add `rotated_at`, `token_family_id` columns
- Ship migration ≥1 deploy before code uses columns
- Cached token lookup in `services/oauth.ts` — invalidate on rotation

## Open questions
- Grace window for legacy mobile clients still on 30d tokens? (defer to v2)
```

## Completion checklist

Before declaring the spec phase done, verify all of:

- [ ] Brainstorm happened; user approved the design in conversation
- [ ] File exists at `docs/specs/YYYY-MM-DD-<topic>.md` (or project equivalent) — verify with a read
- [ ] All required sections present (Context, Goals, Non-goals, Design, Alternatives considered, Implementation notes, Open questions)
- [ ] No placeholder text (TODO/FIXME/"decide later"), no contradictions, no unresolved ambiguity in the body (unresolved items belong in Open questions)
- [ ] User reviewed and approved the written spec
- [ ] `git log` shows a commit with message matching `spec: <topic>`
- [ ] User told "ready to implement — Shift+Tab into Plan Mode when you want to start" (or implementation has been explicitly deferred)

If any box is unchecked, the workflow is not complete.

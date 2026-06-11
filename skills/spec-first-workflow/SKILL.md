---
name: spec-first-workflow
description: EXPLICIT-INVOCATION ONLY — do NOT auto-trigger. A spec-driven workflow for non-trivial feature work: brainstorms requirements, writes a committed spec to docs/specs/YYYY-MM-DD-<topic>.md, hands off to Plan Mode + a task list, and later graduates the spec into a runbook. Invoke ONLY when the user explicitly asks for it by name — "/spec-first-workflow", "spec first", "스펙 먼저", "write a spec", "spec-first로 진행", or an equally direct request to run this workflow. Do NOT trigger merely because the user says "let's build X", "implement Y", or "refactor Z" — those alone are not enough. Also invoke when the user explicitly asks to graduate or clean up a spec that still lives in docs/specs/.
---

# Spec-First Workflow

A lightweight spec-driven approach for team codebases: commit the "what and why" as a spec, then let Claude Code's Plan Mode and task list handle execution tracking. No plan files in the repo, no artifact drift.

## Philosophy

**Commit specs, not plans.** Specs describe intent and remain useful for months. Plans describe execution sequence and go stale the moment they're merged — they duplicate what the code itself shows. Claude Code's native Plan Mode and task list already handle per-session execution; duplicating that in committed files adds maintenance cost without clear payoff for small-to-medium teams.

**Graduate specs when features ship.** Specs are durable during design but their "what and why" framing decays as living documentation once the feature is running. When the feature is verified end-to-end, merge the spec's operational content into a runbook at `docs/<topic>.md`. The runbook keeps only what the code does NOT already show — operational procedures, gotchas, and the load-bearing design decisions that constrain future changes. Everything the code now embodies (architecture, data shapes, the full set of rejected alternatives) is dropped from the doc; the original spec lives on in git history (`git show <sha>:docs/specs/<file>`), cited once in the runbook. The spec file is deleted outright; `docs/specs/` should only hold active specs. The failure mode to avoid: two docs describing the same system — or a doc re-describing what the code already says — drifting apart silently. See Step 7.

This skill is deliberately narrower than Superpowers-style workflows. It does two things: get a good spec committed before code starts, and retire that spec into a runbook once the feature ships.

## When to invoke

**This skill is opt-in only. It never auto-triggers.** Run it ONLY when the user explicitly asks for it — by name (`/spec-first-workflow`), or with a direct request like "spec first", "스펙 먼저 써줘", "write a spec for this", "let's do this spec-first". A plain "let's build X" / "implement Y" / "refactor Z" is NOT an invocation; just build it normally.

Once explicitly invoked, the skill fits best when the work is non-trivial:

- A new feature, component, module, or service
- Non-trivial additions to existing code (anything spanning 3+ files, or introducing new concepts)
- Refactoring that changes behavior, architecture, or public API
- Anything where "write code first and iterate" would be measurably worse than thinking first

If the user explicitly invokes it for something trivial (a typo, a rename, a one-file bug fix), say so and offer to skip the ceremony: "This is small enough that a spec is overhead — want me to just make the change?"

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
- Offer to enter Plan Mode when the user is ready to implement. Claude can request the switch itself via the EnterPlanMode tool (the user approves it), or the user can toggle manually with `Shift+Tab`.
- Use the task list (TaskCreate/TaskUpdate) to track tasks during execution. Reference the spec when useful: task items can say things like "Implement §Design.AuthFlow step 2 (see spec)".

The spec is the durable team artifact during implementation. The plan never enters the repo — Plan Mode saves its plan files under `~/.claude/plans/`, outside version control, by design. Once the feature ships, graduate the spec (Step 7).

### Step 7 — Graduate the spec (when the feature ships)

Specs are durable during design but decay as living documentation after ship. When the feature is verified end-to-end, **graduate** the spec: merge its operational content into a runbook, update any references pointing at the spec path, and **delete the spec file** (`git rm`). This is ideally part of the PR that closes out the feature, not a separate follow-up task that can get lost.

**Trigger.** Spec graduates when the feature has been exercised end-to-end successfully at least once in its real environment — first green CI run, first production request, first user walkthrough, etc. The exact signal depends on the feature; pick it when writing the spec if possible, so graduation has a defined finish line.

If any open questions remain unresolved, the feature isn't done. Close them (or explicitly mark "defer to v2") before graduating.

**The guiding rule:** a runbook holds only what the code does NOT already show. The shipped code is now the source of truth for *how it works* — architecture, data shapes, control flow. Re-describing that in the runbook re-creates exactly the duplication this skill rejects plan files for (see Philosophy). So graduation is mostly subtraction.

**What moves where:**

- **Operational facts** (files, resources, secrets, commands, configuration, endpoints) → runbook body at `docs/<topic>.md`. Living source of truth going forward.
- **Load-bearing design decisions** → a short "Design decisions" note in the runbook (or appendix). Keep ONLY the decisions that constrain future changes — the ones where someone editing the code later would otherwise undo a deliberate choice ("rotate on every use, not sliding-window — clock-skew fragility"). One or two lines each, not the full Alternatives section. Cite the original spec's commit SHA once so the complete historical record is recoverable via `git show <sha>:docs/specs/<file>.md`.
- **Architecture / data shapes / the full Alternatives list** → drop from the doc. The code embodies the design; git holds the full rationale. Do not copy these into the runbook.
- **Context** (the world before the feature existed) → drop. The runbook describes the world as it is, not as it was.
- **Implementation notes** → split by purpose. Ongoing operational caveats (gotchas, cache-invalidation traps) move to the runbook body; one-time ordering constraints that are now irrelevant get dropped.
- **Open questions** → all must be resolved (or deferred to a named follow-up) before graduation.

When in doubt about a piece of design prose, ask: "can a reader recover this by reading the code?" If yes, drop it. If no and it constrains future edits, keep it as a one-liner. Otherwise it lives in git history.

**Delete, don't stub.** Once the load-bearing decisions are captured (with the commit SHA cited for recovery), `git rm` the spec file. Do not leave a one-line stub behind. Git history preserves the original; `docs/specs/` should only contain active specs, not tombstones, so the directory listing stays an honest signal of "what's in flight".

**Update references BEFORE deleting.** Any file in the repo that points at the old spec path will break once the spec is deleted. Grep the repo first and redirect every hit to the runbook:

```bash
grep -rn "docs/specs/<spec-filename>" .
```

Typical hits: error messages in scripts, code comments, CI templates, other specs. Every one of these needs to point at `docs/<topic>.md` before the `git rm` lands in the same commit.

**When NOT to graduate:**

- **Pure refactors or internal changes with no user/operator surface** — no runbook to graduate into. Leave the spec frozen in `docs/specs/`.
- **Spec superseded by a newer spec** — if the superseded spec was never implemented, `git rm` it; if partially implemented, add `## Status: Superseded by <path>` at the top and leave it frozen. The newer spec is the live design record either way.
- **Feature shipped but not yet verified** in its real environment — wait. Graduating too early freezes a design that might still need revision.

**Graduation commit.** Bundle the runbook changes, the reference updates, and the spec deletion into one commit: `docs: graduate <topic> spec to runbook`. Keeping it a single commit means the graduation is atomic and trivial to revert if something downstream breaks.

## Exceptions

### Multi-session work

No special handling needed. Plan Mode persists its plan files under `~/.claude/plans/` (outside the repo), so a multi-day feature resumes from the saved plan without any scratch file in the project. Do not create repo-local plan files for session recovery, and do not add `.claude/plans/` gitignore plumbing — the native plan file already covers it. The rule is unchanged: plans live outside version control, specs live in it.

### User explicitly wants a committed plan

If the user overrides and asks for a committed plan file, honor it. But note the trade-off once, so the decision is informed: "Committed plan files tend to go stale after merge — do you want to archive at merge time, or keep them in `docs/plans/` as historical record?" Then proceed as they prefer.

## What this skill does NOT do

- Does not enforce TDD — that's a separate concern
- Does not create git worktrees — the user's git workflow is up to them
- Does not replace Plan Mode — it feeds INTO Plan Mode
- Does not generate code — it stops at "spec committed, ready to implement"
- Does not force graduation for every spec — pure refactors or superseded specs stay frozen in `docs/specs/`

The outputs of this skill are (1) a committed spec file at `docs/specs/YYYY-MM-DD-<topic>.md` before implementation starts, and (2) graduation of that spec into a runbook at `docs/<topic>.md` once the feature ships and is verified.

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

## Completion checklist — spec phase

Before declaring the spec phase done, verify all of:

- [ ] Brainstorm happened; user approved the design in conversation
- [ ] File exists at `docs/specs/YYYY-MM-DD-<topic>.md` (or project equivalent) — verify with a read
- [ ] All required sections present (Context, Goals, Non-goals, Design, Alternatives considered, Implementation notes, Open questions)
- [ ] No placeholder text (TODO/FIXME/"decide later"), no contradictions, no unresolved ambiguity in the body (unresolved items belong in Open questions)
- [ ] User reviewed and approved the written spec
- [ ] `git log` shows a commit with message matching `spec: <topic>`
- [ ] User told "ready to implement — I can enter Plan Mode when you want to start" (or implementation has been explicitly deferred)

If any box is unchecked, the workflow is not complete.

## Completion checklist — graduation phase

Once the feature ships, before declaring the spec graduated:

- [ ] Feature verified end-to-end in its real environment (cite the verification — e.g., CI run URL, first production event, user confirmation)
- [ ] All open questions resolved or moved to a named follow-up spec
- [ ] Runbook at `docs/<topic>.md` contains all operational content (secrets, setup, commands, troubleshooting)
- [ ] Load-bearing design decisions (the ones that constrain future edits) kept as short one-liners; full Alternatives list, architecture, and data shapes NOT copied into the runbook (the code shows them)
- [ ] Runbook cites the original spec's commit SHA so the full historical spec is recoverable via `git show <sha>:docs/specs/<filename>`
- [ ] References to the spec path updated across the codebase — verified with `grep -rn "docs/specs/<filename>"` returning no hits outside the spec itself
- [ ] Spec file deleted with `git rm` (no stub left behind)
- [ ] Graduation commit created with message `docs: graduate <topic> spec to runbook`

Skip this section entirely if the spec is not graduation-eligible (pure refactor with no operator surface, or superseded by a newer spec — in which case mark the spec's status and leave it).

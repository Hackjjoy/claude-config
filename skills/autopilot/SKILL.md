---
name: autopilot
description: Use when the user gives a multi-step development task and wants it executed autonomously end-to-end (e.g. "build the player admin page", "migrate auth to JWT", "add audit logging to all admin endpoints"). Triggers on "autopilot", "오토파일럿", "알아서 해줘", "끝까지 가줘", "다 해줘", or "/autopilot". Inspired by oh-my-claudecode's autopilot pattern.
---

# Autopilot

Execute a multi-step development task end-to-end with minimal user interruption. Plan once, dispatch atomic tasks to `general-purpose` subagents in parallel where safe, verify each step, commit per task, and finish with a `verifier`-subagent gate.

This skill is opinionated. Do NOT skip phases. Do NOT improvise the workflow.

## When to invoke

Invoke when ALL of:

- The task spans multiple files or steps (anything a single Edit cannot finish)
- The user's intent is "run it to completion", not "discuss the design first"
- No production data, secrets, or external-write side effects are required up front

Do NOT invoke for:

- Single-file bug fixes (just do it)
- Design exploration ("what do you think about...") — use `spec-first-workflow` instead
- Anything touching prod DBs, payment flows, or sending external messages without explicit per-step approval

If the user asked to *plan* a feature, route to `spec-first-workflow`. Autopilot picks up *after* the design is settled, or when the design is obvious enough to skip.

## Working artifact

Track progress at `.claude/plans/autopilot-<topic>.md` (kebab-case slug). This directory is gitignored per project convention; if it isn't yet, add `.claude/plans/` to `.gitignore` before writing. The artifact is disposable — delete it in Phase 5 unless the user asks to keep it.

`TodoWrite` mirrors the same task list for the live UI. The plan file is the durable backup so the run can recover across sessions.

## Phase 1 — Clarify (batched, max 3 questions)

Ask only what genuinely blocks planning:

- Target framework / file location ambiguous?
- Behavior on edge cases the prompt didn't cover?
- Scope boundary unclear (does X count as in-scope)?

Batch all questions into one turn. If the task is clear, skip Phase 1 entirely. Do not ask preference questions ("would you like tests?") — make a reasonable default and proceed.

## Phase 2 — Plan

Read the relevant code first (use `Explore` subagent for breadth-first lookups, direct `Read`/`Grep` for known paths). Then write the plan file:

```markdown
# Autopilot — <topic>

## Goal
<one or two sentences restating the user's ask in concrete terms>

## Tasks
- [ ] T1 [parallel-safe] <atomic 5–15 min task>
  - Files: <paths>
  - Verify: <command, e.g. `pnpm test path/to/file.test.ts`>
- [ ] T2 [sequential, depends on T1] ...
- [ ] T3 [parallel-safe] ...

## Final verification
- typecheck command:
- lint command:
- test command:
```

Rules for the task list:

- **Atomic** — each task is 5–15 minutes of one subagent's work
- **Tagged** — `[parallel-safe]` or `[sequential, depends on Tn]`
- **Verifiable** — each task has a concrete command that returns pass/fail (a test, a typecheck on the touched file, a build, a curl check)
- **Honest about ordering** — if two tasks touch the same file, they are sequential, full stop

Mirror the list into `TodoWrite`. Show the plan to the user. Wait for "go" / "ok" / "ㄱㄱ" before Phase 3. (In auto mode, wait still applies — the plan is the natural confirmation point. If the user said "autopilot, no questions" up front, treat that as pre-approval and proceed.)

## Phase 3 — Dispatch loop

For each unchecked task:

1. **Batch parallel-safe tasks** — up to 3 in a single message via parallel `Agent` calls with `subagent_type: "general-purpose"`. Sequential tasks run one at a time.
2. **Subagent prompt template** (every dispatch must include all of these — the subagent has no memory of this conversation):

   ```
   Task: <one atomic task, copied from plan>

   Context:
   - Working directory: <abs path>
   - Files to touch: <paths>
   - Conventions: follow <repo CLAUDE.md sections> + global rules
     (American English, camelCase vars, 2-space indent, single quotes, semicolons)
   - Related code already exists at: <paths discovered in Phase 2>

   Constraints:
   - Do NOT touch files outside the listed paths
   - Do NOT add new dependencies without flagging
   - Do NOT introduce comments unless WHY is non-obvious

   Verify before returning:
   - Run: <verification command>
   - Report: command output (last 30 lines on failure, "PASS" on success)

   Return format:
   - "PASS" + one-line summary, OR
   - "FAIL" + the failing command output + your hypothesis
   ```

3. **Independently verify** — after the subagent returns, run the verification command yourself. Do not trust the subagent's self-report; subagents can claim PASS on a stale or wrong command.
4. **On pass** — check the box in the plan file, mark the `TodoWrite` item complete, and create a commit. Commit message follows project conventions (`feat(scope): T1 <description>` or similar — match the repo's style from `git log`).
5. **On fail** — re-dispatch with the failure output appended to the prompt. Max 2 retries per task. After 2 failures, STOP (see Stopping conditions).
6. **Never batch a retry with new tasks** — retries run alone so the failure context stays focused.

## Phase 4 — Final verification

After every task is checked off, delegate to the `verifier` subagent (per global CLAUDE.md rule — never self-verify).

The brief to `verifier` must include:

1. **Goal** — what the user originally asked for (one or two sentences).
2. **Plan** — the executed task list (paste the checked-off plan).
3. **What changed** — files touched and the diff range. Use the SHA range from the autopilot run: `git diff <first-autopilot-commit>^...HEAD`.
4. **Concerns** — anything you're unsure about (test gaps, untested edge cases, places you took a shortcut).
5. **Verification commands** — typecheck, lint, full test suite. The verifier runs them.

If `verifier` returns FAIL, address the blocking items before reporting done. If PASS with non-blocking notes, surface those in Phase 5.

## Phase 5 — Report

Report to the user:

- **Done** — tasks completed, total commits
- **Retries** — any task that needed a retry, and what failed the first time
- **Skipped or deferred** — anything punted to a follow-up, with reason
- **Verifier notes** — non-blocking findings worth knowing
- **Suggested next steps** — what naturally comes after this run (deploy, manual QA, follow-up PR)

Then delete `.claude/plans/autopilot-<topic>.md` unless the user asked to keep it. The git history of per-task commits is the durable record.

## Stopping conditions

Stop and ask the user before continuing if any of:

- A task exhausts its 2-retry budget
- The plan needs to grow by >30% mid-flight (new tasks discovered, not just refinements to existing ones)
- A task requires production DB access, real external API calls, secrets, or destructive operations
- Verification reveals an architectural issue (the plan was wrong, not the implementation)
- A subagent reports it cannot proceed without information you don't have

When stopping, surface: what blocked, what was completed, what's still pending, and a concrete question for the user.

## What this skill does NOT do

- Does not push commits or open PRs (user-controlled)
- Does not run destructive git operations (no force-push, no `reset --hard`)
- Does not bypass the global verify rule (`verifier` subagent is mandatory in Phase 4)
- Does not replace `spec-first-workflow` for design-heavy work — that runs first, autopilot picks up after

## Quick reference

| Phase | Action | Tool |
|------|--------|------|
| 1 | Clarify (batched) | direct chat |
| 2 | Read code, write plan | `Explore` agent / `Read` + `TodoWrite` + plan file |
| 3 | Dispatch atomic tasks | `Agent(subagent_type="general-purpose")`, parallel where safe |
| 3 | Verify each task | `Bash` (run the task's verify command) |
| 3 | Commit per task | `Bash` git commit |
| 4 | Final gate | `Agent(subagent_type="verifier")` |
| 5 | Report and clean up | direct chat + delete plan file |

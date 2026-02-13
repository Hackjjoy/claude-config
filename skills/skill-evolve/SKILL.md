---
name: skill-evolve
description: Analyze conversation sessions to improve existing skills or create new ones. Learns from usage patterns, errors, and workflows to evolve the skill ecosystem. Always confirms changes with user before applying. Triggers on "evolve skills", "improve skills", "skill-evolve", "learn from session", "update skills from conversation".
---

# Skill Evolve

Meta-skill that evolves the skill ecosystem by learning from the **current conversation session only**.

## Core Principle

**Never modify any skill without explicit user confirmation.** Always present proposed changes clearly, explain reasoning, and wait for approval.

## Scope

This skill analyzes only the current conversation session context. It does NOT search historical conversation data. All insights come from what happened in this session.

## Workflow

### Phase 1: Gather Intelligence

1. **Analyze the current session** for:
   - Workarounds or manual steps that could be automated
   - Repeated prompt patterns that suggest a missing skill
   - Corrections or refinements to skill outputs
   - New tools or APIs discovered during the session
   - Errors encountered and how they were resolved
   - Patterns that should become conventions

2. **Read all existing skills** from `~/.claude/skills/*/SKILL.md`
   - Catalog each skill's purpose, triggers, and workflow
   - Compare against what this session revealed

3. **Read system CLAUDE.md** from `~/.claude/CLAUDE.md`
   - Review global rules, conventions, and environment settings
   - Check if session learnings reveal missing rules, outdated conventions, or new patterns worth codifying

### Phase 2: Identify Opportunities

Classify findings into:

| Category | Action | Example |
|----------|--------|---------|
| **Skill Gap** | Create new skill | Repeated manual workflow with no matching skill |
| **Trigger Gap** | Update description | Skill exists but doesn't trigger on common phrases |
| **Workflow Improvement** | Update SKILL.md body | Better steps discovered through usage |
| **Script Enhancement** | Update scripts/ | Bug fix or optimization found in session |
| **Stale Content** | Update or remove | Outdated references or deprecated approaches |
| **CLAUDE.md Rule** | Update CLAUDE.md | New convention, missing rule, or outdated setting discovered in session |

### Phase 3: Propose Changes

For each identified opportunity, present to the user:

```
## Proposed Change [N]

**Type**: [New Skill | Skill Update | Trigger Update | Script Fix | CLAUDE.md Update]
**Target**: [skill-name or "new: proposed-name" or "CLAUDE.md"]
**Reason**: [What was learned and why this change helps]

### Current State
[Show current content if updating]

### Proposed State
[Show exact proposed content]

### Impact
[What improves, what might break]
```

Wait for user to approve, modify, or reject EACH proposed change individually.

### Phase 4: Apply Approved Changes

Only after explicit user confirmation for each change:

1. **For skill updates**: Edit the target SKILL.md using the Edit tool
2. **For new skills**: Use dan-skill-creator to initialize and populate
3. **For script changes**: Edit the target script file
4. **For CLAUDE.md updates**: Edit `~/.claude/CLAUDE.md` using the Edit tool
5. **Validate** each modified skill:
   ```bash
   python ~/.claude/skills/dan-skill-creator/scripts/quick_validate.py <path/to/skill>
   ```

### Phase 5: Summary Report

After all approved changes are applied, output:

```
## Skill Evolve Report

### Applied Changes
- [list of changes made with skill names]

### Rejected/Deferred
- [list of proposals user declined, for future reference]

### Recommendations
- [any longer-term improvements noticed but not yet actionable]
```

## Safety Rules

1. **NEVER auto-apply changes** — always show diff and wait for confirmation
2. **NEVER delete a skill** without explicit user request
3. **Back up before editing** — read and display current content before proposing edits
4. **One change at a time** — present each proposal separately for clear approval
5. **Preserve user customizations** — when improving a skill, keep user-specific tweaks intact

## Trigger Phrases

- "evolve skills" / "skill-evolve"
- "improve skills from this session"
- "learn from this conversation"
- "update skills based on what we learned"
- "what skills could be improved?"
- "analyze skills for improvements"

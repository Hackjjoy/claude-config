---
name: gdd
description: Create and maintain Game Design Documents (GDD) from discussion. Use when defining game concepts, mechanics, systems, or creating a formal GDD. The GDD serves as the constitutional reference for all game development decisions. Triggers on "game design", "GDD", "design document", "game concept", "game mechanics".
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
---

# Game Design Document (GDD) Skill

You are creating and maintaining a Game Design Document that will serve as the **constitution** for the game's development. Every implementation decision should reference and align with this document.

## Purpose

The GDD is the authoritative source of truth for:
- What the game IS and IS NOT
- Core mechanics and systems
- Visual and audio direction
- Player experience goals
- Technical requirements

## GDD Location

All GDDs are stored in the `gdd/` directory at the project root:

```
gdd/
  <game-slug>/
    GDD.md           # Main document (START HERE)
    MECHANICS.md     # Detailed mechanics breakdown
    AESTHETICS.md    # Art direction, audio, feel
    SYSTEMS.md       # Technical systems design
    PROGRESSION.md   # Player progression, economy
    CHANGELOG.md     # Document revision history
```

## Creating a New GDD

### Step 1: Gather Context from Discussion

Review the conversation for:
- Core game concept and genre
- Target platform (web, mobile, etc.)
- Key mechanics mentioned
- Visual style preferences
- Player experience goals

### Step 2: Consult Art Director (Optional but Recommended)

For visual and aesthetic decisions, consult the art director agent:

```
Use Task tool with:
  subagent_type: "general-purpose"
  prompt: "Acting as the web-game-art-director, provide aesthetic guidance for: [game concept]. Consider: color palette, visual style, UI/UX approach, typography, and overall mood."
```

### Step 3: Create GDD Structure

Create the directory and files:

```bash
mkdir -p gdd/<game-slug>
```

### Step 4: Write GDD.md (Main Document)

Use this template:

```markdown
# [Game Title] - Game Design Document

**Version:** 1.0
**Status:** Draft | In Review | Approved
**Last Updated:** YYYY-MM-DD

---

## 1. Vision Statement

> One paragraph that captures the essence of the game. What makes it unique?
> What feeling should players have?

## 2. Core Concept

### 2.1 Elevator Pitch
[1-2 sentences describing the game]

### 2.2 Genre
[Primary genre / Secondary elements]

### 2.3 Target Platform
[Web / Mobile / Desktop]

### 2.4 Target Audience
[Who is this game for?]

## 3. Core Pillars

The **non-negotiable** principles that guide all design decisions:

1. **[Pillar 1]**: [Explanation]
2. **[Pillar 2]**: [Explanation]
3. **[Pillar 3]**: [Explanation]

> If a feature conflicts with these pillars, the feature must change.

## 4. Core Loop

```
[Action] -> [Feedback] -> [Reward] -> [Motivation] -> [Action]
```

### 4.1 Primary Loop
[What does the player do moment-to-moment?]

### 4.2 Secondary Loop
[What keeps them coming back?]

## 5. Key Mechanics

| Mechanic | Description | Why It Matters |
|----------|-------------|----------------|
| [Name] | [How it works] | [Purpose] |

## 6. Aesthetic Direction

> See AESTHETICS.md for full details

### 6.1 Visual Style
[Brief description - detailed in AESTHETICS.md]

### 6.2 Audio Direction
[Brief description]

### 6.3 UI/UX Principles
[Brief description]

## 7. Success Metrics

How do we know the game is succeeding?

| Metric | Target | Measurement |
|--------|--------|-------------|
| [Metric] | [Goal] | [How to measure] |

## 8. Scope Definition

### 8.1 MVP Features (Must Have)
- [ ] Feature 1
- [ ] Feature 2

### 8.2 Post-MVP (Nice to Have)
- [ ] Feature A
- [ ] Feature B

### 8.3 Out of Scope (Not This Game)
- Feature X - Why not
- Feature Y - Why not

## 9. Related Documents

- [MECHANICS.md](./MECHANICS.md) - Detailed mechanics
- [AESTHETICS.md](./AESTHETICS.md) - Art and audio direction
- [SYSTEMS.md](./SYSTEMS.md) - Technical systems
- [PROGRESSION.md](./PROGRESSION.md) - Player progression

---

## Document Authority

This GDD is the **constitution** for [Game Title]. All implementation
decisions should align with this document. If implementation needs differ
from the GDD, the GDD should be updated through the change process first.

### Change Process
1. Propose change in CHANGELOG.md
2. Review against Core Pillars
3. Update GDD sections
4. Notify team of changes
```

## AESTHETICS.md Template

This document should be created with Art Director consultation:

```markdown
# [Game Title] - Aesthetic Direction

## Visual Identity

### Color Palette
| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Primary | | #XXXXXX | |
| Secondary | | #XXXXXX | |
| Accent | | #XXXXXX | |
| Background | | #XXXXXX | |
| Text | | #XXXXXX | |

### Art Style
[Detailed description of visual style]

### Reference Images
[Links or descriptions of reference material]

## Typography

### Font Choices
- **Headers:** [Font name] - [Why]
- **Body:** [Font name] - [Why]
- **UI:** [Font name] - [Why]

## UI/UX Design

### Layout Principles
[How screens are organized]

### Interaction Patterns
[How players interact with UI]

### Feedback Systems
[Visual/audio feedback for actions]

## Audio Direction

### Music Style
[Genre, mood, instrumentation]

### Sound Effects
[Style and approach for SFX]

### Audio Implementation Notes
[Technical considerations]

## Mood and Feel

### Emotional Targets
[What emotions should the game evoke?]

### Reference Games/Media
[Similar aesthetics to reference]
```

## Working with the GDD

### Reading the GDD

Before implementing any game feature:

```bash
# Check if GDD exists
ls gdd/<game-slug>/

# Read the main document
cat gdd/<game-slug>/GDD.md
```

### Referencing the GDD

When implementing features, cite the GDD:

```javascript
/**
 * Player jump mechanic
 * @see gdd/my-game/MECHANICS.md#jumping
 * Core Pillar: "Responsive Controls"
 */
```

### Updating the GDD

1. Document the change in CHANGELOG.md
2. Update relevant sections
3. Verify alignment with Core Pillars

## Commands

### /gdd create <game-name>

Create a new GDD for a game. Will prompt for:
- Game concept and genre
- Target platform
- Core mechanics
- Art direction (with Art Director consultation)

### /gdd view <game-name>

Display the GDD overview and status.

### /gdd update <game-name>

Update sections of an existing GDD. Logs changes to CHANGELOG.md.

### /gdd check <game-name>

Verify that implementation aligns with GDD. Checks:
- Are Core Pillars being honored?
- Are out-of-scope features creeping in?
- Does the aesthetic match the direction?

## Integration with Art Director

The Art Director agent (`web-game-art-director`) should be consulted for:

1. **Initial aesthetic direction** - Color palette, style, mood
2. **UI/UX design decisions** - Layout, interaction patterns
3. **Asset creation guidance** - What assets are needed, style requirements
4. **Visual consistency checks** - Does implementation match vision?

To consult the Art Director, use the Task tool:

```
subagent_type: "general-purpose"
prompt: "Acting as the web-game-art-director, [your question about aesthetics]"
```

## Best Practices

### DO
- Keep the GDD concise but complete
- Update the GDD before changing implementation
- Reference Core Pillars in design discussions
- Use the Art Director for aesthetic decisions
- Log all changes in CHANGELOG.md

### DON'T
- Implement features not in the GDD without updating it first
- Ignore Core Pillars for "cool" features
- Let the GDD become stale
- Make aesthetic decisions without Art Director input
- Add scope without removing something else

## Example Workflow

1. **User discusses game idea**
2. **Activate /gdd skill**
3. **Gather requirements from discussion**
4. **Consult Art Director for aesthetics**
5. **Create GDD structure**
6. **Write main GDD.md**
7. **Create AESTHETICS.md with Art Director guidance**
8. **Create other supporting documents as needed**
9. **GDD becomes the reference for all implementation**

## Success Indicators

The GDD is working well when:
- Implementation decisions cite the GDD
- Feature debates reference Core Pillars
- Visual implementation matches AESTHETICS.md
- Scope creep is caught and evaluated against GDD
- Changes go through the change process

---

**Remember**: The GDD is a living document, but changes should be intentional. It is the constitution that keeps the game coherent and the team aligned.

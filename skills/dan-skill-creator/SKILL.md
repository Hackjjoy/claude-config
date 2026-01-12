---
name: dan-skill-creator
description: Guide for creating Claude Code skills. Use when users want to create a new skill, update an existing skill, or understand skill structure. Triggers on requests like "create a skill", "make a new skill", "build a skill for X", or when user asks about skill development.
---

# Dan Skill Creator

Create effective Claude Code skills with proper structure, scripts, and documentation.

## Skill Structure

```
skill-name/
  SKILL.md           # Required: Frontmatter + instructions
  scripts/           # Optional: Executable Python/Bash code
  references/        # Optional: Documentation loaded as needed
  assets/            # Optional: Templates, images, fonts for output
```

## SKILL.md Requirements

### Frontmatter (Required)

```yaml
---
name: skill-name
description: What the skill does AND when to use it. Include specific triggers.
---
```

- `name`: hyphen-case, lowercase, max 64 chars
- `description`: Clear explanation + usage triggers, max 1024 chars, no angle brackets

### Body (Required)

Markdown instructions Claude reads after skill triggers. Keep concise - the context window is shared.

## Creation Process

### 1. Initialize Skill

```bash
python scripts/init_skill.py <skill-name> --path <output-directory>
```

Creates template directory with SKILL.md and example resources.

### 2. Plan Resources

Analyze use cases to determine needed resources:

| Resource Type | When to Use | Example |
|--------------|-------------|---------|
| scripts/ | Repeated deterministic code | `rotate_pdf.py` |
| references/ | Documentation loaded on demand | `api_reference.md` |
| assets/ | Output files (not loaded to context) | `template.pptx` |

### 3. Edit SKILL.md

- Write clear frontmatter description with usage triggers
- Add procedural instructions for the skill workflow
- Reference bundled resources with paths
- Keep under 500 lines; split large content to references/

### 4. Validate

```bash
python scripts/quick_validate.py <path/to/skill-folder>
```

### 5. Package

```bash
python scripts/package_skill.py <path/to/skill-folder> [output-dir]
```

Creates `.skill` file (zip archive) for distribution.

## Design Principles

### Concise is Key

Only add what Claude doesn't already know. Prefer examples over explanations.

### Progressive Disclosure

1. Metadata (name + description) - always loaded (~100 words)
2. SKILL.md body - loaded when skill triggers
3. Bundled resources - loaded as needed

### Degrees of Freedom

- **High**: Text instructions when multiple approaches work
- **Medium**: Pseudocode with parameters for preferred patterns
- **Low**: Specific scripts for fragile operations

## Reference Files

- **Workflow patterns**: See [references/workflows.md](references/workflows.md)
- **Output patterns**: See [references/output-patterns.md](references/output-patterns.md)

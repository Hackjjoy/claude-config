# Output Patterns

Use these patterns when skills need consistent, high-quality output.

## Template Pattern

Provide templates for output format. Match strictness to needs.

**Strict (API responses, data formats):**

```markdown
## Report structure

ALWAYS use this exact template:

# [Analysis Title]

## Executive summary
[One-paragraph overview]

## Key findings
- Finding 1 with data
- Finding 2 with data

## Recommendations
1. Specific action
2. Specific action
```

**Flexible (when adaptation is useful):**

```markdown
## Report structure

Sensible default format (adapt as needed):

# [Analysis Title]

## Executive summary
[Overview]

## Key findings
[Adapt sections based on discoveries]

## Recommendations
[Tailor to context]
```

## Examples Pattern

For output quality that depends on seeing examples, provide input/output pairs:

```markdown
## Commit message format

Follow these examples:

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware

**Example 2:**
Input: Fixed bug where dates displayed incorrectly
Output:
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

Examples help Claude understand style better than descriptions alone.

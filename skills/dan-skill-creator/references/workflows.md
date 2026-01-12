# Workflow Patterns

## Sequential Workflows

For multi-step tasks, provide a clear overview:

```markdown
PDF form filling involves:

1. Analyze form (run analyze_form.py)
2. Create field mapping (edit fields.json)
3. Validate mapping (run validate_fields.py)
4. Fill form (run fill_form.py)
5. Verify output (run verify_output.py)
```

## Conditional Workflows

For branching logic, guide Claude through decision points:

```markdown
1. Determine modification type:
   **Creating new content?** -> Follow "Creation workflow"
   **Editing existing content?** -> Follow "Editing workflow"

2. Creation workflow: [steps]
3. Editing workflow: [steps]
```

## Decision Trees

For complex decisions, use structured trees:

```markdown
## Workflow Decision Tree

Start here:

1. Is this a new document or existing?
   - New -> Step 2
   - Existing -> Step 3

2. Creating: Use docx-js...
3. Editing: Read document first...
```

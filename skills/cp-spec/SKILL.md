---
name: cp-spec
description: Use when the user invokes /cp-spec to write a planning spec from captured notes.
---

# Write Spec

Write a spec document from the captured planning notes.

## Finding the notes file

Look in `~/.claude-plan/specs/` for the current repo's most recently modified `notes.md`:

```bash
find ~/.claude-plan/specs/$(basename $(git rev-parse --show-toplevel)) -name "notes.md" -type f -exec ls -t {} + | head -1
```

## Writing the spec

1. Read all notes from `notes.md`
2. Write `spec.md` in the same directory, organized into logical sections. The format is open-ended but should generally include:
   - Ticket context (title, description, key acceptance criteria from the notes header)
   - Files to change with specific changes described
   - New files to create
   - Migration needs
   - Testing considerations
   - Open questions or risks
3. Present the spec to the user for review
4. Apply edits if requested

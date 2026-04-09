---
name: cp-notes
description: Use when the user invokes /cp-notes to display all captured planning notes for the current session.
---

# Show Notes

Display all captured notes from the active planning session.

## Finding the notes file

Look in `~/.scrawl/specs/` for the current repo's most recently modified `notes.md`:

```bash
find ~/.scrawl/specs/$(basename $(git rev-parse --show-toplevel)) -name "notes.md" -type f -exec ls -t {} + | head -1
```

Read the file and display its contents.

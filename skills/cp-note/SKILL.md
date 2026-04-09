---
name: cp-note
description: Use when the user invokes /cp-note to capture a planning note. Appends to the current planning session's notes.md file.
---

# Capture Note

Append a note to the active planning session's `notes.md` file.

## Finding the notes file

Look in `~/.claude-plan/specs/` for the current repo's most recently modified `notes.md`:

```bash
find ~/.claude-plan/specs/$(basename $(git rev-parse --show-toplevel)) -name "notes.md" -type f -exec ls -t {} + | head -1
```

## Format

The argument may include editor context in brackets: `/cp-note [file:line] text`

- If a file context is provided, group the note under a `### {file}` heading in notes.md (create the heading if it doesn't exist)
- If no file context, put it under `### General`
- Prefix each note with a timestamp: `- [HH:MM] {text}`
- If only context is provided with no text (`/cp-note [file:line]`), read the referenced line and capture it as context

Append the note to the file. Do not rewrite the entire file.

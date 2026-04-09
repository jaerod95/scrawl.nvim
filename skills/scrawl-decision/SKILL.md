---
name: scrawl-decision
description: Use when the user invokes /scrawl-decision to capture a planning decision. Appends a DECISION-prefixed note to the current planning session's notes.md file.
---

# Capture Decision

Append a decision to the active planning session's `notes.md` file.

## Finding the notes file

Look in `~/.scrawl/specs/` for the current repo's most recently modified `notes.md`:

```bash
find ~/.scrawl/specs/$(basename $(git rev-parse --show-toplevel)) -name "notes.md" -type f -exec ls -t {} + | head -1
```

## Format

The argument may include editor context in brackets: `/scrawl-decision [file:line] text`

- If a file context is provided, group under a `### {file}` heading in notes.md
- If no file context, put it under `### General`
- Prefix: `- [HH:MM] DECISION: {text}`

Append to the file. Do not rewrite the entire file.

---
name: decision
description: Use when the user invokes /scrawl:decision to capture a planning decision. Appends a DECISION-prefixed note to the current planning session's notes.md file.
---

# Capture Decision

Append a decision to the active planning session's `notes.md` file.

## Finding the notes file

A session may be pointed at a document the user is writing in (`/scrawl:target`). Check that pointer first and fall back to the most recently modified `notes.md` for the repo:

```bash
repo=$(basename "$(git rev-parse --show-toplevel)")
pointer="$HOME/.scrawl/targets/$repo"
if [ -f "$pointer" ]; then
  cat "$pointer"
else
  find "$HOME/.scrawl/specs/$repo" -name "notes.md" -type f -exec ls -t {} + 2>/dev/null | head -1
fi
```

The resolved path may contain spaces — always quote it. Everything below applies to whichever file this resolves to.

## Format

The argument may include editor context in brackets: `/scrawl:decision [file:line] text`

- If a file context is provided, group under a `### {file}` heading in notes.md
- If no file context, put it under `### General`
- Prefix: `- [HH:MM] DECISION: {text}`

Append to the file. Do not rewrite the entire file.

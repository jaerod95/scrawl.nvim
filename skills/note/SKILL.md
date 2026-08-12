---
name: note
description: >-
  Use when the user invokes /scrawl:note to capture a planning note.
  Appends to the current planning session notes.md file.
---

# Capture Note

Append a note to the active planning session's `notes.md` file.

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

The argument may include editor context in brackets. Two formats are possible:

### Simple note

    /scrawl:note [file:line] text

### Visual selection note (multi-line)

    /scrawl:note [file:start-end]
    optional text
    ```lang
    selected code
    ```

## Rules

- If a file context is provided, group the note under a `### {file}` heading in notes.md (create the heading if it doesn't exist)
- If no file context, put it under `### General`
- Prefix each note with a timestamp: `- [HH:MM] {text}`
- If only context is provided with no text (`/scrawl:note [file:line]`), read the referenced line and capture it as context
- **Code blocks**: Insert exactly as received — preserve the language identifier, indentation, and all whitespace. The code block includes a language tag (e.g. ` ```javascript `) for syntax highlighting — do not strip it.
- **File context line ranges** (e.g. `[file:10-12]`): Format as a bold reference on its own line: `**file:10-12**`

Append the note to the file. Do not rewrite the entire file.

## Example output in notes.md

```markdown
### src/models/review.js
- [14:32] this needs refactoring
  **src/models/review.js:10-12**
  ```javascript
  const x = 1;
  const y = 2;
  ```
- [14:35] check this validation
  **src/models/review.js:25-30**
  ```javascript
  if (!input) return null;
  ```
```

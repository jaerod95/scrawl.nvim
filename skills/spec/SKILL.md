---
name: spec
description: Use when the user invokes /scrawl:spec to write a planning spec from captured notes.
---

# Write Spec

Write a spec document from the captured planning notes.

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

## Writing the spec

1. Read all notes from the resolved file
2. Organize them into logical sections. The format is open-ended but should generally include:
   - Ticket context (title, description, key acceptance criteria from the notes header)
   - Files to change with specific changes described
   - New files to create
   - Migration needs
   - Testing considerations
   - Open questions or risks
3. Where the organized spec goes depends on how the file resolved:
   - **Pointer file (a target document)** — the notes _are_ the document. Organize in place: fold the captured notes into the spec sections within the same file. Preserve any prose the user wrote themselves, and preserve the file/line references and code blocks attached to each note. Never drop content the user did not ask you to drop.
   - **No pointer (`notes.md`)** — write a sibling `spec.md` in the same directory and leave `notes.md` untouched.
4. Present the spec to the user for review
5. Apply edits if requested

When working in a target document, show the user a diff-shaped summary of what you are about to restructure and get confirmation before writing. Their document may contain writing that has nothing to do with the captured notes.

---
name: notes
description: Use when the user invokes /scrawl:notes to display all captured planning notes for the current session.
---

# Show Notes

Display all captured notes from the active planning session.

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

Read the file and display its contents.

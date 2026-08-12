---
name: target
description: >-
  Use when the user invokes /scrawl:target with a file path to point the active
  planning session at a specific document. Notes, decisions, and the spec are
  written to that document instead of ~/.scrawl/specs/{repo}/{ticket}/notes.md.
---

# Set Target Document

Point the session at a document the user is already writing in.

## What the plugin already did

The Neovim side wrote the absolute path to `~/.scrawl/targets/{repo-name}` before sending this command. You do not need to write the pointer file — it exists.

## Your job

1. Confirm the pointer matches the path you were given:

```bash
cat "$HOME/.scrawl/targets/$(basename "$(git rev-parse --show-toplevel)")"
```

2. If the document does not exist, create it with a minimal header (the filename stem as the title) followed by a `## Notes` heading:

```markdown
# {filename stem}

## Notes
```

3. If the document does exist, read it. Do not restructure it and do not add a `## Notes` heading if the user already has their own structure — later notes go under whatever heading is closest to "notes" in intent, or at the end of the file if there is none. Report what you found: the title, the existing top-level headings, and roughly how much is already written.

4. Confirm in one line: `Target: {path}` plus where notes will land.

## Rules

- Never overwrite or reorganize a document the user already wrote. Append only.
- The path may contain spaces. Always quote it in shell commands.
- The target persists across sessions until the user retargets or clears it, so `/scrawl:note`, `/scrawl:decision`, `/scrawl:notes`, and `/scrawl:spec` all resolve to this document from now on.

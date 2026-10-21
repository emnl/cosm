---
description: Go through the inbox — file each item where it belongs and carry what it says onto your pages
---
# /inbox

Waiting in `01-inbox/` (oldest first):
!`bash .claude/scripts/cosm.sh inbox-list`

If it is empty, say so in one line and stop. Otherwise take one item at a time, oldest first.

## Each item

Work out what it is, then:

| Item | Do |
|---|---|
| A meeting note, transcript or meeting export | follow the meeting-notes skill |
| A session log (`*-log-*.md`) | check that what its Decided and Open sections say is on the pages, and write it where it isn't; propose its proposed tasks that aren't on the user's list yet; move it to `04-archive/logs/<YYYY-MM>/`, the month taken from its file name |
| A note, an idea, a fact | put it where it belongs: a line on a state page, or a dated note in the subject's `notes/` when it is longer than a line or two. The user's words are kept as written |
| A clipped web page | a dated note in the subject it is for, with its link at the top (from its `source:` line) and any frontmatter dropped |
| Something to do | propose it for the user's list, linked to its subject |
| A file that isn't text (PDF, Word, Excel, image, audio) | read it if it can be read (tools skill; audio can't, so say so). A meeting transcript then goes through the meeting-notes skill. Anything else: a short note on the right page saying what it is, what matters in it and where the file went. Suggest where the file should live outside the vault (the user's usual file storage, or `~/Downloads` if it is only scratch) and move it there on ==y==; on ==n== it stays and is listed at the end. Convert it into a markdown note only if the user asks, on ==y==. A `.txt` file is treated as a note |
| Nothing fits | ask once, with a suggestion: "Looks like notes from the Q4 budget meeting. File under Q4 budget? ==y== yes · or tell me" |

Filing moves the item's file out of `01-inbox/`, renamed to the vault's naming; that needs no ==y==. When an item's content now lives on pages and its file is left over, keep a list; at the end, ask once: "Delete the 3 inbox notes now on their pages? ==y== yes · ==n== no".

## After each item

One line on what went where, then the next item: "Filed as [[2026-10-21 Acme kickoff]] under [[Acme supply deal]]; updated [[Jonas Ek]]. 2 items left."

At the end, one line: what was filed, and what is still waiting and why.

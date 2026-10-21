---
description: Go through the inbox — file each item where it belongs and carry what it says onto your pages
---
# /inbox

Waiting in `01-inbox/` (oldest first):
!`find 01-inbox -type f -not -name '.*' -print0 2>/dev/null | xargs -0 ls -tr 2>/dev/null`

If it is empty, say so in one line and stop. Otherwise take one item at a time, oldest first. Filing, updating pages and creating new pages need no `y` (`AGENTS.md`); tasks for the user's list and anything deleted do.

## Each item

Work out what it is, then:

| Item | Do |
|---|---|
| A meeting note, transcript or meeting export | follow the meeting-notes skill |
| A session log (`*-log-*.md`) | carry what its Decided and Changed sections say onto the pages if a page doesn't already say it; propose its proposed tasks for the user's list; move it to `04-archive/logs/<YYYY-MM>/` |
| A note, an idea, a fact | put it where it belongs: a line on a state page, or a dated note in the subject's `notes/` when it is longer than a line or two. The user's words are kept as written |
| A clipped web page | a dated note in the subject it is for, with its link at the top; if it fits no subject, ask once where it goes |
| Something to do | propose it for the user's list, linked to its subject |
| A file that isn't markdown (PDF, Word, audio, image) | read it (tools skill); write a short note on the right page saying what it is and what matters in it; then suggest where the file should live outside the vault (the user's usual file storage, or `~/Downloads` if it is only scratch) and move it there on `y`. Only if the user wants the full content in the vault, convert it to a markdown note on `y` |
| Can't tell what it is or where it goes | ask once, with a suggestion: "Looks like notes from the Q4 budget meeting. File under Q4 budget? `y` · or tell me" |

Where something fits two subjects, the more specific one gets it and the other gets a link.

## After each item

One line on what went where, then the next item: "Filed as `acme-deal/notes/2026-10-21-kickoff.md`; updated Acme supply deal, Jonas Ek. 2 items left."

When the inbox is empty, say so. If the same kind of item was filed the same way several times this run, mention once that `/reflect` can turn it into a skill.

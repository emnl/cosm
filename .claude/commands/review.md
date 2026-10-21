---
description: Weekly review — what's due, what needs tidying, and what slipped through
---
# /review

Three parts, in order. Each finding is proposed on its own, with the keys that apply; apply it on ==y==, skip on ==s==. The inbox is `/inbox`'s, not this command's.

## What the vault shows

Today: !`date +%Y-%m-%d`

Open tasks with a date, due within 7 days or overdue:
!`bash .claude/scripts/cosm.sh due 7`

State pages over about 60 lines:
!`bash .claude/scripts/cosm.sh long-pages`

Dated headings or log sections on state pages:
!`bash .claude/scripts/cosm.sh log-headings`

Each subject's *As of* date and its newest note:
!`bash .claude/scripts/cosm.sh as-of`

Subjects with nothing changed in 90 days:
!`bash .claude/scripts/cosm.sh stale`

Folders inside a `notes/`:
!`bash .claude/scripts/cosm.sh notes-folders`

Two pages with the same name:
!`bash .claude/scripts/cosm.sh dup-names`

Links to pages that don't exist:
!`bash .claude/scripts/cosm.sh broken-links`

Folders not yet in `MAP.md`:
!`bash .claude/scripts/cosm.sh unmapped`

Files that aren't markdown, or don't belong at the root:
!`bash .claude/scripts/cosm.sh stray-files`

Preferences and profile over their size:
!`bash .claude/scripts/cosm.sh oversize`

Session logs since the last review:
!`bash .claude/scripts/cosm.sh logs-since-review`

## 1. Due

The tasks above, overdue first, each with its subject; the agent's own (`tasks.md`) last, under "Mine:". If `profile.md` says the user keeps a list elsewhere, read it too. For each overdue one of the user's, ask: "==y== done · ==n== drop · or type a new date". For the agent's own, do or check it now if it can, write the outcome on its subject page, and tick it.

## 2. Tidying

Go through what the lookups found, one finding at a time, with a proposed fix:

- **Page over 60 lines:** propose which section moves to `notes/`, leaving a line with a link.
- **Dated heading or log on a state page:** propose rewriting it as current lines, with anything worth keeping moved to a dated note.
- **As of older than the newest note:** read the note; propose the state lines it should have changed. If the page already says it, propose moving *As of* to the note's date.
- **Nothing changed in 90 days:** propose moving the subject to `04-archive/subjects/` (never the user's own subject).
- **Folder inside `notes/`, same name twice, broken link, file that isn't markdown or doesn't belong:** propose the fix (rename, re-link, create the missing page, move to `~/Downloads` or where the user keeps files).
- **Folder missing from `MAP.md`:** add it (no ==y== needed) and say so.
- **Preferences or profile over size:** show a tighter version (duplicates merged, overridden lines dropped) for a ==y==.
- While reading pages for the fixes above: anything kept in two places that has drifted apart (the same date on two pages, the same task in two lists): propose the one place and a link.

If nothing was found, say "Vault is tidy." in one line.

## 3. Slipped through

Read the Decided and Open sections of the logs above. For anything a page doesn't already say, propose writing it there.

Then read the preference files and the same logs, and propose, one at a time:
- **Preferences:** a way of working the user showed in several sessions that no preference line says yet; a line corrected several times (a firmer line, or moving it into its skill); two lines that say the same thing (merge them).
- **Skills:** a procedure done the same way in several sessions, made into a skill the way `/reflect` does; or an update to an existing skill the logs show was corrected or done differently (edited directly for a skill in `03-references/skills/`, as preference lines for one that ships with cosm).

## Finish

Write today's date to `.cosm-last-review` (one line), and close with one line: what was done, what was skipped.

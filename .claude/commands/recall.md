---
description: Where things stand — what's due, what you worked on last, and what to pick up
---
# /recall

Takes no argument. `profile.md` and `MAP.md` are already loaded. If `profile.md` has no name in it, the vault is new: suggest `/setup` and stop.

## What the vault shows

Today: !`date +%Y-%m-%d`

Open tasks with a date:
!`grep -rn --include=tasks.md -e '- \[ \].*📅' 02-subjects 2>/dev/null | head -40`

Most recently changed pages (newest first):
!`find 02-subjects 03-references -name '*.md' -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -5`

Folders not yet in MAP.md: !`find 02-subjects 03-references 03-references/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r d; do grep -qF "$d/" MAP.md || echo "$d/"; done`

Items waiting in the inbox: !`find 01-inbox -type f -not -name '.*' 2>/dev/null | wc -l | tr -d ' '`

Last review: !`cat .cosm-last-review 2>/dev/null || echo never`

Newest session log: !`find 04-archive/logs -name '*.md' 2>/dev/null | sort | tail -1`

## Answer

Keep it to a few lines, in the user's language:

1. **Due:** tasks dated today or earlier, and those due in the next 3 days, each with its subject. Leave the line out when there are none.
2. **Last worked on:** the recently changed pages grouped by subject (a page in `02-subjects/acme-deal/` belongs to Acme deal; a reference page goes with the subject it links to, or stands alone). If there is a newest session log, read only its summary at the top and add one line from it.
3. **Map:** add any folder listed as not yet in `MAP.md`, with a few words, and say so in one line.
4. **Inbox:** if items are waiting, one line: "3 items in the inbox. /inbox?"
5. **Review:** if the last review is "never" and the vault has subjects, or more than 7 days old, one line: "Last review 12 days ago. /review?"
6. Ask which subject to pick up, as numbered options, plus "something else".

When the user picks a subject, read its state page (and `tasks.md` if there is one) and say where it stands and what is open, in a few lines. Then wait for what they want to do.

---
description: Where things stand — what's due, what you worked on last, and what to pick up
---
# /recall

Takes no argument. `profile.md` and `MAP.md` are already loaded. If `## Me` in `profile.md` is empty, the vault is new: suggest `/setup` and stop.

## What the vault shows

Today: !`date +%Y-%m-%d`

Open tasks due within 3 days, overdue included, from anywhere in the vault:
!`grep -rn --include='*.md' -E '^[[:space:]]*- \[ \].*[0-9]{4}-[0-9]{2}-[0-9]{2}' 01-inbox 02-subjects 03-references 2>/dev/null | awk -v lim="$(date -v+3d +%F)" '{s=$ 0; sub(/^[^:]*:[0-9]+:/,"",s); if (match(s,/📅 *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) d=substr(s,RSTART+RLENGTH-10,10); else {gsub(/\[\[[^]]*\]\]/,"",s); if (!match(s,/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) next; d=substr(s,RSTART,10)} if (d<=lim) print}'`

Most recently changed pages (newest first):
!`find 02-subjects -name '*.md' -not -name todo.md -not -name tasks.md -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -5`

Folders not yet in MAP.md: !`find 02-subjects 03-references 03-references/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r d; do grep -qF "$d/" MAP.md || echo "$d/"; done`

Items waiting in the inbox: !`find 01-inbox -type f -not -name '.*' 2>/dev/null | wc -l | tr -d ' '`

Last review: !`cat .cosm-last-review 2>/dev/null || echo never`

Newest session log: !`find 01-inbox 04-archive/logs -name '*-log-*.md' 2>/dev/null | awk -F/ '{print $NF "\t" $ 0}' | sort | tail -1 | cut -f2`

## Answer

Keep it to a few lines, in the user's language:

1. **Due:** the tasks above, overdue first, each with its subject. Lines from a subject's `tasks.md` are the agent's own: list them last, under "Mine:". If `profile.md` says the user keeps a list somewhere in their own shape, read it too. Leave the line out when nothing is due.
2. **Last worked on:** the recently changed pages grouped by subject (a page in `02-subjects/acme-deal/` belongs to Acme deal). If there is a session log, read only its `## Summary` section and add one line on what happened. It is history, not a task list: never raise an item from it as open or due.
3. **Map:** add any folder listed as not yet in `MAP.md`, with a few words, and say so in one line.
4. **Inbox:** if items are waiting, one line: "3 items in the inbox. /inbox?"
5. **Review:** if the last review was more than 7 days ago, one line: "Last review 12 days ago. /review?"
6. If the user's message asked something, answer it here instead. Otherwise ask which subject to pick up: the subjects from Due and Last worked on, numbered, plus "something else".

When the user picks a subject, read its state page (and `tasks.md` if there is one) and say where it stands and what is open, in a few lines. Then wait for what they want to do.

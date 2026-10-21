---
description: Where things stand — what's due, what you worked on last, and what to pick up
---
# /recall

Takes no argument. `profile.md` and `MAP.md` are already loaded. If `## Me` in `profile.md` is empty, the vault is new: suggest `/setup` and stop.

## What the vault shows

Today: !`date +%Y-%m-%d`

Open tasks due within 3 days, overdue included, from anywhere in the vault:
!`bash .claude/scripts/cosm.sh due 3`

Most recently changed pages (newest first):
!`bash .claude/scripts/cosm.sh recent`

Folders not yet in MAP.md: !`bash .claude/scripts/cosm.sh unmapped`

Items waiting in the inbox: !`bash .claude/scripts/cosm.sh inbox-count`

Last review: !`bash .claude/scripts/cosm.sh last-review`

Newest session log and its summary: !`bash .claude/scripts/cosm.sh log-summary`

## Answer

Keep it to a few lines, in the user's language:

1. **Due:** the tasks above, overdue first, each with its subject. Lines from a subject's `tasks.md` are the agent's own: list them last, under "Mine:". If `profile.md` says the user keeps a list somewhere in their own shape, read it too. Leave the line out when nothing is due.
2. **Last worked on:** the recently changed pages grouped by subject (a page in `02-subjects/Acme supply deal/` belongs to Acme supply deal). If there is a session log, add one line on what happened from its summary above. It is history, not a task list: never raise an item from it as open or due.
3. **Map:** add any folder listed as not yet in `MAP.md`, with a few words, and say so in one line.
4. **Inbox:** if items are waiting, one line: "3 items in the inbox. /inbox?"
5. **Review:** if the last review was more than 7 days ago, one line: "Last review 12 days ago. /review?"
6. If the user's message asked something, answer it here instead. Otherwise end with one line that suggests where to pick up and leaves it open: "Pick up where you left off: [[Acme supply deal]], [[Q4 budget]] — or just tell me what you want to do." No numbered choice.

When the user names a subject, read its state page (and `tasks.md` if there is one) and say where it stands and what is open, in a few lines. Then wait for what they want to do.

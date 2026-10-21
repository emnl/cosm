---
description: Write a record of this session into the inbox — what was decided, what changed, what's next
---
# /log

Now: !`date +%Y-%m-%d-%H%M`

Write one file, `01-inbox/<now>-log-<topic>.md`, where `<topic>` is two to four words for what the session was mostly about (`acme-pricing`). `/inbox` files it later; `/recall` reads its Summary next time.

Written from this session only. It records; it doesn't decide anything new. Facts should already be on their pages (`AGENTS.md`, write as you go); if one isn't, write it there now, before the log.

```
# <Topic in words>, <date>

## Summary
Two to four sentences: what the session was about and where it ended.

## Decided
- Each decision the user made, with its reason in their words; link the page it lives on.

## Changed in the vault
- Each page created or changed, as a link, with a few words on what changed.

## Open
- What is unfinished or waiting, and on whom.

## Proposed tasks
- Things the user said they'd do, for their list (filed only on their `y` during /inbox).
```

Leave a section out when it would be empty. No transcript, no tool output, no long quotes.

Then say in one line where the log is, and that `/inbox` will file it.

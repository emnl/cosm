---
description: Weekly review — what's due, what needs tidying, and what slipped through
---
# /review

Run about once a week. Three parts, in order. Each finding is proposed on its own, with the keys that apply; apply it on `y`, skip on `s`. Nothing is changed without a `y`. The inbox is `/inbox`'s, not this command's.

## What the vault shows

Today: !`date +%Y-%m-%d`

Open tasks with a date, due within 7 days or overdue:
!`grep -rn --include='*.md' -E '^[[:space:]]*- \[ \].*[0-9]{4}-[0-9]{2}-[0-9]{2}' 01-inbox 02-subjects 03-references 2>/dev/null | awk 'BEGIN{"date -v+7d +%F" | getline lim} {if (match($0, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) && substr($0, RSTART, 10) <= lim) print}'`

State pages over about 60 lines:
!`setopt NULL_GLOB 2>/dev/null; for f in 02-subjects/*/*.md 03-references/*/*.md; do [ -f "$f" ] || continue; case "$f" in */todo.md|*/tasks.md) continue;; esac; n=$(wc -l < "$f" | tr -d ' '); [ "$n" -gt 60 ] && echo "$f ($n lines)"; done 2>/dev/null; true`

Dated headings or log sections on state pages:
!`setopt NULL_GLOB 2>/dev/null; grep -n -E '^#+ .*([0-9]{4}-[0-9]{2}-[0-9]{2}|Log|History|Changelog|Updates)' 02-subjects/*/*.md 03-references/*/*.md 2>/dev/null | grep -v -E '/(todo|tasks)\.md:'; true`

Each subject's *As of* date and its newest note:
!`setopt NULL_GLOB 2>/dev/null; for d in 02-subjects/*/; do [ -d "$d" ] || continue; s=$(basename "$d"); a=$(grep -m1 -o -E '\*As of [0-9]{4}-[0-9]{2}-[0-9]{2}' "$d$s.md" 2>/dev/null | grep -o -E '[0-9-]{10}'); n=$(ls "$d"notes 2>/dev/null | grep -o -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | tail -1); echo "$s: as of ${a:-none}, newest note ${n:-none}"; done 2>/dev/null; true`

Subjects with nothing changed in 90 days:
!`setopt NULL_GLOB 2>/dev/null; for d in 02-subjects/*/; do [ -d "$d" ] || continue; [ -z "$(find "$d" -type f -mtime -90 2>/dev/null | head -1)" ] && echo "$d"; done 2>/dev/null; true`

Folders inside a `notes/`:
!`find 02-subjects -path '*/notes/*' -type d 2>/dev/null`

Two pages with the same name:
!`find 01-inbox 02-subjects 03-references 04-archive -name '*.md' -not -name todo.md -not -name tasks.md 2>/dev/null | awk -F/ '{print $NF}' | sort | uniq -d`

Links to pages that don't exist:
!`grep -rhoE '\[\[[^]|#]+' --include='*.md' 02-subjects 03-references 2>/dev/null | sed 's/\[\[//' | sort -u | while read -r l; do [ -n "$(find . -name "$l.md" -not -path './.*' 2>/dev/null | head -1)" ] || echo "[[$l]]"; done`

Folders not yet in `MAP.md`:
!`find 02-subjects 03-references 03-references/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r d; do grep -qF "$d/" MAP.md || echo "$d/"; done`

Files that aren't markdown, or don't belong at the root:
!`setopt NULL_GLOB 2>/dev/null; find 01-inbox 02-subjects 03-references 04-archive -type f -not -name '*.md' -not -name '.*' 2>/dev/null; ls *.md 2>/dev/null | grep -v -x -E 'AGENTS.md|CLAUDE.md|HOME.md|HELP.md|MAP.md|README.md|CHANGES.md|profile.md'; true`

Preferences and profile over their size:
!`setopt NULL_GLOB 2>/dev/null; for f in 03-references/preferences/*.md; do [ -f "$f" ] && [ "$(wc -c < "$f")" -gt 2000 ] && echo "$f"; done 2>/dev/null; [ -f profile.md ] && [ "$(wc -c < profile.md)" -gt 1500 ] && echo profile.md; true`

Session logs from the last 8 days:
!`find 04-archive/logs -name '*-log-*.md' -mtime -8 2>/dev/null | sort`

## 1. Due

The tasks above, overdue first, each with its subject; the agent's own (`tasks.md`) last, under "Mine:". For each overdue one of the user's, ask: done (`y` ticks it), new date, or drop. For the agent's own, do or check it now if it can, write the outcome on its subject page, and tick it.

## 2. Tidying

Go through what the lookups found, one finding at a time, with a proposed fix:

- **Page over 60 lines:** propose which section moves to `notes/`, leaving a line with a link.
- **Dated heading or log on a state page:** propose rewriting it as current lines, with anything worth keeping moved to a dated note.
- **As of older than the newest note:** read the note; propose the state lines it should have changed.
- **Nothing changed in 90 days:** propose moving the subject to `04-archive/subjects/`.
- **Folder inside `notes/`, same name twice, broken link, file that isn't markdown or doesn't belong:** propose the fix (rename, re-link, move to `~/Downloads` or where the user keeps files).
- **Folder missing from `MAP.md`:** add it (no `y` needed) and say so.
- **Preferences or profile over size:** show a tighter version (duplicates merged, overridden lines dropped) for a `y`.
- Anything kept in two places that has drifted apart (the same date on two pages, the same task in two lists): propose the one place and a link.

If nothing was found, say "Vault is tidy." in one line.

## 3. Slipped through

Read the Decided and Open sections of the logs above. For anything a page doesn't already say, propose writing it there.

## Finish

Write today's date to `.cosm-last-review` (one line), and close with one line: what was done, what was skipped.

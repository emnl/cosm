---
description: Weekly review — what's due, what needs tidying, and what slipped through
---
# /review

Three parts, in order. Each finding is proposed on its own, with the keys that apply; apply it on <kbd>y</kbd>, skip on <kbd>s</kbd>. The inbox is `/inbox`'s, not this command's.

## What the vault shows

Today: !`date +%Y-%m-%d`

Open tasks with a date, due within 7 days or overdue:
!`grep -rn --include='*.md' -E '^[[:space:]]*- \[ \].*[0-9]{4}-[0-9]{2}-[0-9]{2}' 01-inbox 02-subjects 03-references 2>/dev/null | awk -v lim="$(date -v+7d +%F)" '{s=$ 0; sub(/^[^:]*:[0-9]+:/,"",s); if (match(s,/📅 *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) d=substr(s,RSTART+RLENGTH-10,10); else {gsub(/\[\[[^]]*\]\]/,"",s); if (!match(s,/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) next; d=substr(s,RSTART,10)} if (d<=lim) print}'`

State pages over about 60 lines:
!`setopt NULL_GLOB 2>/dev/null; for f in 02-subjects/*/*.md 03-references/*/*.md; do [ -f "$f" ] || continue; case "$f" in */todo.md|*/tasks.md) continue;; esac; n=$(wc -l < "$f" | tr -d ' '); [ "$n" -gt 60 ] && echo "$f ($n lines)"; done 2>/dev/null; true`

Dated headings or log sections on state pages:
!`setopt NULL_GLOB 2>/dev/null; grep -n -E '^##+ (.*[^[:alnum:]])?([0-9]{4}-[0-9]{2}-[0-9]{2}|Log|History|Changelog|Updates)([^[:alnum:]].*)?$' 02-subjects/*/*.md 03-references/*/*.md 2>/dev/null | grep -v -E '/(todo|tasks)\.md:'; true`

Each subject's *As of* date and its newest note:
!`setopt NULL_GLOB 2>/dev/null; for d in 02-subjects/*/; do [ -d "$d" ] || continue; s=$(basename "$d"); a=$(grep -m1 -o -E '\*As of [0-9]{4}-[0-9]{2}-[0-9]{2}' "$d$s.md" 2>/dev/null | grep -o -E '[0-9-]{10}'); n=$(ls "$d"notes 2>/dev/null | grep -o -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | tail -1); echo "$s: as of ${a:-none}, newest note ${n:-none}"; done 2>/dev/null; true`

Subjects with nothing changed in 90 days:
!`setopt NULL_GLOB 2>/dev/null; for d in 02-subjects/*/; do [ -d "$d" ] || continue; [ -z "$(find "$d" -type f -mtime -90 2>/dev/null | head -1)" ] && echo "$d"; done 2>/dev/null; true`

Folders inside a `notes/`:
!`find 02-subjects -path '*/notes/*' -type d 2>/dev/null`

Two pages with the same name:
!`find 01-inbox 02-subjects 03-references 04-archive -name '*.md' -not -name todo.md -not -name tasks.md -not -path '03-references/skills/*' 2>/dev/null | awk -F/ '{print tolower($NF)}' | sort | uniq -d`

Links to pages that don't exist:
!`grep -rhoE --exclude-dir=skills '\[\[[^]|#]+' --include='*.md' 02-subjects 03-references 2>/dev/null | sed -E 's/^\[\[//; s/\\$//; s#.*/##; s/\.md$//' | grep -v -E '\.[A-Za-z0-9]{2,4}$' | sort -uf | while IFS= read -r l; do [ -n "$(find . -iname "$l.md" -not -path './.*' 2>/dev/null | head -1)" ] || echo "[[$l]]"; done`

Folders not yet in `MAP.md`:
!`find 02-subjects 03-references 03-references/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r d; do grep -qF "$d/" MAP.md || echo "$d/"; done`

Files that aren't markdown, or don't belong at the root:
!`find 02-subjects 03-references 04-archive -type f -not -name '*.md' -not -name '.*' -not -path '03-references/skills/*' 2>/dev/null; ls -p | grep -v / | grep -v -x -E 'AGENTS.md|CLAUDE.md|HOME.md|HELP.md|MAP.md|README.md|CHANGES.md|MANIFEST|VERSION|profile.md'; true`

Preferences and profile over their size:
!`setopt NULL_GLOB 2>/dev/null; for f in 03-references/preferences/*.md; do [ -f "$f" ] && [ "$(wc -c < "$f")" -gt 2000 ] && echo "$f"; done 2>/dev/null; [ -f profile.md ] && [ "$(wc -c < profile.md)" -gt 1500 ] && echo profile.md; true`

Session logs since the last review:
!`L=$(cat .cosm-last-review 2>/dev/null); L=$(date -j -v-7d -f %Y-%m-%d "${L:-2000-01-01}" +%F); find 04-archive/logs -name '*-log-*.md' 2>/dev/null | awk -F/ -v l="$L" '$NF >= l' | sort`

## 1. Due

The tasks above, overdue first, each with its subject; the agent's own (`tasks.md`) last, under "Mine:". If `profile.md` says the user keeps a list elsewhere, read it too. For each overdue one of the user's, ask: "<kbd>y</kbd> done · <kbd>n</kbd> drop · or type a new date". For the agent's own, do or check it now if it can, write the outcome on its subject page, and tick it.

## 2. Tidying

Go through what the lookups found, one finding at a time, with a proposed fix:

- **Page over 60 lines:** propose which section moves to `notes/`, leaving a line with a link.
- **Dated heading or log on a state page:** propose rewriting it as current lines, with anything worth keeping moved to a dated note.
- **As of older than the newest note:** read the note; propose the state lines it should have changed. If the page already says it, propose moving *As of* to the note's date.
- **Nothing changed in 90 days:** propose moving the subject to `04-archive/subjects/` (never the user's own subject).
- **Folder inside `notes/`, same name twice, broken link, file that isn't markdown or doesn't belong:** propose the fix (rename, re-link, create the missing page, move to `~/Downloads` or where the user keeps files).
- **Folder missing from `MAP.md`:** add it (no <kbd>y</kbd> needed) and say so.
- **Preferences or profile over size:** show a tighter version (duplicates merged, overridden lines dropped) for a <kbd>y</kbd>.
- While reading pages for the fixes above: anything kept in two places that has drifted apart (the same date on two pages, the same task in two lists): propose the one place and a link.

If nothing was found, say "Vault is tidy." in one line.

## 3. Slipped through

Read the Decided and Open sections of the logs above. For anything a page doesn't already say, propose writing it there.

Then read the preference files and the same logs, and propose, one at a time:
- **Preferences:** a way of working the user showed in several sessions that no preference line says yet; a line corrected several times (a firmer line, or moving it into its skill); two lines that say the same thing (merge them).
- **Skills:** a procedure done the same way in several sessions, made into a skill the way `/reflect` does; or an update to an existing skill the logs show was corrected or done differently (edited directly for a skill in `03-references/skills/`, as preference lines for one that ships with cosm).

## Finish

Write today's date to `.cosm-last-review` (one line), and close with one line: what was done, what was skipped.

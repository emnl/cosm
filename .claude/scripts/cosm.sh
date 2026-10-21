#!/bin/bash
# Read-only lookups for cosm's commands. Run from the vault root:
#   bash .claude/scripts/cosm.sh <lookup> [arg]
# Every lookup prints plain lines, or nothing, and always exits 0.
shopt -s nullglob
cd "$(dirname "$0")/../.." || exit 0

due() { # open tasks with a date, due within $1 days or overdue
  local lim; lim=$(date -v+"${1:-3}"d +%F)
  grep -rn --include='*.md' -E '^[[:space:]]*- \[ \].*[0-9]{4}-[0-9]{2}-[0-9]{2}' 01-inbox 02-subjects 03-references 2>/dev/null |
  awk -v lim="$lim" '{s=$0; sub(/^[^:]*:[0-9]+:/,"",s);
    if (match(s,/📅 *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) d=substr(s,RSTART+RLENGTH-10,10);
    else {gsub(/\[\[[^]]*\]\]/,"",s); if (!match(s,/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) next; d=substr(s,RSTART,10)}
    if (d<=lim) print}'
}
recent() { find 02-subjects -name '*.md' -not -name todo.md -not -name tasks.md -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -5; }
unmapped() { find 02-subjects 03-references 03-references/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while IFS= read -r d; do grep -qF "$d/" MAP.md || echo "$d/"; done; }
inbox_count() { find 01-inbox -type f -not -name '.*' 2>/dev/null | wc -l | tr -d ' '; }
inbox_list() { find 01-inbox -type f -not -name '.*' -print0 2>/dev/null | xargs -0 ls -tr 2>/dev/null; }
last_review() { cat .cosm-last-review 2>/dev/null || echo never; }
log_summary() { local f; f=$(newest_log); [ -n "$f" ] && { echo "$f"; awk '/^## Summary/{f=1;next} /^## /{f=0} f' "$f"; }; }
newest_log() { find 01-inbox 04-archive/logs -name '*-log-*.md' 2>/dev/null | awk -F/ '{print $NF "\t" $0}' | sort | tail -1 | cut -f2; }
pages() { find 02-subjects 03-references -name '*.md' 2>/dev/null; }
toolbox() { ~/.local/bin/uv --version 2>/dev/null || command -v uv 2>/dev/null || echo "not installed"; }
long_pages() { for f in 02-subjects/*/*.md 03-references/*/*.md; do case "$f" in */todo.md|*/tasks.md) continue;; esac; n=$(wc -l < "$f" | tr -d ' '); [ "$n" -gt 60 ] && echo "$f ($n lines)"; done; }
log_headings() { grep -n -E '^##+ (.*[^[:alnum:]])?([0-9]{4}-[0-9]{2}-[0-9]{2}|Log|History|Changelog|Updates)([^[:alnum:]].*)?$' 02-subjects/*/*.md 03-references/*/*.md 2>/dev/null | grep -v -E '/(todo|tasks)\.md:'; }
as_of() { for d in 02-subjects/*/; do s=$(basename "$d"); a=$(grep -m1 -o -E '\*As of [0-9]{4}-[0-9]{2}-[0-9]{2}' "$d$s.md" 2>/dev/null | grep -o -E '[0-9-]{10}'); n=$(ls "$d"notes 2>/dev/null | grep -o -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | tail -1); echo "$s: as of ${a:-none}, newest note ${n:-none}"; done; }
stale() { for d in 02-subjects/*/; do [ -z "$(find "$d" -type f -mtime -90 2>/dev/null | head -1)" ] && echo "$d"; done; }
notes_folders() { find 02-subjects -path '*/notes/*' -type d 2>/dev/null; }
dup_names() { find 01-inbox 02-subjects 03-references 04-archive -name '*.md' -not -name todo.md -not -name tasks.md -not -path '03-references/skills/*' 2>/dev/null | awk -F/ '{print tolower($NF)}' | sort | uniq -d; }
broken_links() {
  grep -rhoE --exclude-dir=skills '\[\[[^]|#]+' --include='*.md' 02-subjects 03-references 2>/dev/null |
  sed -E 's/^\[\[//; s/\\$//; s#.*/##; s/\.md$//' | grep -v -E '\.[A-Za-z0-9]{2,4}$' | sort -uf |
  while IFS= read -r l; do [ -n "$(find . -iname "$l.md" -not -path './.*' 2>/dev/null | head -1)" ] || echo "[[$l]]"; done
}
stray_files() {
  find 02-subjects 03-references 04-archive -type f -not -name '*.md' -not -name '.*' -not -path '03-references/skills/*' 2>/dev/null
  ls -p | grep -v / | grep -v -x -E 'AGENTS.md|CLAUDE.md|HOME.md|HELP.md|MAP.md|README.md|CHANGES.md|MANIFEST|VERSION|profile.md'
}
oversize() { for f in 03-references/preferences/*.md; do [ "$(wc -c < "$f")" -gt 2000 ] && echo "$f"; done; [ -f profile.md ] && [ "$(wc -c < profile.md)" -gt 1500 ] && echo profile.md; }
logs_since_review() { local l; l=$(cat .cosm-last-review 2>/dev/null); l=$(date -j -v-7d -f %Y-%m-%d "${l:-2000-01-01}" +%F 2>/dev/null); find 04-archive/logs -name '*-log-*.md' 2>/dev/null | awk -F/ -v l="$l" '$NF >= l' | sort; }
version() { cat VERSION 2>/dev/null || echo unknown; }
source_url() { grep -m1 '^# source:' MANIFEST 2>/dev/null | sed 's/^# source: *//'; }

case "$1" in
  due) due "$2" ;; recent) recent ;; unmapped) unmapped ;; inbox-count) inbox_count ;; inbox-list) inbox_list ;;
  last-review) last_review ;; newest-log) newest_log ;; log-summary) log_summary ;; pages) pages ;; toolbox) toolbox ;;
  long-pages) long_pages ;; log-headings) log_headings ;; as-of) as_of ;; stale) stale ;; notes-folders) notes_folders ;;
  dup-names) dup_names ;; broken-links) broken_links ;; stray-files) stray_files ;; oversize) oversize ;;
  logs-since-review) logs_since_review ;; version) version ;; source) source_url ;;
esac
exit 0

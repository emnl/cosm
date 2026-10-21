#!/bin/bash
# Read-only lookups for cosm's commands. Run from the vault root:
#   bash .claude/scripts/cosm.sh <lookup> [arg]
# Every lookup prints plain lines, or nothing, and always exits 0.
shopt -s nullglob
cd "$(dirname "$0")/../.." || exit 0

due() { # open tasks with a date, due within $1 days or overdue
  local lim; lim=$(date -v+"${1:-3}"d +%F)
  grep -rn --include='*.md' -E '^[[:space:]]*- \[ \].*[0-9]{4}-[0-9]{2}-[0-9]{2}' 01-inbox 02-spaces 03-knowledge 2>/dev/null |
  awk -v lim="$lim" '{s=$0; sub(/^[^:]*:[0-9]+:/,"",s);
    if (match(s,/📅 *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) d=substr(s,RSTART+RLENGTH-10,10);
    else {gsub(/\[\[[^]]*\]\]/,"",s); if (!match(s,/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) next; d=substr(s,RSTART,10)}
    if (d<=lim) print}'
}
recent() { find 02-spaces -name '*.md' -not -name todo.md -not -name tasks.md -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -5; }
unmapped() { # a folder counts as mapped when MAP.md lists it by name, indented ("- Name/") or as a full path (".../Name/"); two folders with one name count as one
  find 02-spaces 03-knowledge 03-knowledge/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while IFS= read -r d; do
    n=${d##*/}; grep -qF -- "- $n/" MAP.md || grep -qF -- "/$n/" MAP.md || echo "$d/"; done; }
inbox_count() { find 01-inbox -type f -not -name '.*' 2>/dev/null | wc -l | tr -d ' '; }
inbox_list() { find 01-inbox -type f -not -name '.*' -print0 2>/dev/null | xargs -0 ls -tr 2>/dev/null; }
last_review() { cat .cosm-last-review 2>/dev/null || echo never; }
log_summary() { local f; f=$(newest_log); [ -n "$f" ] && { echo "$f"; awk '/^## Summary/{f=1;next} /^## /{f=0} f' "$f"; }; }
newest_log() { find 01-inbox 04-archive/logs -name '* Log – *.md' 2>/dev/null | awk -F/ '{print $NF "\t" $0}' | sort | tail -1 | cut -f2; }
pages() { find 02-spaces 03-knowledge -name '*.md' 2>/dev/null; }
toolbox() { ~/.local/bin/uv --version 2>/dev/null || command -v uv 2>/dev/null || echo "not installed"; }
long_pages() { for f in 02-spaces/*/*.md 03-knowledge/*/*/*.md; do case "$f" in */todo.md|*/tasks.md|*/SKILL.md) continue;; esac; n=$(wc -l < "$f" | tr -d ' '); [ "$n" -gt 60 ] && echo "$f ($n lines)"; done; }
log_headings() { grep -n -E '^##+ (.*[^[:alnum:]])?([0-9]{4}-[0-9]{2}-[0-9]{2}|Log|History|Changelog|Updates)([^[:alnum:]].*)?$' 02-spaces/*/*.md 03-knowledge/*/*/*.md 2>/dev/null | grep -v -E '/(todo|tasks|SKILL)\.md:'; }
as_of() { for d in 02-spaces/*/ 03-knowledge/*/*/; do case "$d" in 03-knowledge/skills/*) continue;; esac; s=$(basename "$d"); a=$(grep -m1 -o -E '\*As of [0-9]{4}-[0-9]{2}-[0-9]{2}' "$d$s.md" 2>/dev/null | grep -o -E '[0-9-]{10}'); n=$(ls "$d"notes 2>/dev/null | grep -o -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | tail -1); echo "$s: as of ${a:-none}, newest note ${n:-none}"; done; }
stale() { for d in 02-spaces/*/; do [ -z "$(find "$d" -type f -mtime -90 2>/dev/null | head -1)" ] && echo "$d"; done; }
notes_folders() { find 02-spaces 03-knowledge -path '*/notes/*' -type d 2>/dev/null; }
dup_names() { find 01-inbox 02-spaces 03-knowledge 04-archive -name '*.md' -not -name todo.md -not -name tasks.md -not -path '03-knowledge/skills/*' 2>/dev/null | awk -F/ '{print tolower($NF)}' | sort | uniq -d; }
broken_links() {
  grep -rhoE --exclude-dir=skills '\[\[[^]|#]+' --include='*.md' 02-spaces 03-knowledge 2>/dev/null |
  sed -E 's/^\[\[//; s/\\$//; s#.*/##; s/\.md$//' | grep -v -E '\.[A-Za-z0-9]{2,4}$' | sort -uf |
  while IFS= read -r l; do [ -n "$(find . -iname "$l.md" -not -path './.*' 2>/dev/null | head -1)" ] || echo "[[$l]]"; done
}
stray_files() {
  find 02-spaces 03-knowledge 04-archive -type f -not -name '*.md' -not -name '.*' -not -path '03-knowledge/skills/*' 2>/dev/null
  ls -p | grep -v / | grep -v -x -E 'AGENTS.md|CLAUDE.md|HOME.md|HELP.md|MAP.md|README.md|CHANGES.md|MANIFEST|VERSION|profile.md'
}
oversize() { for f in 03-knowledge/preferences/*.md; do [ "$(wc -c < "$f")" -gt 2000 ] && echo "$f"; done; [ -f profile.md ] && [ "$(wc -c < profile.md)" -gt 1500 ] && echo profile.md; }
logs_since_review() { local l; l=$(cat .cosm-last-review 2>/dev/null); l=$(date -j -v-7d -f %Y-%m-%d "${l:-2000-01-01}" +%F 2>/dev/null); find 04-archive/logs -name '* Log – *.md' 2>/dev/null | awk -F/ -v l="$l" '$NF >= l' | sort; }
open_page() { local f; f=$(osascript -l JavaScript .claude/scripts/open-page.js "$PWD/.obsidian/workspace.json" 2>/dev/null); [ -n "$f" ] && { n=${f##*/}; echo "The page open in Obsidian right now: [[${n%.md}]] ($f)"; }; }
version() { cat VERSION 2>/dev/null || echo unknown; }
source_url() { grep -m1 '^# source:' MANIFEST 2>/dev/null | sed 's/^# source: *//'; }

# --- /update -------------------------------------------------------------------
manifest_paths() { grep -v -e '^#' -e '^[[:space:]]*$' "$1" 2>/dev/null; }
bad_path() { case "$1" in /*|*..*|0[1-4]-*|profile.md|MAP.md) return 0;; esac; return 1; }
update_fetch() { # download the newest version; prints NEW=<folder> and VERSION=<x>
  local t n; t=$(mktemp -d) || { echo "FAIL could not make a temporary folder"; return; }
  if curl -fsSL "$(source_url)/archive/refs/heads/main.zip" -o "$t/cosm.zip" 2>"$t/err" && unzip -q "$t/cosm.zip" -d "$t" 2>>"$t/err"; then
    n=$(ls -d "$t"/*/ 2>/dev/null | head -1)
    if [ -n "$n" ] && [ -f "$n/VERSION" ]; then echo "NEW=${n%/}"; echo "VERSION=$(cat "$n/VERSION")"; return; fi
  fi
  echo "FAIL $(head -c 300 "$t/err" 2>/dev/null)"; rm -rf "$t"
}
update_apply() { # replace the system files from folder $1 (made by update-fetch)
  local n="$1" p d count=0 dropped=""
  case "$n" in "${TMPDIR%/}"/tmp.*/*|/tmp/tmp.*/*|/private/var/folders/*/tmp.*/*|/var/folders/*/tmp.*/*) ;; *) echo "FAIL not an update folder: $n"; return;; esac
  [ -f "$n/MANIFEST" ] || { echo "FAIL no MANIFEST in $n"; return; }
  while IFS= read -r p; do bad_path "$p" && { echo "FAIL refusing path: $p"; return; }; done < <(manifest_paths "$n/MANIFEST"; manifest_paths MANIFEST)
  while IFS= read -r p; do [ -e "$n/${p%/}" ] || { echo "FAIL missing in new version: $p"; return; }; done < <(manifest_paths "$n/MANIFEST")
  while IFS= read -r p; do
    case "$p" in MANIFEST|VERSION) continue;; esac
    d="${p%/}"; mkdir -p "$(dirname "./$d")" || { echo "FAIL $p (replaced so far: $count)"; return; }
    if [ "$p" != "$d" ]; then rm -rf "./$d" && cp -R "$n/$d" "./$d"; else cp "$n/$d" "./$d"; fi || { echo "FAIL $p (replaced so far: $count)"; return; }
    count=$((count+1))
  done < <(manifest_paths "$n/MANIFEST")
  while IFS= read -r p; do
    grep -qxF -- "$p" "$n/MANIFEST" && continue
    [ -e "$n/${p%/}" ] && continue
    bad_path "$p" && continue
    rm -rf "./${p%/}" && dropped="$dropped $p"
  done < <(manifest_paths MANIFEST)
  cp "$n/MANIFEST" ./MANIFEST && cp "$n/VERSION" ./VERSION || { echo "FAIL MANIFEST/VERSION (files replaced: $count)"; return; }
  count=$((count+2)); echo "OK replaced $count, now version $(cat VERSION)"; [ -n "$dropped" ] && echo "REMOVED$dropped"
  for p in $(grep -o '"[^"]*"' "$n/.obsidian/community-plugins.json" 2>/dev/null | tr -d '"'); do grep -q "\"$p\"" .obsidian/community-plugins.json 2>/dev/null || echo "NEW_PLUGIN $p"; done
}
update_settings() { # set cosm's own settings (.claude/scripts/settings.json) inside files the user also changes
  osascript -l JavaScript .claude/scripts/settings.js "$PWD" 2>&1 | grep -v '^$'
}
is_filler() { case "$1" in .gitkeep|.DS_Store) return 0;; esac; return 1; }
move_folder() { # $1 old, $2 new: move what an earlier version kept in $1 into $2, item by item; a clash is reported, never overwritten
  local i moved=0
  [ -d "$1" ] || return 0
  mkdir -p "$2" || { echo "FAIL could not make $2"; return 0; }
  while IFS= read -r i; do
    is_filler "$i" && continue
    if [ -e "$2/$i" ]; then echo "CONFLICT $1/$i and $2/$i both exist; not moved"; MIGRATE_OK=0; continue; fi
    if mv "$1/$i" "$2/$i"; then moved=$((moved+1)); else echo "FAIL could not move $1/$i"; MIGRATE_OK=0; fi
  done < <(ls -A "$1")
  [ -z "$(ls -A "$1" | while IFS= read -r i; do is_filler "$i" || echo x; done)" ] && rm -f "$1/.gitkeep" "$1/.DS_Store" && rmdir "$1"
  [ "$moved" -gt 0 ] && { echo "MOVED $moved item(s) from $1 to $2"; MIGRATE_MOVED=1; }
  return 0
}
update_migrate() { # bring a vault from an earlier version's layout to this one; each step checks first, so a second run does nothing
  local f n=0
  MIGRATE_MOVED=0
  # 0.5: 02-subjects -> 02-spaces, 03-references -> 03-knowledge, 04-archive/subjects -> 04-archive/spaces
  move_folder 04-archive/subjects 04-archive/spaces
  move_folder 02-subjects 02-spaces
  move_folder 03-references 03-knowledge
  if [ "$MIGRATE_MOVED" = 1 ]; then
    while IFS= read -r f; do
      sed -i '' -e 's#02-subjects/#02-spaces/#g' -e 's#03-references/#03-knowledge/#g' -e 's#04-archive/subjects#04-archive/spaces#g' "$f" && n=$((n+1))
    done < <(grep -rl --include='*.md' --exclude-dir=logs -e '02-subjects/' -e '03-references/' -e '04-archive/subjects' MAP.md profile.md 01-inbox 02-spaces 03-knowledge 04-archive 2>/dev/null)
    [ "$n" -gt 0 ] && echo "FIXED old folder paths in $n page(s)"
  fi
  return 0
}
update_finish() { # once per version: migrate, then settings; recorded in .cosm-finished when nothing failed
  [ "$(cat .cosm-finished 2>/dev/null)" = "$(version)" ] && return 0
  local out; MIGRATE_OK=1
  update_migrate
  out=$(update_settings); [ -n "$out" ] && echo "$out"
  case "$out" in *FAIL*) MIGRATE_OK=0;; esac
  [ "$MIGRATE_OK" = 1 ] && version > .cosm-finished
  return 0
}
update_cleanup() { # remove the temporary folder update-fetch made, and nothing else
  local t; t=$(printf '%s' "$1" | sed -E 's#^(.*/tmp\.[A-Za-z0-9]+)(/.*)?$#\1#')
  case "$t" in "${TMPDIR%/}"/tmp.*|/tmp/tmp.*|/private/var/folders/*/tmp.*|/var/folders/*/tmp.*) ;; *) echo "FAIL not a temporary folder: $1"; return;; esac
  case "${t##*/}" in tmp.*) rm -rf "$t" && echo "OK cleaned";; *) echo "FAIL not a temporary folder: $1";; esac
}

# In braces and ended by exit: bash reads the whole block before running it, so /update can replace this file mid-run.
{ case "$1" in
  due) due "$2" ;; recent) recent ;; unmapped) unmapped ;; inbox-count) inbox_count ;; inbox-list) inbox_list ;;
  last-review) last_review ;; newest-log) newest_log ;; log-summary) log_summary ;; pages) pages ;; toolbox) toolbox ;;
  long-pages) long_pages ;; log-headings) log_headings ;; as-of) as_of ;; stale) stale ;; notes-folders) notes_folders ;;
  dup-names) dup_names ;; broken-links) broken_links ;; stray-files) stray_files ;; oversize) oversize ;;
  logs-since-review) logs_since_review ;; open-page) open_page ;; version) version ;; source) source_url ;;
  update-fetch) update_fetch ;; update-apply) update_apply "$2" ;; update-cleanup) update_cleanup "$2" ;; update-settings) update_settings ;; update-migrate) update_migrate ;; update-finish) update_finish ;;
esac; exit 0; }

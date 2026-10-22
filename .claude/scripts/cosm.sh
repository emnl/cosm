#!/bin/bash
# Lookups for cosm's commands and hooks, plus the search index and gran. Most are read-only; the index and gran write. Run from the vault root:
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
oversize() { for f in 03-knowledge/preferences/*.md 03-knowledge/fixes/*.md; do [ "$(wc -c < "$f")" -gt 2000 ] && echo "$f"; done; [ -f profile.md ] && [ "$(wc -c < profile.md)" -gt 1500 ] && echo profile.md; }
logs_since_review() { local l; l=$(cat .cosm-last-review 2>/dev/null); l=$(date -j -v-7d -f %Y-%m-%d "${l:-2000-01-01}" +%F 2>/dev/null); find 04-archive/logs -name '* Log – *.md' 2>/dev/null | awk -F/ -v l="$l" '$NF >= l' | sort; }
open_page_path() { osascript -l JavaScript .claude/scripts/open-page.js "$PWD/.obsidian/workspace.json" 2>/dev/null; }
open_page() { local f n; f=$(open_page_path); [ -n "$f" ] && { n=${f##*/}; echo "The page open in Obsidian right now: [[${n%.md}]] ($f)"; }; }
version() { cat VERSION 2>/dev/null || echo unknown; }

# --- search ----------------------------------------------------------------------
# A BM25 index of the vault (SQLite's FTS5, built into the Mac). It is a cache rebuilt from the notes, kept outside
# the vault so cloud sync never copies it: ~/Library/Caches/cosm/<vault id>/. Deleting it loses nothing.
# pages: every page except logs, skills, preferences and fixes. logs: '* Log – *.md' files (and '<date>-<time>-log-*.md', the name before 0.4). Kept apart because a log
# mentions everything and would crowd out the pages that hold the state.
cache_dir() { local d; d="$HOME/Library/Caches/cosm/$(md5 -q -s "$PWD")"; mkdir -p "$d/shown" 2>/dev/null; echo "$d"; }
INDEX_V=2 # raise when the index is built differently
FTS_TOK="tokenize = 'unicode61 remove_diacritics 0'"
PAT_SQL="CREATE TEMP TABLE pat AS SELECT DISTINCT word, '\"' || stem || '\"' || CASE WHEN pre = 1 THEN '*' ELSE '' END AS pat FROM pin;"
index_sync() { # bring the index up to date: re-read changed files, drop deleted ones. One run at a time.
  local c; c=$(cache_dir)
  [ -n "$(find "$c/lock" -maxdepth 0 -mmin +1 2>/dev/null)" ] && rmdir "$c/lock" 2>/dev/null
  mkdir "$c/lock" 2>/dev/null || return 0
  # the index's shape or rules changed in this version: start it again
  [ "$(sqlite3 "$c/index.db" 'PRAGMA user_version;' 2>/dev/null)" = "$INDEX_V" ] || rm -f "$c/index.db"
  find 01-inbox 02-spaces 03-knowledge 04-archive -type f -name '*.md' -not -path '03-knowledge/skills/*' \
    -not -path '03-knowledge/preferences/*' -not -path '03-knowledge/fixes/*' -print0 2>/dev/null |
    xargs -0 stat -f $'%N\t%m' 2>/dev/null | grep -v -e '"' > "$c/files.tsv"
  sqlite3 "$c/index.db" >/dev/null 2>&1 <<SQL
.bail on
.timeout 5000
CREATE TABLE IF NOT EXISTS files(path TEXT PRIMARY KEY, mtime INTEGER);
CREATE VIRTUAL TABLE IF NOT EXISTS pages USING fts5(path UNINDEXED, name, lead, body, $FTS_TOK);
CREATE VIRTUAL TABLE IF NOT EXISTS logs USING fts5(path UNINDEXED, name, lead, body, $FTS_TOK);
CREATE TEMP TABLE cur(path TEXT, mtime INTEGER);
.mode tabs
.import "$c/files.tsv" cur
CREATE TEMP TABLE gone AS SELECT path FROM files f WHERE NOT EXISTS (SELECT 1 FROM cur c WHERE c.path = f.path AND c.mtime = f.mtime);
CREATE TEMP TABLE new AS SELECT c.path, c.mtime FROM cur c WHERE NOT EXISTS (SELECT 1 FROM files f WHERE f.path = c.path AND f.mtime = c.mtime);
BEGIN;
DELETE FROM pages WHERE path IN (SELECT path FROM gone);
DELETE FROM logs WHERE path IN (SELECT path FROM gone);
DELETE FROM files WHERE path IN (SELECT path FROM gone);
CREATE TEMP TABLE doc AS
  WITH a0 AS (SELECT path, mtime, CAST(readfile(path) AS TEXT) AS raw FROM new),
       a AS (SELECT path, mtime,
                    CASE WHEN raw LIKE '---' || char(10) || '%' AND instr(substr(raw, 5), char(10) || '---') > 0
                         THEN ltrim(substr(substr(raw, 5), instr(substr(raw, 5), char(10) || '---') + 4), char(10, 13, 32)) ELSE raw END AS body,
                    replace(path, rtrim(path, replace(path, '/', '')), '') AS base FROM a0),
       b AS (SELECT *, substr(base, 1, length(base) - 3) AS name,
                    ltrim(CASE WHEN body LIKE '# %' THEN substr(body, instr(body, char(10)) + 1) ELSE body END, char(10, 13, 32)) AS rest,
                    CASE WHEN instr(body, char(10) || '## Summary') > 0
                         THEN ltrim(substr(body, instr(body, char(10) || '## Summary') + 11), char(10, 13, 32)) END AS summ FROM a)
  SELECT path, mtime, name, body, (name LIKE '% Log – %' OR name GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]-log-*') AS is_log,
         CASE WHEN (name LIKE '% Log – %' OR name GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]-log-*') AND summ IS NOT NULL
              THEN substr(summ, 1, instr(summ || char(10) || '## ', char(10) || '## ') - 1)
              ELSE substr(rest, 1, instr(rest || char(10), char(10)) - 1) END AS lead FROM b;
INSERT INTO pages(path, name, lead, body) SELECT path, name, substr(trim(lead), 1, 300), body FROM doc WHERE NOT is_log;
INSERT INTO logs(path, name, lead, body) SELECT path, name, substr(trim(lead), 1, 600), body FROM doc WHERE is_log;
INSERT INTO files SELECT path, mtime FROM doc;
COMMIT;
PRAGMA user_version = $INDEX_V;
SQL
  rmdir "$c/lock" 2>/dev/null; return 0
}
index_sync_bg() { ( index_sync >/dev/null 2>&1 & ) ; }
uv_bin() { [ -x "$HOME/.local/bin/uv" ] && echo "$HOME/.local/bin/uv" && return; command -v uv 2>/dev/null; }
stem_lang() { awk '/^## Language/{f=1;next} /^## /{f=0} f && NF {print tolower($1); exit}' profile.md 2>/dev/null | tr -cd 'a-z'; }
# Words of a text, as the index splits them: one per line. $1 file holding the text.
words_of() { sqlite3 :memory: "CREATE VIRTUAL TABLE q USING fts5(x, $FTS_TOK); INSERT INTO q SELECT CAST(readfile('$1') AS TEXT);
  CREATE VIRTUAL TABLE v USING fts5vocab(q, row); SELECT term FROM v;" 2>/dev/null; }
# Search patterns for words on stdin, one "word<TAB>stem<TAB>prefix?" per line (pat_sql makes the FTS pattern): words
# under 3 letters dropped, under 4 searched whole, others as a prefix. With uv, the prefix is the word's stem in English or the profile's language, whichever is shorter.
patterns_of() {
  local uv words stems; words=$(cat); [ -z "$words" ] && return
  uv=$(uv_bin)
  if [ -n "$uv" ]; then
    stems=$(printf '%s\n' "$words" | cached_stems "$uv")
  fi
  if [ -n "$stems" ] && [ "$(printf '%s\n' "$stems" | wc -l)" = "$(printf '%s\n' "$words" | wc -l)" ]; then
    paste <(printf '%s\n' "$words") <(printf '%s\n' "$stems")
  else
    printf '%s\n' "$words" | awk '{print $0 "\t" $0}'
  fi | awk -F'\t' '{w=$1; p=$2; gsub(/"/,"",w); gsub(/"/,"",p)
    if (length(w) < 3) next; if (length(w) < 4) print w "\t" w "\t0"; else { if (length(p) < 3) p=w; print w "\t" p "\t1" } }'
}
# Stems for words on stdin, in order, one per line; the stemmer runs only for words not in the cache.
cached_stems() {
  local c lang words new out; c=$(cache_dir); lang=$(stem_lang); words=$(cat); touch "$c/stems.tsv"
  new=$(printf '%s\n' "$words" | awk -F'\t' -v l="$lang" -v f="$c/stems.tsv" 'FILENAME == f { if ($1 == l) seen[$2] = 1; next } !($0 in seen)' "$c/stems.tsv" -)
  if [ -n "$new" ]; then
    out=$(printf '%s\n' "$new" | "$1" run -q --no-project --python 3.12 --with snowballstemmer python -I -c '
import sys, snowballstemmer as s
langs = ["english"] + [l for l in sys.argv[1:] if l in s.algorithms() and l != "english"]
st = [s.stemmer(l) for l in langs]
for w in sys.stdin.read().split():
    print(w + "\t" + min((x.stemWord(w) for x in st), key=len))' $lang 2>/dev/null) || return
    [ -n "$out" ] && printf '%s\n' "$out" | awk -v l="$lang" '{print l "\t" $0}' >> "$c/stems.tsv"
  fi
  printf '%s\n' "$words" | awk -F'\t' -v l="$lang" -v f="$c/stems.tsv" 'FILENAME == f { if ($1 == l) st[$2] = $3; next } { print (($0 in st) ? st[$0] : $0) }' "$c/stems.tsv" -
}
# Glue words that never count as rare: the 300 most common words of English and of the profile's language, from the
# wordfreq package through uv. Each list is built once per Mac into the cache, in the background the first time it is
# missing; until then (or without uv) the words go unfiltered. A failed build is tried again after a day.
common_words() {
  local c l f; c=$(cache_dir)
  for l in english $(stem_lang); do
    f="$c/common-$l.txt"
    if [ -f "$f" ]; then cat "$f"
    elif [ -n "$(uv_bin)" ] && [ -z "$(find "$f.fail" -mtime -1 2>/dev/null)" ]; then ( build_common "$l" >/dev/null 2>&1 & )
    fi
  done | sort -u
}
build_common() { # $1 a language name as profile.md writes it (lowercase): english, swedish, german …
  local c f uv; c=$(cache_dir); f="$c/common-$1.txt"; uv=$(uv_bin)
  mkdir "$f.lock" 2>/dev/null || return 0
  if "$uv" run -q --no-project --python 3.12 --with wordfreq python -I -c '
import sys
from wordfreq import top_n_list, available_languages
names = {"arabic": "ar", "catalan": "ca", "czech": "cs", "danish": "da", "dutch": "nl", "english": "en", "finnish": "fi",
  "french": "fr", "german": "de", "greek": "el", "hindi": "hi", "hungarian": "hu", "icelandic": "is", "indonesian": "id",
  "italian": "it", "latvian": "lv", "lithuanian": "lt", "norwegian": "nb", "polish": "pl", "portuguese": "pt",
  "romanian": "ro", "russian": "ru", "spanish": "es", "swedish": "sv", "tamil": "ta", "turkish": "tr", "ukrainian": "uk"}
code = names.get(sys.argv[1])
words = top_n_list(code, 300) if code in available_languages() else []
print("\n".join(sorted({w.lower() for w in words if w.isalpha() and len(w) >= 3})))' "$1" > "$f.new" 2>/dev/null
  then mv "$f.new" "$f"; rm -f "$f.fail"; else rm -f "$f.new"; touch "$f.fail"; fi
  rmdir "$f.lock"
}
# Plain search for the agent: $1 table (pages or logs), the rest the words. Best 8, any match.
search() {
  local t="$1" c qf; shift; c=$(cache_dir); index_sync; qf="$c/q.txt"
  printf '%s' "$*" > "$qf"; words_of "$qf" | patterns_of > "$c/pat.tsv"; [ -s "$c/pat.tsv" ] || return
  sqlite3 "$c/index.db" 2>/dev/null <<SQL
CREATE TEMP TABLE pin(word TEXT, stem TEXT, pre INTEGER);
.mode tabs
.import "$c/pat.tsv" pin
$PAT_SQL
.mode list
.separator ""
SELECT path, ' — ', replace(lead, char(10), ' ') FROM $t WHERE $t MATCH (SELECT group_concat(pat, ' OR ') FROM pat)
ORDER BY bm25($t, 0, 10, 4, 1) LIMIT 8;
SQL
}
# The pages worth attaching to a prompt. $1 file holding the prompt, $2 file of paths already shown (skipped),
# $3 explain (any value): print why each word and page passed or failed instead.
# A page passes when the prompt names it, or when it holds at least 2 of the prompt's rare words (in under a fifth
# of all pages). At most 3; usually none.
relevant_pages() {
  local c; c=$(cache_dir); touch "$2"; common_words > "$c/common.txt"
  words_of "$1" | patterns_of > "$c/pat.tsv"
  sqlite3 "$c/index.db" 2>/dev/null <<SQL
CREATE TEMP TABLE pin(word TEXT, stem TEXT, pre INTEGER);
CREATE TEMP TABLE shown(path TEXT);
CREATE TEMP TABLE common(word TEXT PRIMARY KEY);
.mode tabs
.import "$c/pat.tsv" pin
.import "$c/common.txt" common
$PAT_SQL
.import "$2" shown
CREATE VIRTUAL TABLE temp.q USING fts5(x, $FTS_TOK);
INSERT INTO temp.q SELECT CAST(readfile('$1') AS TEXT);
CREATE TEMP TABLE n AS SELECT count(*) AS n FROM pages;
CREATE TEMP TABLE df AS SELECT word, pat, (SELECT count(*) FROM pages WHERE pages MATCH pat.pat) AS df FROM pat;
CREATE TEMP TABLE rare AS SELECT * FROM df WHERE word NOT IN (SELECT word FROM common) AND df > 0 AND (df * 5 <= (SELECT n FROM n) OR (df = 1 AND (SELECT n FROM n) < 10));
CREATE TEMP TABLE named AS SELECT path FROM pages p
  WHERE length(p.name) >= 3 AND p.name NOT IN ('todo', 'tasks')
    AND EXISTS (SELECT 1 FROM temp.q WHERE q MATCH '"' || replace(p.name, '"', '') || '"');
CREATE TEMP TABLE hits AS SELECT p.path, count(DISTINCT r.pat) AS k FROM rare r, pages p WHERE p.pages MATCH r.pat GROUP BY p.path;
CREATE TEMP TABLE ranked AS
  SELECT path, 0 AS ord, 0.0 AS score FROM named
  UNION ALL
  SELECT path, 1, bm25(pages, 0, 10, 4, 1) FROM pages
   WHERE pages MATCH coalesce((SELECT group_concat(pat, ' OR ') FROM rare), '"cosmnomatch"') AND path IN (SELECT path FROM hits WHERE k >= 2);
.mode list
.separator "\t"
.once "$c/telling.tsv"
SELECT DISTINCT p.word, p.stem, p.pre FROM pin p JOIN df ON df.word = p.word WHERE df.df * 5 <= (SELECT n FROM n);
.separator "\t"
$( if [ -n "$3" ]; then cat <<EXPLAIN
SELECT 'pages in index: ' || n FROM n;
SELECT 'word', 'pattern', 'pages', 'rare' UNION ALL SELECT word, pat, df, CASE WHEN word IN (SELECT word FROM rare) THEN 'yes' WHEN word IN (SELECT word FROM common) THEN 'no (common word)' ELSE 'no' END FROM df;
SELECT 'named in prompt: ' || path FROM named;
SELECT 'rare words held: ' || k || ' ' || path || CASE WHEN k >= 2 THEN '' ELSE '  (needs 2)' END FROM hits ORDER BY k DESC LIMIT 15;
SELECT 'already shown: ' || path FROM shown;
EXPLAIN
fi )
SELECT CASE WHEN '$3' <> '' THEN 'would attach: ' ELSE '' END || r.path, p.name, replace(p.lead, char(10), ' ')
FROM (SELECT path, min(ord) AS ord, min(score) AS score FROM ranked GROUP BY path) r JOIN pages p ON p.path = r.path
WHERE r.path NOT IN (SELECT path FROM shown) ORDER BY r.ord, r.score LIMIT 3;
SQL
}

# --- hooks -----------------------------------------------------------------------
# Claude Code sends each hook a JSON object on stdin; plutil (built into the Mac) reads its fields.
# What a hook prints for a prompt is added to the agent's context. Every hook prints nothing on any failure.
hook_in() { HOOK_IN=$(cat); }
hook_field() { printf '%s' "$HOOK_IN" | plutil -extract "$1" raw -o - - 2>/dev/null; }
session_file() { local s; s=$(hook_field session_id | tr -cd 'A-Za-z0-9-'); echo "$(cache_dir)/shown/${s:-none}"; }
prompt_context() { # each prompt: the page open in Obsidian, then pages and tables worth reading, each once per chat
  local p c sf tmp out op; hook_in; open_page
  p=$(hook_field prompt); [ "${#p}" -lt 20 ] && return
  c=$(cache_dir); [ -f "$c/index.db" ] || { index_sync_bg; return; }
 sf=$(session_file); tmp="$c/prompt.$$"; printf '%s' "$p" > "$tmp.txt"
  touch "$sf"; : > "$c/telling.tsv"
  op=$(open_page_path); { cat "$sf"; [ -n "$op" ] && echo "$op"; } > "$tmp.shown"
  out=$(relevant_pages "$tmp.txt" "$tmp.shown")
  if [ -n "$out" ]; then
    echo '<pages hint="pages that may bear on this message: read one before relying on it">'
    printf '%s\n' "$out" | awk -F'\t' '{print "- [[" $2 "]] (" $1 ")" ($3 != "" ? " — " $3 : "")}'
    echo '</pages>'
    printf '%s\n' "$out" | cut -f1 >> "$sf"
  fi
  tables_for_prompt "$tmp.txt" "$sf" "$out"
  rm -f "$tmp.txt" "$tmp.shown"; index_sync_bg
}
mark_read() { # after the agent reads a page: never attach it again in this chat
  local f; hook_in; f=$(hook_field tool_input.file_path); f=${f#"$PWD"/}
  case "$f" in *.md) echo "$f" >> "$(session_file)";; esac
}
session_start() { # a compacted chat forgets what was attached, so it may be attached again; old lists are cleared
  hook_in; [ "$(hook_field source)" = compact ] && rm -f "$(session_file)"
  find "$(cache_dir)/shown" -type f -mtime +7 -delete 2>/dev/null
}
# A failed tool call: the fix lines in 03-knowledge/fixes/ that share at least 2 telling words with the error
# (words in under half the lines). At most 2, each once per chat. Printed as the hook's JSON answer.
error_context() {
  local c sf tmp; hook_in; c=$(cache_dir); sf=$(session_file); tmp="$c/error.$$"
  set -- 03-knowledge/fixes/*.md; [ -e "$1" ] || { fix_reminder; return; }
  grep -H -E '^- ' "$@" 2>/dev/null | awk '{i=index($0,":"); print substr($0,1,i-1) "\t" substr($0,i+1)}' | tr -d '"' > "$tmp.lines"
  [ -s "$tmp.lines" ] || { rm -f "$tmp.lines"; fix_reminder; return; }
  { hook_field tool_name; echo; hook_field error; } | sed -E 's#[^[:space:]]*/[^[:space:]]*# #g; s/[0-9]+/ /g' > "$tmp.txt"
  words_of "$tmp.txt" | patterns_of > "$tmp.pat"; touch "$sf"
  local found; found=$(sqlite3 :memory: 2>/dev/null <<SQL
CREATE VIRTUAL TABLE fx USING fts5(file UNINDEXED, line, $FTS_TOK);
CREATE TEMP TABLE raw(file TEXT, line TEXT); CREATE TEMP TABLE pin(word TEXT, stem TEXT, pre INTEGER); CREATE TEMP TABLE shown(key TEXT);
.mode tabs
.import "$tmp.lines" raw
.import "$tmp.pat" pin
$PAT_SQL
.import "$sf" shown
INSERT INTO fx SELECT file, line FROM raw;
CREATE TEMP TABLE good AS SELECT pat FROM pat WHERE (SELECT count(*) FROM fx WHERE fx MATCH pat.pat) BETWEEN 1 AND max(1, (SELECT count(*) FROM fx) / 2);
CREATE TEMP TABLE hit AS SELECT f.rowid AS id, count(*) AS k FROM good g, fx f WHERE f.fx MATCH g.pat GROUP BY f.rowid HAVING k >= 2;
CREATE TEMP TABLE pick AS SELECT file, line FROM fx WHERE rowid IN (SELECT id FROM hit)
  AND 'fix:' || file || ':' || line NOT IN (SELECT key FROM shown) ORDER BY (SELECT k FROM hit WHERE id = fx.rowid) DESC LIMIT 2;
.mode list
.once "$tmp.new"
SELECT 'fix:' || file || ':' || line FROM pick;
.once stdout
SELECT json_object('hookSpecificOutput', json_object('hookEventName', 'PostToolUseFailure', 'additionalContext',
  'Known fixes that may apply (from 03-knowledge/fixes/):' || char(10) || group_concat(line || ' (' || file || ')', char(10))))
FROM pick HAVING count(*) > 0;
SQL
)
  if [ -n "$found" ]; then echo "$found"; else fix_reminder; fi
  cat "$tmp.new" >> "$sf" 2>/dev/null; rm -f "$tmp.lines" "$tmp.txt" "$tmp.pat" "$tmp.new"
}
fix_reminder() { # a failure with no known fix: remind the agent once per chat to write the fix when it finds one
  local sf; sf=$(session_file); grep -qx 'fix-reminder' "$sf" 2>/dev/null && return; echo 'fix-reminder' >> "$sf"
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PostToolUseFailure","additionalContext":"No known fix for this failure. When another way works and the failure would recur, write it to 03-knowledge/fixes/<tool>.md before moving on (AGENTS.md, Learning)."}}'
}
# --- gran ------------------------------------------------------------------------
# gran, the user's tables: one SQLite database in the vault, .cosm/gran.db (data, so it syncs with the vault, unlike the
# search cache). table_docs describes every table and column: a table's row has col '' and holds "Grain: one row per
# …" and "Scope: [[Page]]" (the page that names the table in one line) and "Queries: …" (words someone asking
# about it would use). After every write each table is exported to .cosm/gran/<table>.csv: a copy the user can open, and the way back if the database breaks.
TDB=.cosm/gran.db
TDOCS="CREATE TABLE IF NOT EXISTS table_docs(tbl TEXT NOT NULL, col TEXT NOT NULL DEFAULT '', doc TEXT NOT NULL, PRIMARY KEY (tbl, col));"
user_tables() { [ -f "$TDB" ] && sqlite3 -readonly "$TDB" "SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'tmp\_%' ESCAPE '\' AND name <> 'table_docs' ORDER BY name;" 2>/dev/null; }
table_list() { [ -f "$TDB" ] || { echo "No tables yet."; return; }
  sqlite3 -readonly "$TDB" "SELECT 'Scratch: ' || group_concat(name, ', ') FROM sqlite_master WHERE type = 'table' AND name LIKE 'tmp\_%' ESCAPE '\\' HAVING count(*) > 0;" 2>/dev/null
  sqlite3 -readonly -separator ' — ' "$TDB" "SELECT m.name, coalesce(replace(d.doc, char(10), ' · '), 'NO DESCRIPTION') FROM sqlite_master m LEFT JOIN table_docs d ON d.tbl = m.name AND d.col = ''
    WHERE m.type IN ('table','view') AND m.name NOT LIKE 'sqlite_%' AND m.name <> 'table_docs' AND m.name NOT LIKE 'tmp\_%' ESCAPE '\' ORDER BY m.name;" 2>/dev/null; }
table_describe() { [ -f "$TDB" ] || { echo "No tables yet."; return; }
  local t; t=$(printf '%s' "$1" | tr -cd 'A-Za-z0-9_')
  sqlite3 -readonly "$TDB" "SELECT coalesce((SELECT doc FROM table_docs WHERE tbl = '$t' AND col = ''), 'NO DESCRIPTION for $t');
    SELECT '- ' || c.name || ' (' || coalesce(nullif(c.type, ''), 'any') || CASE WHEN c.pk > 0 THEN ', key' ELSE '' END || ')' || ' — ' || coalesce(d.doc, 'NO DESCRIPTION')
    FROM pragma_table_info('$t') c LEFT JOIN table_docs d ON d.tbl = '$t' AND d.col = c.name ORDER BY c.cid;" 2>&1; }
table_query() { [ -f "$TDB" ] || { echo "No tables yet."; return; }
  local f n; f=$(mktemp); sqlite3 -readonly -bail -markdown "$TDB" "$1" > "$f" 2>&1; n=$(wc -l < "$f" | tr -d ' ')
  head -202 "$f"; [ "$n" -gt 202 ] && echo "(cut: $((n - 2)) rows, only the first 200 shown; count and sum in SQL instead of reading rows)"; rm -f "$f"; }
table_exec() { # one or more SQL statements, all or nothing; then the copies and the check
  local out; mkdir -p .cosm
  out=$(sqlite3 -bail "$TDB" "$TDOCS PRAGMA foreign_keys = ON; BEGIN; $1; COMMIT;" 2>&1) || { echo "FAIL nothing written: $out"; return; }
  [ -n "$out" ] && echo "$out"
  gran_after
}
table_import() { # $1 an existing table, $2 a CSV file whose header row names its columns
  local t cols sel out; mkdir -p .cosm; t=$(printf '%s' "$1" | tr -cd 'A-Za-z0-9_')
  [ -f "$2" ] || { echo "FAIL no file $2"; return; }
  case "$t" in tmp_*) [ -f "$TDB" ] || sqlite3 "$TDB" "$TDOCS";
    sqlite3 -readonly "$TDB" "SELECT 1 FROM sqlite_master WHERE name = '$t';" 2>/dev/null | grep -q 1 || {
      out=$(sqlite3 -bail "$TDB" ".import --csv \"$2\" $t" 2>&1) || { echo "FAIL nothing written: $out"; return; }
      echo "IMPORTED $(sqlite3 -readonly "$TDB" "SELECT count(*) FROM $t;") rows into new scratch table $t (all columns text)"; return; } ;;
    *) user_tables | grep -qxF "$t" || { echo "FAIL no table $t (make it with gran-exec first)"; return; } ;;
  esac
  cols=$(head -1 "$2" | tr -d '\r"' | tr -cd 'A-Za-z0-9_,'); sel=$(printf '%s' "$cols" | sed -E "s/([A-Za-z0-9_]+)/nullif(\1, '')/g")
  out=$(sqlite3 -bail "$TDB" 2>&1 <<SQL
DROP TABLE IF EXISTS gran_import_tmp;
.import --csv "$2" gran_import_tmp
BEGIN;
INSERT INTO "$t" ($cols) SELECT $sel FROM gran_import_tmp;
SELECT 'IMPORTED ' || changes() || ' rows into $t';
DROP TABLE gran_import_tmp;
COMMIT;
SQL
) || { sqlite3 "$TDB" "DROP TABLE IF EXISTS gran_import_tmp;" 2>/dev/null; echo "FAIL nothing written: $out"; return; }
  echo "$out"; gran_after
}
gran_after() { # after a write: refresh the copies, move a dropped table's copy to .trash/, check every table is described
  local t f; mkdir -p .cosm/gran
  for f in .cosm/gran/*.csv; do t=${f##*/}; t=${t%.csv}; [ "$t" = table_docs ] && continue
    user_tables | grep -qxF "$t" || { mkdir -p .trash && mv "$f" ".trash/$t $(date +%Y-%m-%d).csv" && echo "REMOVED table $t (its last export is in .trash/)"; }; done
  sqlite3 -readonly "$TDB" "SELECT 'MISSING DESCRIPTION table ' || m.name FROM sqlite_master m WHERE m.type IN ('table','view') AND m.name NOT LIKE 'sqlite_%' AND m.name <> 'table_docs' AND m.name NOT LIKE 'tmp\_%' ESCAPE '\'
      AND NOT EXISTS (SELECT 1 FROM table_docs d WHERE d.tbl = m.name AND d.col = '' AND d.doc LIKE '%Grain:%' AND d.doc LIKE '%Scope:%');
    SELECT 'NO KEY table ' || m.name FROM sqlite_master m WHERE m.type = 'table' AND m.name NOT LIKE 'sqlite_%' AND m.name <> 'table_docs' AND m.name NOT LIKE 'tmp\_%' ESCAPE '\'
      AND NOT EXISTS (SELECT 1 FROM pragma_table_info(m.name) c WHERE c.pk > 0);
    SELECT 'NO SOURCE COLUMN table ' || m.name FROM sqlite_master m WHERE m.type = 'table' AND m.name NOT LIKE 'sqlite_%' AND m.name <> 'table_docs' AND m.name NOT LIKE 'tmp\_%' ESCAPE '\'
      AND NOT EXISTS (SELECT 1 FROM pragma_table_info(m.name) c WHERE c.name = 'source');
    SELECT 'MISSING DESCRIPTION column ' || m.name || '.' || c.name FROM sqlite_master m, pragma_table_info(m.name) c
      WHERE m.type = 'table' AND m.name NOT LIKE 'sqlite_%' AND m.name <> 'table_docs' AND m.name NOT LIKE 'tmp\_%' ESCAPE '\' AND NOT EXISTS (SELECT 1 FROM table_docs d WHERE d.tbl = m.name AND d.col = c.name);
    SELECT 'NOT STRICT table ' || m.name FROM sqlite_master m WHERE m.type = 'table' AND m.name NOT LIKE 'sqlite_%' AND m.name <> 'table_docs' AND m.name NOT LIKE 'tmp\_%' ESCAPE '\'
      AND NOT EXISTS (SELECT 1 FROM pragma_table_list WHERE name = m.name AND strict = 1);" 2>/dev/null > .cosm/check.txt
  if [ -s .cosm/check.txt ]; then cat .cosm/check.txt; echo "WRITTEN, but fix the lines above in this session (gran skill, Making a table)"; else echo "OK"; fi; rm -f .cosm/check.txt
  ( gran_copies >/dev/null 2>&1 & )
}
gran_copies() { # a CSV copy of every table, each written whole before it replaces the old one
  local t
  for t in $(user_tables); do sqlite3 -readonly -header -csv "$TDB" "SELECT * FROM \"$t\";" > ".cosm/gran/$t.csv.new" && mv ".cosm/gran/$t.csv.new" ".cosm/gran/$t.csv"; done
  sqlite3 -readonly -header -csv "$TDB" "SELECT * FROM table_docs ORDER BY tbl, col;" > .cosm/gran/table_docs.csv.new && mv .cosm/gran/table_docs.csv.new .cosm/gran/table_docs.csv
}
# Tables for a prompt, once per chat each, at most 3: one the prompt names ("expenses", "pc cash" for pc_cash), one
# whose Scope page was attached for this prompt, or one whose description (with its Queries line and column docs)
# holds at least 2 of the prompt's telling words (in under a fifth of the vault's pages, or in none).
# $1 prompt file, $2 the chat's shown file, $3 the pages just attached; relevant_pages left the telling words in telling.tsv.
tables_for_prompt() {
  [ -f "$TDB" ] || return; local out
  printf '%s\n' "$3" | cut -f1 | sed '/^$/d' | while IFS= read -r p; do n=${p##*/}; echo "${n%.md}"; done > "$2.pages"
  out=$(sqlite3 -readonly "$TDB" 2>/dev/null <<SQL
CREATE TEMP TABLE shown(key TEXT); CREATE TEMP TABLE att(name TEXT); CREATE TEMP TABLE pin(word TEXT, stem TEXT, pre INTEGER);
.mode tabs
.import "$2" shown
.import "$2.pages" att
.import "$(cache_dir)/telling.tsv" pin
$PAT_SQL
CREATE TEMP TABLE tell AS SELECT pat FROM pat;
CREATE VIRTUAL TABLE temp.td USING fts5(name, doc, $FTS_TOK);
INSERT INTO temp.td SELECT m.name, (SELECT group_concat(doc, ' ') FROM table_docs WHERE tbl = m.name) FROM sqlite_master m
  WHERE m.type IN ('table','view') AND m.name NOT LIKE 'sqlite_%' AND m.name <> 'table_docs' AND m.name NOT LIKE 'tmp\_%' ESCAPE '\';
CREATE TEMP TABLE about AS SELECT t.name FROM tell, temp.td t WHERE t.td MATCH tell.pat GROUP BY t.name HAVING count(DISTINCT tell.pat) >= 2;
CREATE VIRTUAL TABLE temp.q USING fts5(x, $FTS_TOK);
INSERT INTO temp.q SELECT CAST(readfile('$1') AS TEXT);
.mode list
.separator "\t"
SELECT m.name, replace(coalesce(d.doc, ''), char(10), ' · '),
       (SELECT group_concat(c.name, ', ') FROM pragma_table_info(m.name) c)
FROM sqlite_master m LEFT JOIN table_docs d ON d.tbl = m.name AND d.col = ''
WHERE m.type IN ('table','view') AND m.name NOT LIKE 'sqlite_%' AND m.name <> 'table_docs' AND m.name NOT LIKE 'tmp\_%' ESCAPE '\'
  AND 'table:' || m.name NOT IN (SELECT key FROM shown)
  AND (EXISTS (SELECT 1 FROM temp.q WHERE q MATCH '"' || replace(m.name, '_', ' ') || '"')
       OR EXISTS (SELECT 1 FROM att WHERE d.doc LIKE '%Scope: [[' || att.name || ']]%')
       OR m.name IN (SELECT name FROM about))
LIMIT 3;
SQL
)
  rm -f "$2.pages"; [ -n "$out" ] || return
  echo '<tables hint="gran tables that may bear on this message: gran-describe one before relying on it (gran skill)">'
  printf '%s\n' "$out" | awk -F'\t' '{print "- " $1 " — " $2 " (columns: " $3 ")"}'
  echo '</tables>'
  printf '%s\n' "$out" | cut -f1 | sed 's/^/table:/' >> "$2"
}
fixes() { local f; for f in "$@"; do [ -f "03-knowledge/fixes/$f.md" ] && grep -E '^- ' "03-knowledge/fixes/$f.md"; done; }
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
  # 0.7.1: the fixes folder, and its line in MAP.md below the preferences line
  [ -d 03-knowledge/fixes ] || { mkdir -p 03-knowledge/fixes && echo "ADDED folder 03-knowledge/fixes/"; }
  if [ -f MAP.md ] && ! grep -qF '03-knowledge/fixes/' MAP.md; then
    awk '{print} /^- 03-knowledge\/preferences\// && !d {print "- 03-knowledge/fixes/ — what works when a tool failed (each listed below it)"; d=1}
      END {if (!d) print "- 03-knowledge/fixes/ — what works when a tool failed (each listed below it)"}' MAP.md > MAP.md.new && mv MAP.md.new MAP.md && echo "ADDED 03-knowledge/fixes/ to MAP.md"
  fi
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
  logs-since-review) logs_since_review ;; open-page) open_page ;;
  search) shift; search pages "$@" ;; search-logs) shift; search logs "$@" ;; fixes) shift; fixes "$@" ;;
  index-sync) index_sync ;; search-explain) shift; index_sync; { t="$(cache_dir)/explain.$$"; printf '%s' "$*" > "$t"; relevant_pages "$t" /dev/null x; rm -f "$t"; } ;;
  gran-list) table_list ;; gran-describe) table_describe "$2" ;; gran-query) table_query "$2" ;; gran-exec) table_exec "$2" ;; gran-import) table_import "$2" "$3" ;;
  prompt-context) prompt_context ;; mark-read) mark_read ;; session-start) session_start ;; error-context) error_context ;; version) version ;; source) source_url ;;
  update-fetch) update_fetch ;; update-apply) update_apply "$2" ;; update-cleanup) update_cleanup "$2" ;; update-settings) update_settings ;; update-migrate) update_migrate ;; update-finish) update_finish ;;
esac; exit 0; }

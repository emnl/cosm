#!/bin/bash
# Runs every cosm.sh lookup on an empty copy of this repo and on one with planted content, with the Mac's own bash.
# Usage, from the repo root: bash .github/lookups-test.sh
# Read the output: on the empty vault every lookup prints nothing (version and source excepted); on the planted
# vault each check finds its planted case. Every rc must be 0.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d)
LOOKUPS="due recent unmapped inbox-count inbox-list last-review newest-log log-summary pages long-pages log-headings as-of stale notes-folders dup-names broken-links stray-files oversize logs-since-review version source fixes gran-list"

run_all() {
  for l in $LOOKUPS; do
    out=$(perl -e 'alarm 8; exec @ARGV' /bin/bash .claude/scripts/cosm.sh "$l" 3 2>&1 </dev/null); rc=$?
    echo "[$l rc=$rc] $(printf '%s' "$out" | head -4 | tr '\n' '|')"
  done
}

for v in empty planted; do rsync -a --exclude .git "$REPO/" "$T/$v/"; done

cd "$T/planted"
mkdir -p "02-spaces/Acme supply deal/notes/sub" "03-knowledge/people/Anna Berg" "04-archive/logs/2026-10"
printf '# Acme\n*As of 2026-10-01.*\n- [ ] Send price [[Anna Berg|Anna]] 📅 2026-10-20\n## 2026-10-02 call\n[[Nobody Here]]\n' > "02-spaces/Acme supply deal/Acme supply deal.md"
printf 'x\n' > "02-spaces/Acme supply deal/notes/2026-10-21 Acme – kickoff.md"
printf '# Anna\n' > "03-knowledge/people/Anna Berg/Anna Berg.md"
seq 1 70 > "03-knowledge/people/Anna Berg/Long.md"
touch "02-spaces/Acme supply deal/stray.pdf"
head -c 2500 /dev/zero | tr '\0' a > 03-knowledge/preferences/email.md
printf '## Summary\nold\n' > "04-archive/logs/2026-10/2026-10-21 21.51 Log – Test.md"
mkdir -p "02-spaces/Mapped by name" && printf -- '  - Mapped by name/ — indented line\n' >> MAP.md

echo "== empty"; (cd "$T/empty" && run_all)
echo "== planted (expect: due, recent, unmapped = Acme only, long-pages, log-headings, as-of, notes-folders, broken-links, stray-files, oversize, logs)"; run_all
rm -rf "$T"

#!/bin/bash
# Updates a vault made from an earlier release to this working tree, the way /update does, and checks the result.
# Usage, from the repo root: bash .github/update-test.sh [old-commit]
#   old-commit: a commit of an earlier release (default: the commit before the newest VERSION change).
#   0574524 is 0.4.1, the last release on the old folder names (02-subjects, 03-references).
# It plants user content and the user's own settings, a name clash and a Finder .DS_Store, then runs the OLD
# cosm.sh update-apply and the NEW update-finish three times (clash, resolved, silent). Needs jq.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd)
OLD=${1:-$(git -C "$REPO" log -2 --format=%h -- VERSION | tail -1)}
T=$(mktemp -d); V="$T/vault"; mkdir "$V"
git -C "$REPO" archive "$OLD" | tar -x -C "$V"
cd "$V"
echo "old version: $(cat VERSION) ($OLD)"

# The user's content, in whichever layout this version has.
S=$( [ -d 02-subjects ] && echo 02-subjects || echo 02-spaces ); K=$( [ -d 03-references ] && echo 03-references || echo 03-knowledge )
mkdir -p "$S/Acme supply deal/notes" "$S/Me" "$K/people/Anna Berg"
printf '# Acme\n- [[Anna Berg]]\n' > "$S/Acme supply deal/Acme supply deal.md"
printf '# Me\n' > "$S/Me/Me.md"; printf -- '- [ ] Ring Anna\n' > "$S/Me/todo.md"
printf '# Anna Berg\n' > "$K/people/Anna Berg/Anna Berg.md"
printf -- '  - Acme supply deal/ — signing Nov\n- %s/Me/ — mine\n' "$S" >> MAP.md
# The user's own settings, which an update must keep.
jq '. + {spellcheck:false}' .obsidian/app.json > x && mv x .obsidian/app.json
jq '.permissions.allow += ["Bash(ls:*)"] | .hooks.Stop = [{"hooks":[{"type":"command","command":"echo hi"}]}]' .claude/settings.local.json > x && mv x .claude/settings.local.json
jq '.model="sonnet"' .claudian/claudian-settings.json > x && mv x .claudian/claudian-settings.json
jq '.homepages.Mobile = {"value":"X"}' .obsidian/plugins/homepage/data.json > x && mv x .obsidian/plugins/homepage/data.json
# A clash: the agent already made the new folder for one item; Finder left a .DS_Store.
if [ "$S" = 02-subjects ]; then mkdir -p "02-spaces/Me" && echo new > "02-spaces/Me/new.md" && touch 02-spaces/.DS_Store; fi

N=$(mktemp -d)/new; mkdir -p "$N"; rsync -a --exclude .git "$REPO/" "$N/"
echo "== old update-apply"; /bin/bash .claude/scripts/cosm.sh update-apply "$N" </dev/null 2>/dev/null | head -3
echo "== finish 1"; /bin/bash .claude/scripts/cosm.sh update-finish </dev/null
if [ -d 02-subjects/Me ]; then echo "== resolving the clash by hand"; mv 02-subjects/Me/* 02-spaces/Me/; rmdir 02-subjects/Me; fi
echo "== finish 2"; /bin/bash .claude/scripts/cosm.sh update-finish </dev/null
echo "== finish 3 (must print nothing)"; /bin/bash .claude/scripts/cosm.sh update-finish </dev/null

echo "== checks"
fail=0; check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
check "version is the new one" '[ "$(cat VERSION)" = "$(cat "$REPO/VERSION")" ] && [ "$(cat .cosm-finished)" = "$(cat VERSION)" ]'
check "old folders gone" '[ ! -e 02-subjects ] && [ ! -e 03-references ] && [ ! -e 04-archive/subjects ]'
check "notes moved" '[ -f "02-spaces/Acme supply deal/Acme supply deal.md" ] && [ -f "03-knowledge/people/Anna Berg/Anna Berg.md" ] && [ -f 02-spaces/Me/todo.md ] && { [ "$S" = 02-spaces ] || [ -f 02-spaces/Me/new.md ]; }'
check "MAP paths fixed" '! grep -q "02-subjects/" MAP.md'
check "user settings kept" '[ "$(jq -r .spellcheck .obsidian/app.json)" = false ] && [ "$(jq -r .model .claudian/claudian-settings.json)" = sonnet ] && jq -e ".homepages.Mobile" .obsidian/plugins/homepage/data.json >/dev/null && jq -e ".hooks.Stop" .claude/settings.local.json >/dev/null && jq -e ".permissions.allow|index(\"Bash(ls:*)\")" .claude/settings.local.json >/dev/null'
check "cosm settings in place" '[ "$(jq -r .mediaFolder .claudian/claudian-settings.json)" = 01-inbox ] && [ "$(jq -r .attachmentFolderPath .obsidian/app.json)" = 01-inbox ]'
check "system files match the release" 'grep -v -e "^#" -e "^[[:space:]]*$" MANIFEST | while read -r f; do diff -rq "$N/${f%/}" "./${f%/}" >/dev/null || { echo "  differs: $f"; exit 1; }; done'
/bin/bash .claude/scripts/cosm.sh update-cleanup "$N" >/dev/null 2>&1
rm -rf "$T" "$(dirname "$N")"
[ "$fail" = 0 ] && echo "PASS" || echo "FAILED"

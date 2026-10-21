# Releasing and testing cosm

For whoever works on cosm itself. Kept in `.github/`, which Obsidian ignores, and not listed in `MANIFEST`, so `/update` never copies it. The design and every decision behind it are in the author's notes (microcosm: `03-areas/kosmos/notes/cosm-sketch.md`).

## Before a release

1. **Lookups.** Every `!` line in a command or skill calls `bash .claude/scripts/cosm.sh <lookup>` (or a plain `date` / `cat`). Compound shell in a `!` line doesn't run on its own: Claude Code leaves an "[output of command …]" placeholder the agent then runs in view. Variables in `!` lines are refused.
2. **Test the script with the Mac's own tools**, never an interactive zsh with your own aliases (a `grep` that is really `ugrep` hides bugs a colleague will hit):
   - `cd <scratch vault> && /bin/bash .claude/scripts/cosm.sh <lookup> [arg]` for every lookup, quoting the arguments
   - on an empty vault (nothing printed, exit 0), and on a planted one: names with spaces and an en dash, a dated note name, a link with an alias, a stale *As of*, a long page, a broken link, a stray file, an old and a new log
3. **Files.** Every line in `MANIFEST` exists (`grep -v '^#' MANIFEST | while read -r f; do [ -e "$f" ] || echo "MISSING $f"; done`). User files (anything the user can change: `appearance.json`, `community-plugins.json`, Style Settings' `data.json`, notes) are never listed.
4. **Shipped `settings.local.json`** is in git explicitly (`git add -f`); a global git ignore may exclude it. It carries the allow rules and the active-page hook, which a project's `settings.json` can't (Claude Code ignores its allow rules until the folder is trusted, and Claudian doesn't mark it trusted).
5. **Prompt review.** A changed command, skill or `AGENTS.md` goes through a reviewer before release; a second look at a rewrite goes to the same reviewer, not a fresh one.

## Release

1. Bump `VERSION`; add a `CHANGES.md` entry in the user's words (what they'll notice, not how it was built).
2. Commit, `git push origin main`, check `curl -fsSL https://raw.githubusercontent.com/emnl/cosm/main/VERSION`.

## New-user test

1. `git archive --format=zip --prefix=cosm-main/ -o ~/Downloads/cosm-main-<version>.zip HEAD`.
2. The tester follows only the README into a fresh folder: unzip, open as vault, trust, close Settings, `/setup`, then email, a meeting note and a non-markdown file through `/inbox`, `/reflect`, `/log`, and `/recall` in a new chat.
3. Read the sessions afterwards from `~/.claude/projects/-<vault path with / as ->/*.jsonl`:
   - lookup placeholders: `jq -r 'select(.type=="user") | .message.content | if type=="string" then . else (.[]?|.text? // empty) end' <file> | grep -c 'output of command'` (must be 0)
   - the agent's own tool calls: `jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | .name' <file>`
   - errors: `jq -r 'select(.type=="user") | .message.content[]? | select(.type=="tool_result") | select(.is_error==true) | (.content|tostring)[0:300]' <file>`
4. Screenshots the tester takes land on their Desktop; read them from there.

## Update test

In a vault on the previous version, a new chat, the words "update cosm". Afterwards compare every file in `MANIFEST` with the release (`git show <commit>:<path> | cmp -s - <vault>/<path>`) and check the user's notes, theme, light/dark and plugin list are as they were.

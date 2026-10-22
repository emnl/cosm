# Releasing and testing cosm

For whoever works on cosm itself. Kept in `.github/`, which Obsidian ignores, and not listed in `MANIFEST`, so `/update` never copies it. The design and every decision behind it are in the author's notes (microcosm: `03-areas/kosmos/notes/cosm-sketch.md`).

## Before a release

1. **Lookups.** Every `!` line in a command or skill calls `bash .claude/scripts/cosm.sh <lookup>` (or a plain `date` / `cat`). Compound shell in a `!` line doesn't run on its own: Claude Code leaves an "[output of command …]" placeholder the agent then runs in view. Variables in `!` lines are refused.
2. **Test the script with the Mac's own tools** (`bash .github/lookups-test.sh` does the run below), never an interactive zsh with your own aliases (a `grep` that is really `ugrep` hides bugs a colleague will hit):
   - `cd <scratch vault> && /bin/bash .claude/scripts/cosm.sh <lookup> [arg]` for every lookup, quoting the arguments
   - on an empty vault (nothing printed, exit 0), and on a planted one: names with spaces and an en dash, a dated note name, a link with an alias, a stale *As of*, a long page, a broken link, a stray file, an old and a new log
3. **Files.** Every line in `MANIFEST` exists (`grep -v '^#' MANIFEST | while read -r f; do [ -e "$f" ] || echo "MISSING $f"; done`). User files (anything the user can change: `appearance.json`, `community-plugins.json`, Style Settings' `data.json`, notes) are never listed.
4. **Settings and migrations.** A release copy needs no finishing: `rsync -a --exclude .git ./ <scratch>/ && cd <scratch> && /bin/bash .claude/scripts/cosm.sh update-finish` prints nothing. If it prints `SET`, `.claude/scripts/settings.json` and the shipped file disagree; fix one. A change to the folder layout gets a step in `update_migrate` (check first, so a second run does nothing), tested by updating a copy of a vault on the previous version: `bash .github/update-test.sh [old-commit]` (0574524 is 0.4.1, the last on the old folder names) must end in PASS.
5. **Shipped `settings.local.json`** is in git explicitly (`git add -f`); a global git ignore may exclude it. It carries the allow rules and the active-page hook, which a project's `settings.json` can't (Claude Code ignores its allow rules until the folder is trusted, and Claudian doesn't mark it trusted).
6. **Prompt review.** A changed command, skill or `AGENTS.md` goes through a reviewer before release; a second look at a rewrite goes to the same reviewer, not a fresh one.

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

## Live check

After a release that changes what the agent does, in the test vault (`~/Downloads/cosm-main-2`), each in a new chat unless said otherwise, after "update cosm" and a restart of Obsidian (⌘Q) so the cosm plugin reloads:

1. **Update:** "update cosm" reports the new version and any migration lines; the user's notes, `MAP.md` entries and preferences stay where they were.
2. **Pages attached:** a question about a page that exists (the Keeper payout date) gets that page in `<pages>` and is answered from it; ask the agent to list what came attached.
3. **gran read:** "what tables do i have?" loads the gran skill (a skill row, not Bash), reads the gran preference and answers in one step.
4. **gran write:** "add 9 Oct Uber 312 kr travel from the October statement" shows "gran · Writing to a table", ends `OK`, asks nothing.
5. **gran yes-rule:** "delete the <named> row" just does it; "clean up the table" proposes and waits for ==y==.
6. **Narrow table:** a table answer in a narrow chat scrolls sideways, columns intact.
7. **Failure:** `ls "01-inbox/no such folder"` comes back with the fix reminder (or a matching fix line), once per chat.

Read the sessions afterwards as in New-user test step 3. Anything that doesn't match is a fix before the next release.

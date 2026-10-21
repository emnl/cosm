---
description: Get the newest version of cosm — replaces cosm's own files, never your notes
---
# /update

This vault: version !`bash .claude/scripts/cosm.sh version`. Source: !`bash .claude/scripts/cosm.sh source`

Every step goes through `bash .claude/scripts/cosm.sh`; never copy, move or remove files by hand during an update (one exception: a `CONFLICT`, below). Write out the folder path a step prints in full in the next step.

## 1. Fetch

Run `bash .claude/scripts/cosm.sh update-fetch`. It prints `NEW=<folder>` and `VERSION=<x>`, or `FAIL …`. On `FAIL`, say the new version couldn't be downloaded (quote the reason) and stop: nothing has changed.

If the new version equals this vault's, say "cosm is up to date (version X)", run `bash .claude/scripts/cosm.sh update-cleanup <folder>`, and stop.

## 2. Show what's new

Read `<folder>/CHANGES.md` and show the entries for every version newer than this vault's. Then ask: "Update from X to Y? Your notes, `profile.md`, `MAP.md`, your preferences, your own skills and your Obsidian choices (light or dark, theme, plugins you turned on) are not touched, except that folders an earlier version named differently are renamed and the paths to them fixed. ==y== yes · ==n== no". If a `CHANGES.md` entry says it must change one of those Obsidian files, say so and ask for it separately. On ==n==, clean up and stop.

## 3. Replace

Run `bash .claude/scripts/cosm.sh update-apply <folder>`. It checks both file lists, replaces exactly the files in the new `MANIFEST` (`MANIFEST` and `VERSION` last), removes files a new version dropped, and prints `OK replaced <n>, now version <x>`, `REMOVED …`, `NEW_PLUGIN <id>`, or `FAIL …`.

- On `FAIL`, say what it says and that the vault is still on the old version where `VERSION` says so; run `bash .claude/scripts/cosm.sh update-cleanup <folder>` and stop. `/update` can be run again to finish.
- A `syntax error` line after `OK` is expected when updating from 0.5 or earlier (the old helper replaced itself while running); it is not a failure. Don't mention it.
- For each `NEW_PLUGIN`, ask: "Turn on <plugin>, which comes with this version? ==y== yes · ==n== no". On ==y==, add its id to `.obsidian/community-plugins.json`, keeping the user's own entries. Never remove one.

Then run `bash .claude/scripts/cosm.sh update-finish`, which runs the new version's own steps: it moves folders an earlier version named differently and fixes those paths in pages (`MOVED …`, `FIXED …`), and sets cosm's own settings inside files the user also changes, such as the chat's and Obsidian's settings, leaving the user's other settings alone (`SET <file>: <keys>`). It prints nothing more when all is in place, and may also print `SKIP …` or `FAIL …`: quote those as they are. On `CONFLICT`, an item exists under both the old and the new folder name: show both, propose how to combine them (say which file or folder goes where) and move them on ==y==; this is the one case where files are moved by hand during an update. Then run `bash .claude/scripts/cosm.sh update-finish` again.

Then run `bash .claude/scripts/cosm.sh update-cleanup <folder>`.

## 4. Report

Say the vault is now on version Y, what was removed if anything, which folders were moved and settings set, if any, and that the user's notes weren't otherwise touched. Then: "Quit Obsidian and open it again now to finish."

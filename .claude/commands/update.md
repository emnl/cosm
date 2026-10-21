---
description: Get the newest version of cosm — replaces cosm's own files, never your notes
---
# /update

This vault: version !`bash .claude/scripts/cosm.sh version`. Source: !`bash .claude/scripts/cosm.sh source`

Every step goes through `bash .claude/scripts/cosm.sh`; never copy, move or remove files by hand during an update. Write out the folder path a step prints in full in the next step.

## 1. Fetch

Run `bash .claude/scripts/cosm.sh update-fetch`. It prints `NEW=<folder>` and `VERSION=<x>`, or `FAIL …`. On `FAIL`, say the new version couldn't be downloaded (quote the reason) and stop: nothing has changed.

If the new version equals this vault's, say "cosm is up to date (version X)", run `bash .claude/scripts/cosm.sh update-cleanup <folder>`, and stop.

## 2. Show what's new

Read `<folder>/CHANGES.md` and show the entries for every version newer than this vault's. Then ask: "Update from X to Y? Your notes, `profile.md`, `MAP.md`, your preferences, your own skills and your Obsidian choices (light or dark, theme, plugins you turned on) are not touched. ==y== yes · ==n== no". If a `CHANGES.md` entry says it must change one of those Obsidian files, say so and ask for it separately. On ==n==, clean up and stop.

## 3. Replace

Run `bash .claude/scripts/cosm.sh update-apply <folder>`. It checks both file lists, replaces exactly the files in the new `MANIFEST` (`MANIFEST` and `VERSION` last), removes files a new version dropped, and prints `OK replaced <n>, now version <x>`, `REMOVED …`, `NEW_PLUGIN <id>`, or `FAIL …`.

- On `FAIL`, say what it says and that the vault is still on the old version where `VERSION` says so; `/update` can be run again to finish.
- For each `NEW_PLUGIN`, ask: "Turn on <plugin>, which comes with this version? ==y== yes · ==n== no". On ==y==, add its id to `.obsidian/community-plugins.json`, keeping the user's own entries. Never remove one.

Then run `bash .claude/scripts/cosm.sh update-cleanup <folder>`.

## 4. Report

Say the vault is now on version Y, what was removed if anything, and that the user's notes weren't touched. Then: "Quit Obsidian and open it again now to finish."

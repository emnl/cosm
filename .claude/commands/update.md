---
description: Get the newest version of cosm — replaces cosm's own files, never your notes
---
# /update

This vault: version !`cat VERSION 2>/dev/null || echo unknown`. Source: !`grep -m1 '^# source:' MANIFEST | sed 's/^# source: *//'`

Each command runs in a new shell, so a path one command prints must be written out in full in the next; never rely on a variable from an earlier command.

## 1. Fetch

```
T=$(mktemp -d) && echo "$T" && curl -fsSL <source>/archive/refs/heads/main.zip -o "$T/cosm.zip" && unzip -q "$T/cosm.zip" -d "$T" && ls -d "$T"/*/
```

The last line printed is the new version's folder. If no folder was printed, say the new version couldn't be downloaded (quote the error), delete the temporary folder, and stop: nothing has changed.

Read the new folder's `VERSION`. If it equals this vault's, say "cosm is up to date (version X)", delete the temporary folder, and stop.

## 2. Show what's new

Show the new `CHANGES.md` entries for every version newer than this vault's. Then ask: "Update from X to Y? Your notes, `profile.md`, `MAP.md`, your preferences, your own skills and your Obsidian choices (light or dark, theme, plugins you turned on) are not touched. `y` · `n`". If a `CHANGES.md` entry says it must change one of those Obsidian files, say so in the question and ask for it separately. If step 3 will delete files that the new version dropped, list them in the question. On `n`, delete the temporary folder and stop.

## 3. Replace

Read both `MANIFEST` files first, this vault's and the new one, skipping blank lines and lines starting with `#`. Stop and change nothing if any line starts with `/`, contains `..`, names a numbered folder (`01-`…`04-`), `profile.md` or `MAP.md`, or if a path in the new list is missing from the new version.

Then, for each path in the new list, with `MANIFEST` and `VERSION` last:
- a file: `mkdir -p` its parent folder, then `cp` the new file over the old;
- a folder (ending in `/`): `rm -rf <old> && cp -R <new> <old>` in one command, with full paths.

Delete each path that this vault's `MANIFEST` lists, the new one doesn't, and the new version doesn't contain at all (a path still in the new version but off its list has become the user's: leave it). If a command fails, stop and say which paths were already replaced: `VERSION` is still the old one, so `/update` can be run again to finish.

Delete the temporary folder.

## 4. Report

Say the vault is now on version Y and the user's notes weren't touched, then: "Quit Obsidian and open it again now to finish."

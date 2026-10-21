---
description: Get the newest version of cosm — replaces cosm's own files, never your notes
---
# /update

This vault: version !`cat VERSION 2>/dev/null || echo unknown`. Source: !`grep -m1 '^# source:' MANIFEST | sed 's/^# source: *//'`

## 1. Fetch

```
T=$(mktemp -d) && curl -sL <source>/archive/refs/heads/main.zip -o "$T/cosm.zip" && unzip -q "$T/cosm.zip" -d "$T" && echo "$T"/*/
```

That folder is the new version. Read its `VERSION`. If it is the same as this vault's, say "cosm is up to date (version X)", delete the temporary folder (`rm -rf "$T"`), and stop.

## 2. Show what's new

Show the lines of the new `CHANGES.md` for every version newer than this vault's, then ask: "Update from X to Y? Your notes, `profile.md`, `MAP.md`, your preferences and your own skills are not touched. `y` · `n`". On `n`, delete the temporary folder and stop.

## 3. Replace

On `y`, for each line in the **new** `MANIFEST` that isn't a `#` comment: copy that file, or that folder's contents, from the new version over this vault's (`cp` for a file; `rm -rf` the old folder, then `cp -R` the new one, for a path ending in `/`). Files the user made are not on the list, so they stay.

Then delete the temporary folder.

## 4. Report

Say which version the vault is on now, how many files were replaced, and that the user's notes weren't touched. If anything in `.obsidian/` was replaced, add: "Quit Obsidian and open it again to finish."

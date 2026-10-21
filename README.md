# cosm

Your notes, and an AI that reads and writes them. Everything is plain files in one folder on your Mac: the AI remembers between sessions because it writes what it learns into your notes, where you can read and correct it.

## What you need

- A Mac
- A Claude plan that includes Claude Code, with Claude Code installed and signed in (`curl -fsSL https://claude.ai/install.sh | bash`, then run `claude` once and sign in)
- Obsidian, free: [obsidian.md](https://obsidian.md)
- Optional: your mail and calendar connected in the Claude app (Settings → Connectors). cosm learns much more on day one with them.

## Install (about 5 minutes)

1. Download cosm: on this page, **Code → Download ZIP**.
2. Unzip it, rename the folder to `cosm`, and move it to a folder that is backed up, such as iCloud Drive, OneDrive or Google Drive.
3. Open Obsidian → **Open folder as vault** → choose the `cosm` folder.
4. Obsidian asks whether you trust the author of this vault: click **Trust author and enable plugins**.
5. A settings window opens. Close it.
6. In the chat on the right, type `/setup`.

## Every day

The start page in cosm lists the commands. In short: `/recall` to pick up where you left off, drop anything in `01-inbox/` and say `/inbox`, `/reflect` when you're done.

## Your files

Everything you write, and everything cosm writes for you, stays in this folder. `/update` brings new versions of cosm's own files and never touches your notes.

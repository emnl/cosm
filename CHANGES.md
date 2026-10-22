# Changes

## 0.7.3
- The AI works with your tables only through cosm's own commands, so every change keeps its copy and its checks.

## 0.7.2
- The chat says in plain words what the AI is doing ("gran · Reading a table", "Searching your notes", "Moving a file") instead of "Bash".
- The AI loads cosm's skills properly, so your preferences, tables and known fixes are in front of it at once.
- Tables in a narrow chat scroll sideways instead of squeezing their columns.
- Fixed: 0.7.1 put the fixes folder's line in your map above your preferences files; this update sorts them back.

## 0.7.1
- Search ignores everyday words (in English and your language), so it attaches fewer pages that only share words like "first" or "list" with your message.
- Logs saved under the older name format are found as logs.
- The fixes folder is there from the start, and listed in your map.
- Ask to see a table and the AI opens a copy for you.

## 0.7
- The agent finds things in your notes by search, and understands word forms in your language ("fakturorna" finds "faktura") once the toolbox is installed.
- When you write a message, the agent is handed the few pages that clearly bear on it, each once per chat, so it starts from your notes instead of guessing. Nothing is attached when nothing fits.
- gran: tables for anything that would otherwise be a spreadsheet (expenses, balances, lists). The agent keeps them, adds them up with real arithmetic, and loads files straight in. A copy of each table sits in `.cosm/gran/`.
- When a tool fails and the agent finds a way round it, it writes the fix to `03-knowledge/fixes/`, and is reminded of it the next time the same thing fails.
- Search and copies run in the background, so you never wait for them.

## 0.6.3
- The help page says where pasted images and files go, and the README says what an update does to your folders and settings.

## 0.6.2
- A cleaner chat: the right sidebar holds only the chat, pinned; under an answer there's just copy; the line above it reads "Worked 4s · 325 tokens", small and faint; your own messages sit in a soft box.
- The stale note chip under the chat box is gone.
- A page the agent deletes goes to the vault's trash, so it can be brought back.

## 0.6.1
- The agent treats your vault as your own space: bold inside it, careful with anything that leaves it.
- New folders are listed in your map by name, indented under their folder; /recall and /review no longer report them as missing.

## 0.6
- Updates now reach almost everything: cosm's own settings in Obsidian and the chat are added to yours instead of replacing them, so your own choices stay.
- Updating from 0.4 or 0.5 works: your folders are renamed to 02-spaces and 03-knowledge for you, with the paths in your map fixed. No fresh install needed.
- Files and images you paste land in 01-inbox, and /inbox files them.
- The chat follows cosm's rules where the chat plugin's own instructions differ (moving and renaming files).

## 0.5
- Two folders have new names: what you run is in **02-spaces** (was 02-subjects), and people, companies, your preferences and skills are in **03-knowledge** (was 03-references).
- Already using an earlier version? Install 0.5 fresh instead of updating, and move your notes across: the agent's rules now look for the new folder names.

## 0.4.1
- The chat opens by itself when Obsidian starts, if it was closed; the help page says how to bring it back.
- /update does its work through cosm's own helper, which checks every file and only removes what it should.
- Smaller fixes to setup, the inbox, email and the agent's rules.

## 0.4
- Mail, calendar and other tools show friendly names in the chat ("Gmail · Search threads"), through a small cosm plugin; /update offers to turn it on.
- Tables in the chat keep their labels whole; lists of labels show as bold lines.
- Session logs are named like other notes; the setup scan reads mail in small pages.

## 0.3
- New look: the Cupertino theme, light and dark, following your Mac.
- Pages are named the way you'd write them (Anna Berg, Acme supply deal); people and companies each get a folder so they can grow.
- Answer keys are clear buttons, the chat no longer shows tool internals, and the agent knows which page you have open.

## 0.2
- `/inbox`, `/log`, `/reflect`, `/review` and `/update`.
- Skills for email, meeting notes, and reading and making Office files and PDFs.
- Your own to-do list, and the agent's own task lists per subject.

## 0.1
- First version: folders, start page, `/setup` and `/recall`.

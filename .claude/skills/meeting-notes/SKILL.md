---
name: meeting-notes
description: File a meeting note, a pasted transcript or a meeting export — keep the user's text, add a summary, update the subject's state page and the people in it. Use when /inbox meets a meeting, or when the user pastes or describes a meeting.
---
# Meeting notes

How the user wants it done, from `03-references/preferences/meeting-notes.md` (if its text isn't shown below, read the file first). It overrides anything here:

!`cat 03-references/preferences/meeting-notes.md 2>/dev/null || echo "No preferences yet."`

## 1. Work out what it is

From the text: the date, who was there, and which subject it belongs to (`MAP.md`, then the subject pages). Ask only what can't be told from the text, in one question with a suggestion: "Acme supply deal, 21 Oct, with Jonas Ek and Sara Lind? <kbd>y</kbd> yes · or tell me". A meeting about two subjects goes with the one it mostly decided; the other gets a link.

## 2. Save the note

`02-subjects/<subject>/notes/<YYYY-MM-DD> <Topic>.md`. From the inbox, move the file there, renamed. The user's text stays exactly as written, below a heading, a **With:** line and a summary the agent adds:

```
# Acme kickoff, 21 Oct

**With:** [[Jonas Ek]], [[Sara Lind]] · **Subject:** [[Acme supply deal]]

## Summary
- **Decided:** price 84 kr/unit; delivery moved to 17 Nov
- **Actions:** Jonas — send the contract by 25 Oct · you — confirm volumes by 24 Oct
- **Open:** who signs on Acme's side

## Notes
<the user's text, unchanged>
```

A transcript longer than a few screens is kept whole in the same note; the summary is what makes it usable.

## 3. Carry it onto the pages

- The subject's state page: the lines the meeting changed, **In flight:** and `## Open` (`AGENTS.md` § Page shapes).
- A decision that binds later work, or a change whose old value will matter, also gets its own decision note (`AGENTS.md` § How the vault grows).
- Each person and company there: update their state page with what the meeting showed about them; if they are new, create their folder and page (`03-references/<kind>/<name>/<name>.md`), with its line in `MAP.md` if it starts a new folder.
- The user's own actions: propose them for their list in one block: "Add to your list? 1. Confirm volumes to Acme [[Acme supply deal]] 📅 2026-10-24 · 2. Book the follow-up [[Acme supply deal]] — <kbd>y</kbd> all · <kbd>1</kbd> <kbd>2</kbd> pick · <kbd>n</kbd>". Others' actions stay in the note.

## 4. Report

One line on what was saved and which pages changed: "Saved [[2026-10-21 Acme kickoff]] under [[Acme supply deal]]; updated [[Acme supply deal]] (delivery 17 Nov) and [[Jonas Ek]]; new page [[Sara Lind]]." Under `/inbox`, this is the item's line: go on to the next item.

When the user corrects how a meeting is written up ("always a Decisions heading first", "skip small talk"), add it as a dated line to `03-references/preferences/meeting-notes.md` and say so.

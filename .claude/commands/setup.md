---
description: First-time setup — learns who you are and what you work on, and writes your first pages
---
# /setup

Get a new vault to useful in a few minutes. Propose rather than interview: read what can be read, ask only what can't. Ask one thing at a time and wait for the answer. Nothing is written before the user's `y`. Running it again later adds what is new; it never overwrites a page that exists.

## 1. Mail and calendar

Search the available tools for a mail tool and a calendar tool (they can connect a moment after the session starts, so search rather than read the first tool list).

- Both or one found: say which, and go to step 2.
- None found: say that cosm works without them, and that connecting mail and calendar in the AI app's settings (connectors) lets it learn much more on day one. Ask: carry on without (`y`), or stop and connect first (`n`)? Without them, go to step 4.

## 2. Read the last weeks

With the user's go ("I'll look through the last 3 weeks of your sent mail and calendar to suggest what you work on. Nothing is saved without your yes. `y`/`n`"), read:

- sent mail of the last 3 weeks: who the user writes to most, the recurring subjects
- calendar of the last 3 weeks and the next 2: recurring meetings, who is in them
- the user's own signature: name, role, company

Never copy mail text. Keep only names, a few words per subject, and who is involved.

## 3. Propose

Show one short proposal and let the user correct it in one go:

```
You:       Anna Berg, CFO at Acme AB
Subjects:  1. Acme supply deal   2. Q4 budget   3. Hiring two developers
People:    Jonas Ek (Acme), Sara Lind (your team), Per Ahl (auditor)
Companies: Acme AB, Lind & Co
Right? y · or tell me what to change
```

Take their changes, show the result once more if it changed much, then go to step 5.

## 4. Without mail and calendar: ask

One at a time:
1. Your name, role and company?
2. What are the 2–5 main things you're working on now?
3. Who are the people and companies you deal with most?

## 5. Language and answers

Ask: which language to answer in (offer the one their mail is in), and short answers or full ones? (`1` short · `2` full).

## 6. Document reader (optional)

Ask once: "Install the document reader? It lets me read Word, Excel, PowerPoint and PDF files and web pages. About 1 minute, nothing outside your user folder. `y`/`n`". On `y`, run `curl -LsSf https://astral.sh/uv/install.sh | sh` and check that `uvx --version` answers. On `n`, carry on; it can be installed later.

## 7. Write

On the user's `y` to the final proposal, write:

- `profile.md`: fill in `## Me` (name, role, company, city if known), `## Language`, and under `## How I like to work` one dated line for their answer style, e.g. `- Short answers; full detail only when I ask (2026-10-21)`.
- One folder per subject: `02-subjects/<subject>/<subject>.md` in the state page shape from `AGENTS.md`, with what is known in `## Where it stands` (*As of* today) and anything unclear under `## Open`. No `tasks.md` or `notes/` yet; they come with their first item.
- One page per person and company in `03-references/people/` and `03-references/companies/`: heading, one line on who they are and how the user knows them, links to their subjects.
- `MAP.md`: one line per new subject folder.

Use the naming and link rules in `AGENTS.md`. Then say in a few lines what was written.

## 8. First task

End on something real, not a summary. With a mail tool: "Want me to go through your inbox now? `y`/`n`". Without: "Drop a note or a meeting write-up in `01-inbox/` and say /inbox, or ask me anything about your subjects."

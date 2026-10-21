---
description: First-time setup — learns who you are and what you work on, and writes your first pages
---
# /setup

Get a new vault to useful in about three minutes. Propose rather than interview: read what can be read, ask only what can't, one question at a time. Nothing is written before the user's `y`.

## What the vault already holds

Today: !`date +%Y-%m-%d`

Pages: !`find 02-subjects 03-references -name '*.md' 2>/dev/null`

Toolbox: !`~/.local/bin/uv --version 2>/dev/null || echo not installed`

On a rerun, propose only what isn't listed above and never overwrite a page that exists: leave filled sections of `profile.md` as they are, add new To do lines at the end of `todo.md`, and skip step 6 if the toolbox is installed.

## 1. Start

Say first: "I'll set up your notes in about 3 minutes. With your OK I'll look at your mail and calendar, suggest what you work on, and you correct it."

Then search the available tools for a mail tool and a calendar tool.

- One or both found: go to step 2.
- None found: say "Connecting your mail and calendar in the settings of the account you signed in with (under Connectors) lets me learn much more on day one. Afterwards, start a new chat and type /setup again. Carry on without them for now? `y` · `n`". On `y`, go to step 3. On `n`, stop.

## 2. Read the last weeks

Ask, naming only the tools found: "I'll look at whom you've written to, what's waiting for your reply, and about what over the last 3 weeks, and at your calendar 3 weeks back and 2 ahead. Your mail stays where it is: I keep only names and topics, and nothing is saved without your yes. `y` · `n`". On `n`, go to step 3.

On `y`, say it takes a minute or two, then read:
- sent mail: recipients and subject lines only; open a message only to read the user's own signature
- active threads: threads of the last 3 weeks with a real back-and-forth (the user and others both writing, three messages or more): participants and subject lines only. They are the best source for Subjects and People; the ones waiting on the user feed To do.
- calendar: recurring meetings and who is in them

Skip anything that looks private (health, family). Never copy mail text. Whatever the reading doesn't give (often name and role), ask with the questions in step 3. Then go to step 4.

## 3. Without mail and calendar: ask

1. Your name, role and company?
2. What are the 2–5 main things you're working on now?
3. Who are the people and companies you deal with most?

## 4. Propose

Show one block, at most 5 subjects, 10 people and 5 companies, the ones that come up most:

```
You:       Anna Berg, CFO at Nordvik AB
Language:  Swedish (as in your mail)
Answers:   short — or say "full"
Subjects:  1. Acme supply deal   2. Q4 budget   3. Hiring two developers
People:    Jonas Ek (Acme), Sara Lind (your team), Per Ahl (auditor)
Companies: Acme AB, Lind & Co
To do:     1. Reply to Jonas on the delivery date   2. Q4 budget draft by 1 Nov
Create these pages? y · or tell me what to change
```

Language is the one their mail is in, or the one they type in. To do holds up to three things the user has to do, from active threads waiting on them and upcoming meetings; leave it out when there are none. After any change, show the block again and ask `y` again.

## 5. Write

On `y`, write:

- `profile.md`: `## Me` (name, role, company, city if known), `## Language`, and under `## How I like to work` dated lines: the answer style (`- Short answers; full detail only when I ask (<today>)`), then the two defaults, `- Tables over prose for structured data (default)` and `- One item at a time when there are several to decide (default)`.
- The user's own subject: `02-subjects/<user>/<user>.md`, a state page for their own work and admin (`<user>`: their first name, lowercase), and `02-subjects/<user>/todo.md` with the To do lines from the block, each linked to its subject.
- One folder per subject: `02-subjects/<subject>/<subject>.md`, a state page in the shape from `AGENTS.md`, with what the reading showed; `## Open` only for open items it showed.
- One state page per person and company in `03-references/people/` and `03-references/companies/`, in the same shape.
- `MAP.md`: one line per new folder.
- `.cosm-last-review`: today's date, one line, so the first review reminder comes a week from now.

Then say in a few lines what was written, and that `todo.md` is theirs to change however they like.

## 6. Toolbox

If it isn't installed, ask: "Install the toolbox? It lets me read and make Word, Excel, PowerPoint and PDF files. About 1 minute, nothing outside your user folder. `y` · `n`". On `y`, run `curl -LsSf https://astral.sh/uv/install.sh | sh` and check that `~/.local/bin/uv --version` answers. If it doesn't, say it didn't install, that cosm works without it, and carry on.

## 7. First task

End on something real. With a mail tool: "Want me to go through your inbox now? `y` · `n`". Without: "Make a new note (⌘N) and it lands in your inbox. Type anything, then say /inbox."

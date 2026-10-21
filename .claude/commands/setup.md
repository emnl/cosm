---
description: First-time setup — learns who you are and what you work on, and writes your first pages
---
# /setup

Get a new vault to useful in about three minutes. Propose rather than interview: read what can be read, ask only what can't, one question at a time. Nothing is written before the user's ==y==.

## What the vault already holds

Today: !`date +%Y-%m-%d`

Pages: !`bash .claude/scripts/cosm.sh pages`

Toolbox: !`bash .claude/scripts/cosm.sh toolbox`

On a rerun, propose only what isn't listed above and never overwrite a page that exists: leave filled sections of `profile.md` as they are, add new To do lines at the end of `todo.md`, and skip step 6 if the toolbox is installed.

## 1. Start

Search the available tools for a mail tool and a calendar tool, without a message first. Your first message then opens with this line, word for word, before anything else:

> I'll set up your notes in about 3 minutes. With your OK I'll look at your mail and calendar, suggest what you work on, and you correct it.

- One or both found: go to step 2.
- None found: say "Connecting your mail and calendar in the settings of the account you signed in with (under Connectors) lets me learn much more on day one. Afterwards, start a new chat and type /setup again. Carry on without them for now? ==y== yes · ==n== no". On ==y==, go to step 3. On ==n==, stop.

## 2. Read the last weeks

In the same first message, after the opening line, ask, naming only the tools found: "I'll look at whom you've written to, what's waiting for your reply, and about what over the last 3 weeks, and at your calendar 3 weeks back and 2 ahead. Your mail stays where it is: I keep only names and topics, and nothing is saved without your yes. ==y== yes · ==n== no". On ==n==, go to step 3.

On ==y==, say it takes a minute or two, then read:
- sent mail: recipients and subject lines only; open a message only to read the user's own signature
- active threads: threads of the last 3 weeks with a real back-and-forth (the user and others both writing, three messages or more): participants and subject lines only. They are the best source for Subjects and People; the ones waiting on the user feed To do.
- calendar: recurring meetings and who is in them

Never copy mail text. Whatever the reading doesn't give (often name and role), ask with the questions in step 3. Then go to step 4.

## 3. Without mail and calendar: ask

1. Your name, role and company?
2. What are the 2–5 main things you're working on now?
3. Who are the people and companies you deal with most?

## 4. Propose

Show the proposal as bold-label lines (never a table or a code block; the chat is narrow), at most 5 subjects, 10 people and 5 companies, the ones that come up most:

**You** · Anna Berg, CFO at Nordvik AB
**Language** · Swedish (as in your mail)
**Answers** · short (or say "full")
**Subjects** · Acme supply deal · Q4 budget · Hiring two developers
**People** · Jonas Ek (Acme) · Sara Lind (your team) · Per Ahl (auditor)
**Companies** · Acme AB · Lind & Co
**To do** · Reply to Jonas on the delivery date · Q4 budget draft by 1 Nov

Then one line: "I'll make a page for each subject, person and company, and your to-do list, and keep them up to date as we work. ==y== yes · or tell me what to change".

Language is the one their mail is in, or the one they type in. To do holds up to three things the user has to do, from active threads waiting on them and upcoming meetings; leave it out when there are none. After any change, show the block again and ask ==y== again.

## 5. Write

On ==y==, write:

- `profile.md`: `## Me` (name, role, company, city if known), `## Language`, and under `## How I like to work` dated lines: the answer style (`- Short answers; full detail only when I ask (<today>)`), then the two defaults, `- Tables over prose for structured data (default)` and `- One item at a time when there are several to decide (default)`.
- The user's own subject: `02-subjects/<user>/<user>.md`, a state page for their own work and admin (`<user>`: their first name, as they write it), and `02-subjects/<user>/todo.md` with the To do lines from the block, each linked to its subject.
- One folder per subject: `02-subjects/<subject>/<subject>.md`, a state page in the shape from `AGENTS.md`, with what the reading showed; `## Open` only for open items it showed.
- One folder per person and company, `03-references/people/<name>/<name>.md` and `03-references/companies/<name>/<name>.md`, with a state page in the same shape.
- `MAP.md`: one line per new folder.
- `.cosm-last-review`: today's date, one line, so the first review reminder comes a week from now.

Then say in a few plain lines what was made, by name and what it is for, not by path: "I made your profile, a page for each of your 5 subjects (Acme supply deal, Q4 budget …), pages for 10 people and 5 companies, and your to-do list [[todo]], which is yours to change however you like. I'll keep the pages up to date as we work."

## 6. Toolbox

If it isn't installed, ask: "Install the toolbox? It lets me read and make Word, Excel, PowerPoint and PDF files. About 1 minute, nothing outside your user folder. ==y== yes · ==n== no". On ==y==, run `curl -LsSf https://astral.sh/uv/install.sh | sh` and check that `~/.local/bin/uv --version` answers. If it doesn't, say it didn't install, that cosm works without it, and carry on.

## 7. First task

End on something real. With a mail tool: "Want me to go through your inbox now? ==y== yes · ==n== no". Without: "Make a new note (⌘N) and it lands in your inbox. Type anything, then say /inbox."

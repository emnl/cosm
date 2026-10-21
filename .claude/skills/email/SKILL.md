---
name: email
description: Go through the user's mail inbox with them, one thread at a time — what it is, who it's from, a proposed action — and draft replies. Use when the user asks to go through, check, triage or answer their email, asks about a particular mail or thread, or wants a mail drafted.
---
# Email

How the user wants it done, from `03-references/preferences/email.md` (if its text isn't shown below, read the file first). It overrides anything here except § Never:

!`cat 03-references/preferences/email.md 2>/dev/null || echo "No preferences yet."`

If no mail tool is found, say how to connect one: the settings of the account they signed in with, under Connectors, then a new chat.

## Two ways of working

Which one the user has is a line in `email.md`; until it is there, ask first (§ Offer once).

- **They archive.** The inbox is their to-do list: a thread in it still needs something; archived means done. Work oldest first, by each thread's last message.
- **They keep everything.** Never suggest archiving. Work from what is waiting on them: threads from the last 2 weeks, and since the date in `.cosm-last-mail` if it is older, where the newest message isn't from the user; newest first. A thread is handled when the user has replied or says done or skip. At the end of the pass, write today's date to `.cosm-last-mail` (one line).

Either way, read a thread from its newest message; don't take its last activity from a search result, which may show only some of its messages.

## One thread at a time

For each thread, in a few lines:
1. **What it is:** one sentence.
2. **Who:** the sender, from their page in `03-references/` if there is one ("Jonas Ek, Acme, the supply deal"); read the subject page it belongs to before proposing anything.
3. **Proposal:** reply (with the draft's gist), archive (only if they archive), nothing needed, or a line for the user's list (`todo.md`), and why.
4. **Keys:** one line of the keys that apply: ==d== write the suggested draft · ==a== archive · ==y== do what's proposed · ==s== skip, next thread · ==1== ==2== … an option. Anything else the user types is an answer or a correction.

Wait for the answer before the next thread. Skipped threads stay in the inbox and come once in the recap, not again.

Leave newsletters, notifications and other automated mail out of the one-by-one pass. After every ten threads, a short recap: what left the inbox, what stays and why, what is waiting on others; list the inbox again; and offer the automated mail in one line with a count and its senders: "8 newsletters and notifications (Acme News, LinkedIn …). Archive them all? ==y== yes · ==n== no". A sender seen three times in a session gets a filter or preference line proposed.

## Drafts

- On ==d==, show the draft text in the chat first, with ==y== create it · or tell me what to change. Change it there until the user says ==y==; only then create one draft in their mail. Their changes are how their style is learned: a change that applies to every mail ("sign off Anna B") becomes a preference line.
- Make drafts only with a tool that says it creates a draft. A tool called reply, send or forward may send at once: never call one, even when the user says "just send it". Say the draft is waiting in their mail app.
- Write in the user's language and register for that person; before a reply to someone outside, check what was promised in the thread and on the subject page.
- Numbers, dates, names and commitments come from the thread or the vault. When one is unknown, leave a marked gap such as `[date]`.
- Read the draft back after creating it: its recipients, and that it sits in the thread. Never leave two drafts on one thread; a change after creating it replaces the draft.
- Attachments can't be added through the mail tool: write the draft, then list what to attach. An attachment the mail tool can't open: ask the user to save it to `~/Downloads` and read it there.

## What it learns

- A fact from a thread (a date moved, a decision, a new contact) goes to its page before the next thread, said in one line. Paraphrase it and name the sender and date; never copy mail text into a page.
- A rule about mail as a whole ("archive newsletters from X without showing me", "sign off with my first name only") goes as a dated line to `03-references/preferences/email.md` at once.

## Offer once

Each of these is offered the first time it applies (`AGENTS.md` § Learning):
- Before the first pass: "Do you archive mail when it's done, or let your inbox grow? ==1== I archive · ==2== I keep everything"
- If they archive, when the inbox has more than about 50 threads: "Your inbox has 1,240 threads. Start fresh? ==1== archive everything older than 3 months in one go (it stays searchable) · ==2== work only the last 4 weeks, leave the rest · ==n== go through it all". Explain once, before it: "The inbox is your to-do list: archived means done." Count the inbox before listing it.
- If they archive, when the user says they sent a reply: "Archive a thread when you say it's sent, from now on? ==y== yes · ==n== no"

## Never

Send a mail. Delete a mail, or change filters or labels, without the user's ==y== on that exact change. Archive on your own judgment: only on ==a==, ==y==, or a preference line the user agreed to.

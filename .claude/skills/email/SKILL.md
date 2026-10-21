---
name: email
description: Go through the user's mail inbox with them, one thread at a time — what it is, who it's from, a proposed action — and draft replies. Use when the user asks to go through, check, triage or answer their email, asks about a particular mail or thread, or wants a mail drafted.
---
# Email

How the user wants it done, from `03-references/preferences/email.md` (if its text isn't shown below, read the file first). It overrides anything here except § Never:

!`cat 03-references/preferences/email.md 2>/dev/null || echo "No preferences yet."`

If no mail tool is found, say how to connect one: the settings of the account they signed in with, under Connectors, then a new chat.

## How the inbox works

The inbox is the user's to-do list: a thread in it still needs something. Archived means done. Work oldest first, by each thread's last message. Read a thread from its newest message; don't take its last activity from a search result, which may show only some of its messages.

## One thread at a time

For each thread, in a few lines:
1. **What it is:** one sentence.
2. **Who:** the sender, from their page in `03-references/` if there is one ("Jonas Ek, Acme, the supply deal"); read the subject page it belongs to before proposing anything.
3. **Proposal:** reply (with the draft's gist), archive, or a line for the user's list (`todo.md`), and why.
4. **Keys:** one line of the keys that apply: `d` create the suggested draft · `a` archive · `y` do what's proposed · `s` skip, next thread · `1` `2` … an option. Anything else the user types is an answer or a correction.

Wait for the answer before the next thread. Skipped threads stay in the inbox and come once in the recap, not again.

Leave newsletters, notifications and other automated mail out of the one-by-one pass. After every ten threads, a short recap: what left the inbox, what stays and why, what is waiting on others; list the inbox again; and offer the automated mail in one line with a count and its senders: "8 newsletters and notifications (Acme News, LinkedIn …). Archive them all? `y` · `n`". A sender seen three times in a session gets a filter or preference line proposed.

## Drafts

- Make drafts only with a tool that says it creates a draft. A tool called reply, send or forward may send at once: never call one, even when the user says "just send it". Say the draft is waiting in their mail app.
- Write in the user's language and register for that person; before a reply to someone outside, check what was promised in the thread and on the subject page.
- Numbers, dates, names and commitments come from the thread or the vault. When one is unknown, leave a marked gap such as `[date]`.
- Read the draft back before handing it over: its recipients, and that it sits in the thread. Never leave two drafts on one thread; to change one, replace it.
- Attachments can't be added through the mail tool: write the draft, then list what to attach. An attachment the mail tool can't open: ask the user to save it to `~/Downloads` and read it there.

## What it learns

- A fact from a thread (a date moved, a decision, a new contact) goes to its page before the next thread, said in one line. Paraphrase it and name the sender and date; never copy mail text into a page.
- A rule about mail as a whole ("archive newsletters from X without showing me", "sign off with my first name only") goes as a dated line to `03-references/preferences/email.md` at once.

## Never

Send a mail. Delete a mail, or change filters or labels, without the user's `y` on that exact change. Archive on your own judgment: only on `a` or `y`.

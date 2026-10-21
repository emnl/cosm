---
name: email
description: Go through the user's mail inbox with them, one thread at a time — what it is, who it's from, a proposed action — and draft replies. Use when the user asks to go through, check, triage or answer their email, or names a sender or a thread.
---
# Email

How the user wants it done (read first and follow it over anything below):

!`cat 03-references/preferences/email.md 2>/dev/null || echo "No preferences yet."`

Search the available tools for a mail tool before starting; if none is there, say so and how to connect one (the account's settings, under Connectors, then a new chat).

## How the inbox works

The inbox is the user's to-do list: a thread in it still needs something. Archived means done. Work oldest first.

## One thread at a time

For each thread, in a few lines:
1. **What it is:** one sentence.
2. **Who:** the sender, from their page in `03-references/` if there is one ("Jonas Ek, Acme, the supply deal"); read the subject page it belongs to before proposing anything.
3. **Proposal:** reply (with the draft's gist), archive, or make it a task, and why.
4. **Keys:** one line of the keys that apply: `d` create the suggested draft · `a` archive · `s` skip, next thread · `1` `2` … an option. Anything else the user types is an answer or a correction.

Wait for the answer before the next thread. Skipped threads stay in the inbox and come once in the recap, not again.

Newsletters, notifications and other noise go at the end as one line with a count: "8 newsletters and notifications. Archive them all? `y` · `n`". A sender that turns up three times gets a suggestion for a mail filter or a preference line.

After every ten threads, a short recap: what left the inbox, what stays and why, what is waiting on others.

## Drafts

- Only drafts: never send. The user sends from their mail app.
- Write in the user's language and register for that person; before a reply to someone outside, check what was promised in the thread and on the subject page.
- Attachments can't be added through the mail tool: write the draft, then list what to attach.
- When the user edits a draft and asks for the final version, their edits are the direction.

## What it learns

- A fact from a thread (a date moved, a decision, a new contact) goes to its page before the next thread, and is said in one line.
- A rule about mail ("newsletters from X: archive, don't show me", "always cc Sara on Acme") goes as a dated line to `03-references/preferences/email.md` at once; if the file is new, it gets its line in `MAP.md`.

## Never

Send a mail. Delete a mail, or change filters or labels, without the user's `y` on that exact change. An attachment the mail tool can't open: ask the user to save it to `~/Downloads` and read it there.

# cosm

This folder is the user's notes: plain markdown files, read and written by the agent. Every session starts from these files, not from memory of earlier chats. This file is the agent's rules. It is a system file: `/update` replaces it, so the agent never edits it.

At the start of every session, read `profile.md` (who the user is, how they like to work) and `MAP.md` (what exists and where) before the first reply.

## Session start and end

- The first reply of a session runs `/recall` (`.claude/commands/recall.md`), then answers the message. If the message is already a concrete task ("go through my email"), skip `/recall` and do the task.
- When the user says they are done, or the session has clearly wound down, ask once: "`/reflect` before you go?" After it, offer `/log`. Never add this to ordinary replies.
- If `profile.md` has no name in it, the vault is new: suggest `/setup` before anything else.

## Folders

| Folder | Holds |
|---|---|
| `01-inbox/` | anything dropped in by the user; `/inbox` files it |
| `02-subjects/<subject>/` | something the user runs (a project, a client, an area): `<subject>.md` (state page), `tasks.md`, `notes/` (dated notes such as meetings) |
| `03-references/people/`, `03-references/companies/` | what the user knows about a person or company: one page each, `<name>.md` |
| `04-archive/subjects/` | finished subjects, same layout as `02-subjects/` |
| `04-archive/logs/<YYYY-MM>/` | session logs from `/log`, filed by `/inbox`; never changed after filing |
| `preferences/` | `<skill>.md`: how the user wants one kind of work done |

Root files: `HOME.md` (start page, system), `MAP.md` (vault map), `profile.md`. Nothing else goes at the root.

## Reading and writing

- **Read before answering.** When a subject, person or company comes up, read its page first and work from what the vault says, not from the conversation alone. `MAP.md` shows where it is.
- **Write as you go.** When something durable comes up (a decision, a date, a number, a name, a commitment, a correction), write it to its page right then and say so in one line. Nothing waits for the end of the session.
- **What goes on a page:** what was decided, not what was discussed. Status changes, decisions with their reason, numbers, names, dates, commitments. Leave out background and passing thoughts. Replace the line that changed; never add a running log to a state page.
- **The user's own words** (a note, a meeting write-up) are kept as written. The agent may add a short summary on top; it never rewrites their text.

### Where each kind of fact goes

| Fact | Goes to |
|---|---|
| Who the user is, how they like to work in general | `profile.md` (propose first, write on `y`) |
| How the user wants one kind of work done | `preferences/<skill>.md`, one dated line |
| Where a subject stands, what is open | `02-subjects/<subject>/<subject>.md` |
| Something to do by a date | `02-subjects/<subject>/tasks.md` (on `y`) |
| A meeting or other dated note | `02-subjects/<subject>/notes/<YYYY-MM-DD>-<topic>.md` |
| A fact about a person or company | `03-references/people/<name>.md`, `03-references/companies/<name>.md` |

### Page shapes

State page:

```
# Acme supply deal

One line: what this is.

## Where it stands
*As of 2026-10-21*
- Price agreed at 84 kr/unit; contract with Acme's lawyer
- Delivery moved to 3 Nov

## Open
- Who signs on Acme's side
```

Optional sections, only when they have content: `## How to` (procedures for this subject), `## People` (links).

Reference page: `# Anna Berg`, one line on who they are and how the user knows them, then `## Notes` with dated facts, rewritten in place when they change.

Tasks, one line each in the subject's `tasks.md`: `- [ ] Send Acme the revised price 📅 2026-11-03`. A task is the user's commitment, so it is written only on their `y`.

### Naming and links

- File names: lowercase, hyphens, unique across the vault: `anna-berg.md`, `acme-deal.md`, `2026-10-21-acme-kickoff.md`.
- Link pages with `[[anna-berg]]`. A meeting note links everyone who was there and its subject; a state page links the people who matter to it.
- Every page starts with a `# Heading`. No frontmatter.

### MAP.md

Folders, not files, two levels deep, each with a few words: `- 02-subjects/acme-deal/ — Acme supply deal, signing Nov`. When the agent creates or archives a subject, or adds a folder, it updates `MAP.md` in the same step. `04-archive/` is not listed in detail.

### Archive

When a subject is done, propose moving its folder to `04-archive/subjects/`; move it on `y`. References are never archived.

## Learning

- A correction about one kind of work ("newsletters from X: archive, don't show me") goes at once to `preferences/<skill>.md` as one dated line: `- Archive newsletters from X without showing them (2026-10-21)`. Say so in one line.
- A correction about how the user works in general goes to `profile.md`: propose the line, write it on `y`.
- A procedure done the same way a second time is a skill candidate: `/reflect` proposes it.
- Size: about 2,000 characters per `preferences/` file and 1,500 for `profile.md`. Past that, `/review` proposes a tighter version (duplicates merged, overridden lines dropped).

## System files

`AGENTS.md`, `CLAUDE.md`, `HOME.md`, the commands and skills that ship with cosm (listed in `MANIFEST`), `VERSION`, `CHANGES.md`, `.obsidian/` plugins, theme and snippets. `/update` replaces them, so the agent never edits them: a change there would be lost. A rule the user gives goes to `preferences/` or `profile.md` instead. Skills the user makes go in `.claude/skills/<name>/`; they are not in `MANIFEST`, so updates leave them alone.

## Keys

When the agent asks the user to choose, it ends with one line of the keys that apply, and each key always means the same:

`y` yes, do it · `n` no · `s` skip, next item · `1` `2` … pick an option · `a` archive (email) · `d` create the draft (email)

Anything else the user types is an answer or a correction.

## Tools

- Tools are described by what they do, never by product: a mail tool, a calendar tool, a file tool. Mail and calendar tools may connect a moment after a session starts; search the available tools for them before concluding there are none.
- Use what a fresh Mac has (`curl`, `unzip`, `textutil`, `find`, `grep`, reading PDFs and images directly), plus `uv` / `uvx` when installed (`uvx markitdown <file>` turns Word, Excel, PowerPoint, PDF and web pages into markdown). Never install anything without asking.

## Safety

No passwords, tokens or card numbers in notes. If one turns up in the inbox or a mail, say so and leave it out of the note.

## Quirks

- "File has been modified since read": the editor touched the file. Re-read it, then write.
- The editor pads markdown table columns, so an exact-text edit on a table row can miss. Match the row by its first cell and replace the whole line.

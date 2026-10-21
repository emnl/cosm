---
description: Before you close — what I learned this session, and what could become a skill
---
# /reflect

Look back over this session only. Make the learning visible: the user confirms or corrects it. Nothing new is written without a `y`.

## 1. What was written down

List, in a few lines, what this session already wrote as learning:
- preference lines (which file, the line)
- profile lines proposed or written
- facts written to pages that changed how a subject stands

Ask: "Anything wrong or missing? `y` all fine · or tell me". Fix what they correct at once, in the same files.

## 2. Anything not yet written

Anything durable from the whole session that isn't on its page yet: a correction or preference, a decision, a date, an unfinished thread (it goes to the subject's `tasks.md` or the user's `todo.md`). Check the page before calling it missing. Propose each, one at a time, with where it goes; write on `y`.

If nothing was learned or missed, say so in one line and go to step 4.

## 3. A skill?

A procedure is a skill candidate when it was done the same way twice or more (this session, or this session and an earlier one in a log), or when the user had to explain the same steps again. Propose at most one:

> "You sorted supplier invoices the same way three times: check the VAT line, match the order, file under the supplier. Make it a skill, `invoices`? `y` · `n`"

On `y`, write `03-references/skills/<name>/SKILL.md`, add its line to `MAP.md` (`- 03-references/skills/<name>/ — <when it applies, in the user's words>`), and move the matching preference lines (name them in the proposal) into `03-references/preferences/<name>.md`, with its `MAP.md` line if the file is new. How to write it:
- Starts with `# <Name>` and one line on what it does. No frontmatter: the agent finds it through its `MAP.md` line.
- The steps as rules the agent can follow on its own, short. Examples only for the shape of an output; a rule that needs an example to be understood is rewritten.
- Self-contained: what it needs sits in its folder; facts that live on a page (a price, a contact) are linked, not copied. Name the user's own tools if they are the user's (their mail app, their spreadsheet).
- Its first step says to read `03-references/preferences/<name>.md` if it exists.

## 4. Log

Offer: "`/log` this session? `y` · `n`".

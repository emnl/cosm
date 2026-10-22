---
description: Before you close — what I learned this session, and what could become a skill
---
# /reflect

Look back over this session only. Make the learning visible: the user confirms or corrects it. Nothing new is written without a ==y==.

## 1. What was written down

List, in a few lines, what this session already wrote as learning:
- preference lines (which file, the line)
- profile lines proposed or written
- facts written to pages that changed how a space stands
- fix lines written to `03-knowledge/fixes/`, and rows written to gran

Ask: "Anything wrong or missing? ==y== all fine · or tell me". Fix what they correct at once, in the same files.

## 2. Anything not yet written

Anything durable from the whole session that isn't on its page yet: a correction or preference (including a way of working the user showed without saying it as a rule), a decision, a date, an unfinished thread (it goes to the space's `tasks.md` or the user's `todo.md`), a failure the agent got past without writing its fix, rows or figures that fit gran but weren't offered, and `tmp_` tables this session made (`gran-list` ends with them; keep: rename and describe; or drop). Check the page before calling it missing. Propose each, one at a time, with where it goes; write on ==y==.

If nothing was learned or missed, say so in one line.

## 3. A skill, or a skill update?

When a skill was used this session and the user corrected it, or did a step differently, propose updating it: a skill in `03-knowledge/skills/` is edited directly (show the changed lines, write on ==y==); for a skill that ships with cosm (in `.claude/skills/`), the change goes into its preferences file instead.


A procedure is a skill candidate when it was done the same way twice or more (this session, or this session and an earlier one in a log), or when the user had to explain the same steps again. Propose each candidate, one at a time:

> "You sorted supplier invoices the same way three times: check the VAT line, match the order, file under the supplier. Make it a skill, `invoices`? ==y== yes · ==n== no"

On ==y==, write `03-knowledge/skills/<name>/SKILL.md`, add its line to `MAP.md`, indented below `03-knowledge/skills/` (`  - <name>/ — <when it applies, in the user's words>`), and move the matching preference lines (name them in the proposal) into `03-knowledge/preferences/<name>.md`, with its `MAP.md` line if the file is new. How to write it:
- Starts with `# <Name>` and one line on what it does. No frontmatter: the agent finds it through its `MAP.md` line.
- The steps as rules the agent can follow on its own, short. Examples only for the shape of an output; a rule that needs an example to be understood is rewritten.
- Self-contained: what it needs sits in its folder; facts that live on a page (a price, a contact) are linked, not copied. Name the user's own tools if they are the user's (their mail app, their spreadsheet).
- Its first step says to read `03-knowledge/preferences/<name>.md` if it exists.

## 4. Log

Offer: "`/log` this session? ==y== yes · ==n== no".

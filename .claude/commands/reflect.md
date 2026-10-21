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

Corrections or preferences the user gave that didn't make it into a file (said in passing, or before the agent noticed). Propose each as its line, one at a time, with where it would go; write on `y`.

## 3. A skill?

A procedure is a skill candidate when it was done the same way twice or more (this session, or this session and an earlier one in a log), or when the user had to explain the same steps again. Propose at most one:

> "You sorted supplier invoices the same way three times: check the VAT line, match the order, file under the supplier. Make it a skill, `invoices`? `y` · `n`"

On `y`, write `03-references/skills/<name>/SKILL.md` and its line in `MAP.md`, and move any matching preference lines into `03-references/preferences/<name>.md`. How to write it:
- Front: `name`, and a `description` that says what it does and when to use it, in the user's words; this is what makes it come up next time.
- Body: the steps as rules the agent can follow on its own, short. If a rule needs an example to be understood, rewrite the rule.
- Self-contained: what it needs is in its folder; nothing copied from elsewhere goes stale in it. Name the user's own tools if they are the user's (their mail app, their spreadsheet).
- Its first step says to read `03-references/preferences/<name>.md` if it exists. (A skill here is read as a file when `MAP.md` points to it, so it can't load the file by itself.)

## 4. Log

Offer: "`/log` this session? `y` · `n`".

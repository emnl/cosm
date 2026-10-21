---
name: gran
description: gran, the user's tables — rows that would otherwise live in a spreadsheet (expenses, balances, measurements, a contact or case list), kept in one local SQL database and queried with real SQL. Use when the user asks to log, record, look up, total, compare or export rows ("log this", "what did we spend in March", "put this in a table"); when a figure that fits an existing table turns up in other work; when a task means adding up or matching more than about 20 rows; and before answering from memory a number a table holds.
---
# gran

The user's tables, in one SQLite database at `.cosm/gran.db`. The agent runs it with SQL through the commands below; the user sees it through the agent's answers.

Tables now: !`bash .claude/scripts/cosm.sh gran-list`

## What goes in a table

If it would otherwise be a spreadsheet, it is a table: rows that recur, get added to and get added up. Narrative, decisions and status stay on pages. A thing that deserves its own page (a company, a person with a history) is a page, not a row.

A table and its page point at each other: the table's `Scope:` names the page that owns it, and that page names the table in one line under **Parts**, for example `- Card expenses: gran table expenses`. The page never repeats the columns; a figure copied onto it carries its date ("as of 2026-10-21, from `expenses`").

## Commands

| Command | Does |
|---|---|
| `bash .claude/scripts/cosm.sh gran-list` | every table with its description |
| `bash .claude/scripts/cosm.sh gran-describe <table>` | the description, every column with its type and meaning, the key |
| `bash .claude/scripts/cosm.sh gran-query "<SELECT …>"` | read only, as a table; more than 200 rows are cut with a notice, so count and sum in SQL rather than reading rows |
| `bash .claude/scripts/cosm.sh gran-exec "<SQL>"` | any SQL, several statements, all or nothing (no `BEGIN`/`COMMIT`: it adds them); then the copies in `.cosm/gran/` and a check |
| `bash .claude/scripts/cosm.sh gran-import <table> <file.csv>` | adds the rows of a CSV file (header row = column names) to a table, all or nothing, empty cells as NULL; a `tmp_` table that doesn't exist is made from the header (all columns text) |

The SQL goes in double quotes: text values in single quotes, an apostrophe inside one doubled (`'Anna''s'`); no `$`, backtick or double quote inside.

## Reading

Read the description and column meanings before adding anything up (`gran-describe`). A column described as a *stock* (a balance, a headcount) is never summed across dates: take the latest per group. A *flow* (a payment, an expense) can be summed. Numbers that go to someone outside come from a query the user has seen, never from memory.

## Making a table

One `gran-exec`: create it, describe it, load it, and read it back.

```
CREATE TABLE expenses (
  ref      TEXT NOT NULL,                 -- the statement's own transaction reference
  date     TEXT NOT NULL,                 -- YYYY-MM-DD
  merchant TEXT NOT NULL,
  amount   REAL NOT NULL,
  category TEXT CHECK (category IN ('travel', 'software', 'food', 'other')),
  note     TEXT,
  source   TEXT NOT NULL,
  PRIMARY KEY (ref)
) STRICT;
INSERT INTO table_docs (tbl, col, doc) VALUES
  ('expenses', '', 'Expenses paid on the company card.
Grain: one row per card transaction
Scope: [[Budget]]
Queries: spend, spent, utgifter, kostnader, card, kort'),
  ('expenses', 'ref', 'Transaction reference from the card statement'),
  ('expenses', 'date', 'Day of the purchase'),
  ('expenses', 'merchant', 'Who was paid, as on the statement'),
  ('expenses', 'amount', 'SEK including VAT. A flow: sum freely'),
  ('expenses', 'category', 'What it was for'),
  ('expenses', 'note', 'Anything that does not fit a column'),
  ('expenses', 'source', 'Where the row came from: the statement, file or mail');
INSERT INTO expenses (ref, date, merchant, amount, category, source)
  VALUES ('4471-0921', '2026-10-02', 'SAS', 2450, 'travel', 'card statement Oct 2026');
SELECT * FROM expenses;
```

Every table needs:
- a description in `table_docs` (`col` empty): one plain line, then `Grain: one row per …`, `Scope: [[Page]]` and `Queries: …`;
- a line in `table_docs` for every column, saying what it holds, its unit, and stock or flow for numbers;
- `STRICT` at the end, so a number written as text (`2 450`) is refused instead of stored wrong;
- a primary key that tells two real rows apart (two coffees on one day are two rows: use the statement's reference, not date and amount), and a `source` column filled on every row, specifically ("card statement Oct 2026", a file name, a mail), never "user" or "chat".

`gran-exec` and `gran-import` end with `OK` only when all of this is in place; otherwise they list what is missing (`MISSING DESCRIPTION`, `NO KEY`, `NO SOURCE COLUMN`, `NOT STRICT`) and say `WRITTEN, but …`: fix them in the same session.

`Queries:` holds the words the user would ask for this data with, where they differ from the description: the other language, short forms, the question behind the number. A table is attached to a message when the message shares two of these words with it, so leave out names the rest of the vault also uses (the company, a person), and add a word when a question that should have found the table didn't.

Also: allowed values get a `CHECK` ("travel" and "Travel" break every total); dates are text as `YYYY-MM-DD`; a fact that fits no column goes in `note`, never into a column meant for something else; a total asked for twice becomes a view (`CREATE VIEW`, with a description in `table_docs` holding Grain and Scope; its columns need none).

## Writing

- The user asks to record something: do it, and say in one line what was written.
- In a kept table (any not named `tmp_…`), changing or deleting rows the user didn't ask to change needs ==y==, however few: nothing undoes a write. More than 10 rows changed or deleted, or a change to its shape (`ALTER`, `DROP`, rename), needs ==y== even when asked. In `tmp_` tables anything goes, without asking. Say exactly what will change (the rows, or their count and a sample) before asking. Adding rows, and fixing the rows the user named, need no question. A dropped table's last copy goes to `.trash/`.
- Many rows (a statement, a list): write them to a CSV file in a new `mktemp -d` folder and use `gran-import`, never a long `INSERT` list. An Excel file becomes CSV first (tools skill). Rows that may already be there: import into a `tmp_` table, then `INSERT … SELECT` only the new ones.
- Scratch work: a table named `tmp_…` needs no description and gets no copy. Use one whenever a file or a list has more than about 20 rows to add up, compare or match: write the rows to CSV with a script (an Excel file through the tools skill, a PDF's tables through `pdfplumber`), `gran-import tmp_<name> <file>`, then answer with `gran-query`. The rows never pass through the chat, only the result does; SQL does the arithmetic, which the agent never does in its head. Columns arrive as text: `CAST(amount AS REAL)` before adding up, and clean formats first (`70 000` → `70000`, `1 234,50` → `1234.50`). Importing into a `tmp_` table that already exists adds the rows again: to reload, `DROP TABLE tmp_<name>` first. Drop the table when the work is done, or keep it by renaming and describing it; `/reflect` asks.

## Offer, never skip

A figure that fits an existing table's grain turns up in other work (a balance in a mail, an expense on a receipt): offer it in one line at a natural pause, "Add to `expenses`: 2026-10-02 SAS 2 450 kr, from the October statement? ==y== yes · ==n== no". The agent never decides on its own that such a figure isn't worth keeping.

## Showing the user

To show a table, `open .cosm/gran/<table>.csv` (a hidden folder the user can't browse to). Ids and phone numbers lose their leading zeros there; for those, or when the user wants a spreadsheet file, make one from the copy with the tools skill into `~/Downloads`.

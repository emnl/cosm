---
name: tools
description: How to read and make Word, Excel, PowerPoint and PDF files and read web pages on this Mac — which tool to use for each file type, and the exact command. Use before opening, converting or creating any such file.
---
# Tools

What this Mac has, and the right tool for each file type.

## What is installed

uv: !`~/.local/bin/uv --version 2>/dev/null || command -v uv 2>/dev/null || echo "not installed"`

Without uv, only the "No uv" column under Reading works and nothing under Making does; offer the install: "Install the toolbox? It lets me read and make Word, Excel, PowerPoint and PDF files. About 1 minute, nothing outside your user folder. <kbd>y</kbd> yes · <kbd>n</kbd> no", then run `curl -LsSf https://astral.sh/uv/install.sh | sh`. If `uv` is not on the path afterwards, call it as `~/.local/bin/uv`.

Every command below runs as `uv run -q --no-project --python 3.12 --with <package> python -c "<code>"` (or `uvx … ` where shown). Write longer code to a file in a new `mktemp -d` folder and run it with `python -I` (never from `~/Downloads`, where a stray file could be imported).

## Reading

| File | Use | No uv |
|---|---|---|
| PDF | read it directly, page by page (a scan is read as an image); for tables, `pdfplumber`: `pdfplumber.open(f).pages[i].extract_tables()` | read it directly |
| Word (.docx) | `pypandoc_binary`: `pypandoc.convert_file(f, 'gfm', extra_args=['--track-changes=all'])` (keeps headings, lists and tables, and shows tracked changes as marked insertions and deletions) | `textutil -convert txt -stdout <file>` (text only) |
| Excel (.xlsx) | `openpyxl`: `load_workbook(f, data_only=True)`, then each sheet's rows | — |
| PowerPoint (.pptx) | `python-pptx`: each slide's shapes with a text frame | — |
| Web page | the agent's own web fetch; if that fails, markitdown on the URL (below) | the agent's own web fetch |
| Anything else (.epub, .html, an odd format) | `uvx --python 3.12 --from 'markitdown[docx,xlsx,pptx,pdf]' markitdown <file or URL>` | — |

## Making

| File | Use |
|---|---|
| Word | write markdown, then `pypandoc.convert_file('x.md', 'docx', outputfile='x.docx')` |
| PDF | for anything with layout, make the Word file and ask the user to export it as PDF; for a plain text document, `reportlab` |
| Excel | `openpyxl`: `Workbook()`, append rows, `save()` |
| PowerPoint | `python-pptx`: one slide per section, title and bullet text |


## Changing a file someone else made

Keep its formatting: open the file itself with `openpyxl`, `python-pptx` or `python-docx` and change only the cells, text or slides asked for, then save it as a new file in `~/Downloads` with `-edited` in the name. Never rebuild it from a conversion: that loses styles, formulas and layout.
- Excel: load without `data_only` (with it, saving turns every formula into a fixed value). `openpyxl` drops dropdowns, conditional formatting and shapes: if the file has them, say so before changing it.
- Word: change text inside its runs, never `paragraph.text` (that drops bold and other formatting).

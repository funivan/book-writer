---
name: convert-md-to-epub
description: Convert a folder with markdown files to EPUB format for ebook readers.
compatibility:
  - pandoc
  - imagemagick (optional, for cover processing)
---

# Convert Markdown to EPUB

Converts a folder containing markdown files to a single EPUB file.

## When to Use

- Converting markdown story files to ebook format
- Creating EPUBs from generated content
- Preparing books for e-readers
- Triggered by: "convert to epub", "create epub", "convert md to epub", "конвертувати в epub", "створити epub"

## Instructions

When the user provides a folder path, run:

```bash
scripts/convert.sh --folder "<folder-path>"
```

Optional prefix: to include only `.md` files whose name starts with a prefix (e.g. scene files `s1.md`, `s2.md`):

```bash
scripts/convert.sh --folder "<folder-path>" --prefix "<prefix>"
```

If prefix is not specified, all `.md` files in the folder are used, sorted naturally (e.g. s1, s2, s10).

## Usage

**Arguments**

- `--folder <path>` (required) – Path to folder containing `.md` files.
- `--prefix <str>` (optional) – If set, only `.md` files whose basename starts with this prefix are included. If omitted, all `.md` files are used, in natural sort order.
- `-h`, `--help` – Show usage and exit.

**Requirements**

- **pandoc** – markdown to EPUB conversion.
- **coreutils** (macOS, optional) – for natural sort (s1, s2, s10). Linux `sort` already supports `-V`.

**Install required tools**

- **macOS:**  
  `brew install pandoc`  
  For natural chapter order (s1, s2, s10): `brew install coreutils`
- **Linux (Debian/Ubuntu):**  
  `sudo apt install pandoc`
- **Linux (Fedora):**  
  `sudo dnf install pandoc`

## What It Does

1. Merges `.md` files in the folder (natural sort: s1, s2, s10…).
2. Creates an EPUB with the folder name as title in the same folder.
3. Uses a temporary directory for merge/CSS; cleans up on exit.
4. Uses the first PNG/JPG/JPEG in the folder as cover if present.

## Example

```bash
# Convert a book folder (all .md files, natural sort)
scripts/convert.sh --folder "books/my-book"

# Only include scene files s1.md, s2.md, s10.md, ...
scripts/convert.sh --folder "books/my-book" --prefix "s"
```

This creates `books/my-book/my-book.epub` with proper formatting and cover image when available.

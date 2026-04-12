#!/usr/bin/env bash
set -euo pipefail

# Convert markdown files in a folder to a single EPUB.
# Usage: convert.sh --folder <path> [--prefix <prefix>]
#   --folder  path to folder containing .md files (required)
#   --prefix  optional; only include .md files whose name starts with this prefix (e.g. "s" for s1.md, s2.md). If omitted, all .md files are used, sorted naturally.
#
# Requirements: pandoc, optionally ImageMagick (magick) for cover processing.
# Install:
#   macOS:   brew install pandoc
#   Linux:   sudo apt install pandoc  (Debian/Ubuntu)  or  sudo dnf install pandoc  (Fedora)

readonly AUTHOR="${AUTHOR:-Ivan Shcherbak}"
readonly LANG="${LANG:-uk}"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

readonly CSS_CONTENT='body { font-size: 14pt;}'

usage() {
    echo "Usage: $0 --folder <path> [--prefix <prefix>]"
    echo ""
    echo "Options:"
    echo "  --folder <path>  Path to folder containing .md files (required)"
    echo "  --prefix <str>   Optional. Only include .md files whose name starts with prefix (e.g. s for s1.md, s2.md). If omitted, all .md files are used, sorted naturally."
    echo "  -h, --help       Show this help"
    echo ""
    echo "Example:"
    echo "  $0 --folder books/my-book                    # use all .md files in books/my-book"
    echo "  $0 --folder books/my-book --prefix s         # use only s1.md, s2.md, s10.md, ..."
    echo ""
    echo "Requirements: pandoc. For natural sort (s1, s2, s10) on macOS, coreutils is recommended."
    echo "  macOS:   brew install pandoc [coreutils]"
    echo "  Linux:   sudo apt install pandoc   (Debian/Ubuntu)"
    echo "           sudo dnf install pandoc   (Fedora)"
    exit "${1:-1}"
}

cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Parse arguments (while/case per shell best practices)
INPUT_FOLDER=""
PREFIX=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage 0 ;;
        --folder)
            if [[ $# -lt 2 ]]; then
                echo "Error: --folder requires a value" >&2
                exit 1
            fi
            INPUT_FOLDER="$2"
            shift 2
            ;;
        --prefix)
            if [[ $# -lt 2 ]]; then
                echo "Error: --prefix requires a value" >&2
                exit 1
            fi
            PREFIX="$2"
            shift 2
            ;;
        --) shift; break ;;
        -*) echo "Unknown option: $1" >&2; exit 1 ;;
        *) echo "Unexpected argument: $1 (use --folder and --prefix)" >&2; exit 1 ;;
    esac
done
if [[ -z "$INPUT_FOLDER" ]]; then
    echo "Error: --folder is required" >&2
    usage 1
fi

if [[ ! -d "$INPUT_FOLDER" ]]; then
    echo "Error: Folder '$INPUT_FOLDER' not found" >&2
    exit 1
fi

if ! command -v pandoc &>/dev/null; then
    echo "Error: pandoc is required. Install: brew install pandoc (macOS) or sudo apt install pandoc (Linux)" >&2
    exit 1
fi

INPUT_DIR="$(cd "$INPUT_FOLDER" && pwd)"
OUTPUT_DIR="$INPUT_DIR"
FOLDER_NAME="$(basename "$INPUT_DIR")"
TEMP_DIR="$(mktemp -d)"
TEMP_MERGED="$TEMP_DIR/merged.md"
TEMP_CSS="$TEMP_DIR/style.css"

echo "$CSS_CONTENT" > "$TEMP_CSS"

# Natural sort: gsort -V (GNU coreutils) on macOS, sort -V on Linux
if command -v gsort &>/dev/null; then
    SORT_CMD="gsort -V"
else
    SORT_CMD="sort -V"
fi

# Collect .md files: with optional prefix filter, then natural sort
echo "Merging MD files from: $INPUT_DIR"
md_files=()
while IFS= read -r -d '' f; do
    if [[ -z "$PREFIX" || "$(basename "$f")" == "$PREFIX"* ]]; then
        md_files+=("$f")
    fi
done < <(find "$INPUT_DIR" -maxdepth 1 -name "*.md" -type f -print0)

# Sort naturally (s1, s2, s10...) and merge
TOTAL_WORDS=0
while IFS= read -r md_file; do
    [[ -z "$md_file" ]] && continue
    echo "  Adding: $(basename "$md_file")"
    cat "$md_file" >> "$TEMP_MERGED"
    printf '\n' >> "$TEMP_MERGED"
    
    # Calculate word count
    words=$(wc -w < "$md_file")
    TOTAL_WORDS=$((TOTAL_WORDS + words))
done < <(printf '%s\n' "${md_files[@]}" | $SORT_CMD)

# Append total word count at the end
if [[ $TOTAL_WORDS -gt 0 ]]; then
    printf '\n# Статистика\n\nЗагальна кількість слів: %d\n' "$TOTAL_WORDS" >> "$TEMP_MERGED"
fi

if [[ ! -s "$TEMP_MERGED" ]]; then
    if [[ -n "$PREFIX" ]]; then
        echo "Error: No .md files matching prefix '$PREFIX' in '$INPUT_FOLDER'" >&2
    else
        echo "Error: No .md files found in '$INPUT_FOLDER'" >&2
    fi
    exit 1
fi

COVER=""
while IFS= read -r -d '' f; do
    COVER="$f"
    break
done < <(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname "cover.png" -o -iname "cover.jpg" -o -iname "cover.jpeg" \) -print0 2>/dev/null)

TITLE="$FOLDER_NAME"
SAFE_TITLE="$(echo "$FOLDER_NAME" | sed 's/[\/\\:*?"<>|]/-/g')"
OUTPUT_FILE="$OUTPUT_DIR/${SAFE_TITLE}.epub"

echo "Converting: $TEMP_MERGED → $OUTPUT_FILE"
echo "  Title:  $TITLE"
echo "  Author: $AUTHOR"
echo "  Lang:   $LANG"

PANDOC_ARGS=(
    --resource-path="$INPUT_DIR"
    --css="$TEMP_CSS"
    -o "$OUTPUT_FILE"
    "$TEMP_MERGED"
)

if [[ -n "$COVER" && -f "$COVER" ]]; then
    echo "  Cover:  $COVER"
    PANDOC_ARGS+=(--epub-cover-image="$COVER")
fi

pandoc "${PANDOC_ARGS[@]}"

if [[ -f "$OUTPUT_FILE" ]]; then
    echo ""
    echo "Successfully created: $OUTPUT_FILE"
    echo "  Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
else
    echo "Error: Failed to create EPUB" >&2
    exit 1
fi

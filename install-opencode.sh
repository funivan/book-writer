#!/usr/bin/env bash
set -euo pipefail

# Install book-writer skills into a project's .opencode/skills/ directory so they
# are discovered by opencode's native skill loader.
#
# opencode has no plugin marketplace — it loads plugins from .opencode/plugins/ and
# discovers skills from directories listed in opencode.json plus the conventional
# skill folders (.opencode/skills/, .claude/skills/, .agents/skills/ and their global
# equivalents). This script wires the skills bundled in this repo into a project's
# .opencode/skills/ folder; see the README for the plugin and opencode.json options.
#
# Usage: ./install-opencode.sh [--copy] [target-project-dir]
#   target-project-dir   Project to install into (default: current directory).
#   --copy               Copy skill files instead of symlinking (use on Windows or
#                        when the book-writer checkout may move/be deleted).
#   -h, --help           Show this help.

MODE="symlink"
TARGET=""

usage() {
    grep -E '^#( |$)' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --copy) MODE="copy"; shift ;;
        -h|--help) usage 0 ;;
        --) shift; break ;;
        -*) echo "Unknown option: $1" >&2; usage 1 ;;
        *) TARGET="$1"; shift ;;
    esac
done

TARGET="${TARGET:-$PWD}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
DEST="$TARGET/.opencode/skills"

if [[ ! -d "$SKILLS_SRC" ]]; then
    echo "Error: skills/ not found at $SKILLS_SRC" >&2
    exit 1
fi

if [[ ! -d "$TARGET" ]]; then
    echo "Error: target project directory does not exist: $TARGET" >&2
    exit 1
fi

mkdir -p "$DEST"

installed=0
for skill in "$SKILLS_SRC"/*/; do
    name="$(basename "$skill")"
    [[ -f "${skill}SKILL.md" ]] || continue
    target="$DEST/$name"
    rm -rf "$target"
    if [[ "$MODE" == "copy" ]]; then
        cp -R "${skill%/}" "$target"
    else
        ln -s "${skill%/}" "$target"
    fi
    echo "Installed ($MODE): $name -> $target"
    installed=$((installed + 1))
done

if [[ "$installed" -eq 0 ]]; then
    echo "Error: no skills found under $SKILLS_SRC" >&2
    exit 1
fi

echo ""
echo "Done. $installed skill(s) installed into $DEST"
echo "Restart opencode (skills are cached at startup) to pick them up."

#!/usr/bin/env bash
set -euo pipefail

# Slugify a string for use in filenames.
# Converts to lowercase, replaces non-alphanumeric chars with hyphens,
# trims leading/trailing hyphens, and collapses consecutive hyphens.
#
# Usage: slugify.sh "Some Title Here"
# Output: some-title-here

if [[ $# -eq 0 ]] || [[ -z "$1" ]]; then
    echo "Usage: $0 <string>" >&2
    exit 1
fi

slug="$1"
# Lowercase
slug="$(echo "$slug" | tr '[:upper:]' '[:lower:]')"
# Replace non-alphanumeric (except hyphens) with hyphens
slug="$(echo "$slug" | sed 's/[^a-z0-9-]/-/g')"
# Collapse consecutive hyphens
slug="$(echo "$slug" | sed 's/-\{2,\}/-/g')"
# Trim leading/trailing hyphens
slug="$(echo "$slug" | sed 's/^-//;s/-$//')"

echo "$slug"

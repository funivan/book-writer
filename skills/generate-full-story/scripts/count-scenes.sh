#!/bin/bash
# Count the number of scenes in a book-idea.txt file
# Usage: ./count-scenes.sh path/to/book-idea.txt

if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-book-idea.txt>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    exit 1
fi

# Count lines matching "### N." pattern
count=$(grep -c '^### [0-9]\+\.' "$1")
echo "$count"
